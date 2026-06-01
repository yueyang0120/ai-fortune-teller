import Foundation
import UIKit

class FortuneTaskManager: ObservableObject {
    @Published private(set) var activeTasks: [UUID: FortuneTask] = [:]
    private let historyService: ReadingHistoryService
    private let backgroundTaskManager = BackgroundTaskManager.shared
    private let processingQueue = DispatchQueue(label: "com.ZiWeiFortune.FortuneTaskManager", qos: .userInitiated)

    init(historyService: ReadingHistoryService) {
        self.historyService = historyService
        setupNotificationObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleResumePendingTasks(_:)),
            name: .shouldResumePendingTasks,
            object: nil
        )
    }

    @objc private func handleResumePendingTasks(_ notification: Notification) {
        guard let pendingTasks = notification.userInfo?["pendingTasks"] as? [PersistentFortuneTaskData] else {
            return
        }

        for taskData in pendingTasks {
            // 检查任务是否已经在运行
            if activeTasks[taskData.id] != nil {
                continue
            }

            // 恢复任务
            #if DEBUG
            print("Resuming fortune task: \(taskData.id)")
            #endif
            resumeTask(taskData: taskData)
        }
    }

    struct FortuneTask {
        let id: UUID
        let startTime: Date
        var status: Status
        var progress: Double
        var error: Error?
        let birthInfo: BirthInfo

        enum Status {
            case analyzing
            case completed
            case failed
        }
    }

    func startNewFortuneTask(birthInfo: BirthInfo) -> UUID {
        let taskId = UUID()
        let task = FortuneTask(
            id: taskId,
            startTime: Date(),
            status: .analyzing,
            progress: 0,
            birthInfo: birthInfo
        )

        // Add task to active tasks
        DispatchQueue.main.async {
            self.activeTasks[taskId] = task

            // Add the in-progress task to history
            _ = self.historyService.addInProgressTask(birthInfo: birthInfo, taskId: taskId)
        }

        // 保存任务状态以便后台恢复
        backgroundTaskManager.saveFortuneTaskState(taskId: taskId, birthInfo: birthInfo)

        // 开始后台任务
        backgroundTaskManager.startBackgroundTask(for: taskId, taskName: "Fortune Analysis - \(taskId)")

        // Start processing with background task support
        processTask(taskId: taskId, birthInfo: birthInfo)

        return taskId
    }

    private func resumeTask(taskData: PersistentFortuneTaskData) {
        let task = FortuneTask(
            id: taskData.id,
            startTime: taskData.startTime,
            status: .analyzing,
            progress: 0,
            birthInfo: taskData.birthInfo
        )

        DispatchQueue.main.async {
            self.activeTasks[taskData.id] = task
        }

        // 开始后台任务
        backgroundTaskManager.startBackgroundTask(for: taskData.id, taskName: "Fortune Analysis - \(taskData.id)")

        // 继续处理任务
        processTask(taskId: taskData.id, birthInfo: taskData.birthInfo)
    }

    private func processTask(taskId: UUID, birthInfo: BirthInfo) {
        processingQueue.async { [weak self] in
            guard let self = self else {
                return
            }

            Task {
                do {
                    #if DEBUG
                    print("Starting fortune analysis for task: \(taskId)")
                    #endif

                    // 1. 生成命盘
                    await MainActor.run {
                        self.activeTasks[taskId]?.progress = 0.3
                    }
                    let chartService = ZiWeiChartService()
                    let chart = try await chartService.generateChart(from: birthInfo)

                    // 1.1 立即保存命盘数据并发送通知（这样用户可以先看命盘）
                    await MainActor.run {
                        self.historyService.updateTaskWithChart(taskId: taskId, chart: chart)

                        // 发送命盘就绪通知
                        NotificationCenter.default.post(
                            name: .fortuneChartReady,
                            object: nil,
                            userInfo: ["taskId": taskId, "chart": chart, "birthInfo": birthInfo]
                        )
                    }

                    // 1.5 生成关键流年动态数据
                    // 为前8个大限的起始年份生成流年盘，帮助AI判断运势起伏
                    var yearlyFlows: [YearlyFlowContext] = []
                    let calendar = Calendar.current
                    let birthYear = calendar.component(.year, from: birthInfo.solarDate)
                    let currentYear = calendar.component(.year, from: Date())

                    for limit in chart.majorLimits.prefix(8) {
                        // 计算大限起始年份 (虚岁换算：Year = BirthYear + Age - 1)
                        let startYear = birthYear + limit.startAge - 1

                        // 生成大限第一年的流年盘
                        if let flow = try? await chartService.generateYearlyFlowContext(birthInfo: birthInfo, year: startYear) {
                            yearlyFlows.append(flow)
                        }

                        // 如果当前真实年份落在这个大限内，且不是第一年，额外生成当前年份的流年盘
                        // 这对用户当下的运势分析非常重要
                        let endYear = birthYear + limit.endAge - 1
                        if currentYear > startYear && currentYear <= endYear {
                            if let flow = try? await chartService.generateYearlyFlowContext(birthInfo: birthInfo, year: currentYear) {
                                yearlyFlows.append(flow)
                            }
                        }
                    }

                    // 2. AI分析
                    await MainActor.run {
                        self.activeTasks[taskId]?.progress = 0.6
                    }
                    let analyzerService = FortuneAnalyzerService()
                    let analysis = try await analyzerService.analyze(chart: chart, birthInfo: birthInfo, yearlyFlows: yearlyFlows)

                    // 3. 创建reading
                    await MainActor.run {
                        self.activeTasks[taskId]?.progress = 0.9
                    }
                    let reading = FortuneReading(
                        id: taskId,
                        birthInfo: birthInfo,
                        chart: chart,
                        analysis: analysis,
                        timestamp: Date()
                    )

                    // 4. 保存到历史并更新任务状态，确认保存后再发通知
                    await MainActor.run {
                        self.activeTasks[taskId]?.status = .completed
                        self.activeTasks[taskId]?.progress = 1.0

                        // 清理持久化状态
                        self.backgroundTaskManager.removeFortuneTaskState(for: taskId)
                    }

                    // 使用带 completion 的版本确保 CoreData 写入完成
                    self.historyService.updateTaskStatus(taskId: taskId, reading: reading, status: TaskStatus.completed) { [weak self] in
                        guard let self = self else { return }

                        // 发送完成通知（在 CoreData 保存确认后）
                        self.backgroundTaskManager.sendFortuneTaskCompletedNotification(taskId: taskId)

                        // 结束后台任务
                        self.backgroundTaskManager.endBackgroundTask(for: taskId)

                        // 发布完成通知
                        NotificationCenter.default.post(
                            name: .fortuneTaskCompleted,
                            object: nil,
                            userInfo: ["taskId": taskId, "reading": reading]
                        )

                        #if DEBUG
                        print("Fortune task completed successfully: \(taskId)")
                        #endif
                    }

                } catch {
                    // 先结束后台任务，防止在清理前触发超时通知
                    self.backgroundTaskManager.endBackgroundTask(for: taskId)

                    await MainActor.run {
                        self.activeTasks[taskId]?.status = .failed
                        self.activeTasks[taskId]?.error = error
                        self.historyService.updateTaskStatus(taskId: taskId, status: TaskStatus.failed, errorMessage: error.localizedDescription)

                        // 清理持久化状态（不要只是更新为失败，直接删除）
                        self.backgroundTaskManager.removeFortuneTaskState(for: taskId)
                    }

                    // 发送失败通知
                    self.backgroundTaskManager.sendFortuneTaskFailedNotification(taskId: taskId, errorMessage: error.localizedDescription)

                    #if DEBUG
                    print("Fortune task failed: \(taskId), error: \(error)")
                    #endif
                }
            }
        }
    }

    func getTask(id: UUID) -> FortuneTask? {
        return activeTasks[id]
    }

    func removeTask(id: UUID) {
        DispatchQueue.main.async {
            self.activeTasks.removeValue(forKey: id)
        }
    }

    /// 重试失败的任务
    func retryTask(birthInfo: BirthInfo, originalTaskId: UUID? = nil) -> UUID {
        #if DEBUG
        print("Starting retry process...")
        #endif

        // 如果提供了原始任务ID，先删除原始任务
        if let originalId = originalTaskId {
            // 从活动任务中移除
            removeTask(id: originalId)

            // 清理持久化状态
            backgroundTaskManager.removeFortuneTaskState(for: originalId)

            // 从历史记录中删除失败的任务（使用 completion 确保删除完成后再创建新任务）
            historyService.deleteTaskById(originalId) { [weak self] in
                guard let self = self else { return }
                // 删除完成后才创建新任务
                let newTaskId = self.startNewFortuneTask(birthInfo: birthInfo)
                #if DEBUG
                print("Retry task created after cleanup: \(newTaskId)")
                #endif
            }

            // 返回一个临时 UUID — 实际任务会在 completion 中创建
            // 但因为现有调用方需要一个同步返回值，我们仍然立即创建
            // 注意：为了保持 API 兼容性，我们使用下面的 fallthrough
        }

        // 如果没有原始任务需要清理，直接创建新任务
        if originalTaskId == nil {
            let newTaskId = startNewFortuneTask(birthInfo: birthInfo)
            #if DEBUG
            print("Retry task created: \(newTaskId)")
            #endif
            return newTaskId
        }

        // 当有 originalTaskId 时，任务在 completion 回调中创建
        // 返回一个占位 ID（调用方使用 history 来追踪任务，不依赖此返回值）
        return UUID()
    }
}

extension Notification.Name {
    static let fortuneTaskCompleted = Notification.Name("fortuneTaskCompleted")
    static let fortuneChartReady = Notification.Name("fortuneChartReady")
    static let shouldResumePendingTasks = Notification.Name("shouldResumePendingTasks")
    static let postAnalysisGoToHistory = Notification.Name("postAnalysisGoToHistory")
    static let postAnalysisTryAnother = Notification.Name("postAnalysisTryAnother")
    static let postAnalysisStartReading = Notification.Name("postAnalysisStartReading")
}
