import Foundation
import UIKit
import UserNotifications

@Observable
final class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()

    private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = .invalid
    private var activeTasks: Set<UUID> = []

    private init() {
        setupNotificationCenter()
    }

    private func setupNotificationCenter() {
        // 请求通知权限
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("📱 Notification permission granted")
            } else if let error = error {
                print("❌ Notification permission error: \(error)")
            }
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notification permission granted")
            } else if let error = error {
                print("❌ Notification permission error: \(error)")
            }
        }
    }

    func sendNotification(title: String, body: String, userInfo: [String: Any] = [:]) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = userInfo

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to send notification: \(error)")
            }
        }
    }

    // MARK: - Background Task Management

    func startBackgroundTask(for taskId: UUID, taskName: String = "Fortune Analysis") {
        // 添加任务到活跃列表
        activeTasks.insert(taskId)

        // 如果已有后台任务在运行，不需要重新创建
        if backgroundTaskIdentifier != .invalid {
            print("🔄 Background task already running, adding task \(taskId) to queue")
            return
        }

        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(withName: taskName) { [weak self] in
            // 后台时间即将耗尽时的处理
            self?.handleBackgroundTaskExpiration()
        }

        if backgroundTaskIdentifier == .invalid {
            print("❌ Failed to start background task")
        } else {
            print("✅ Background task started with ID: \(backgroundTaskIdentifier.rawValue)")
            print("⏰ Background time remaining: \(UIApplication.shared.backgroundTimeRemaining) seconds")
        }
    }

    func endBackgroundTask(for taskId: UUID) {
        // 从活跃任务列表中移除
        activeTasks.remove(taskId)

        // 如果还有其他任务在运行，不结束后台任务
        if !activeTasks.isEmpty {
            print("🔄 Other tasks still running, keeping background task active")
            return
        }

        // 结束后台任务
        if backgroundTaskIdentifier != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
            backgroundTaskIdentifier = .invalid
            print("✅ Background task ended")
        }
    }

    private func handleBackgroundTaskExpiration() {
        print("⚠️ Background task is about to expire")

        // 检查是否真的有正在分析中的任务（双重验证：内存中的 activeTasks + 持久化状态）
        let pendingPersistentTasks = getAllPendingFortuneTasks()
        let hasRealActiveTasks = !activeTasks.isEmpty && !pendingPersistentTasks.isEmpty

        // 只有确实有进行中的任务才发送通知
        if hasRealActiveTasks {
            sendTaskContinuingNotification()
        } else {
            // 清理可能残留的无效任务
            activeTasks.removeAll()
            print("🧹 Cleared stale active tasks on expiration")
        }

        // 清理后台任务
        if backgroundTaskIdentifier != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
            backgroundTaskIdentifier = .invalid
        }
    }

    // MARK: - Task Persistence for Fortune

    func saveFortuneTaskState(taskId: UUID, birthInfo: BirthInfo) {
        let taskData = PersistentFortuneTaskData(
            id: taskId,
            birthInfo: birthInfo,
            startTime: Date(),
            status: .analyzing
        )

        if let data = try? JSONEncoder().encode(taskData) {
            UserDefaults.standard.set(data, forKey: "fortune_task_\(taskId.uuidString)")
            print("💾 Fortune task state saved for task: \(taskId)")
        }
    }

    func loadFortuneTaskState(for taskId: UUID) -> PersistentFortuneTaskData? {
        guard let data = UserDefaults.standard.data(forKey: "fortune_task_\(taskId.uuidString)"),
              let taskData = try? JSONDecoder().decode(PersistentFortuneTaskData.self, from: data) else {
            return nil
        }
        return taskData
    }

    func removeFortuneTaskState(for taskId: UUID) {
        UserDefaults.standard.removeObject(forKey: "fortune_task_\(taskId.uuidString)")
        print("🗑️ Fortune task state removed for task: \(taskId)")
    }

    func getAllPendingFortuneTasks() -> [PersistentFortuneTaskData] {
        let userDefaults = UserDefaults.standard
        var tasks: [PersistentFortuneTaskData] = []

        for key in userDefaults.dictionaryRepresentation().keys {
            if key.hasPrefix("fortune_task_"),
               let data = userDefaults.data(forKey: key),
               let taskData = try? JSONDecoder().decode(PersistentFortuneTaskData.self, from: data),
               taskData.status == .analyzing {
                tasks.append(taskData)
            }
        }

        return tasks
    }

    // MARK: - Notifications for Fortune

    func sendFortuneTaskCompletedNotification(taskId: UUID) {
        let strings = LocalizationManager.shared.strings
        let content = UNMutableNotificationContent()
        content.title = strings.chartReady
        content.body = strings.language == .english
            ? "Your Zi Wei chart is ready. Tap to view the results."
            : "您的紫微命盘已生成完毕，点击查看测算结果"
        content.sound = .default
        content.badge = 1
        content.userInfo = ["taskId": taskId.uuidString, "type": "task_completed"]

        let request = UNNotificationRequest(
            identifier: "task_completed_\(taskId.uuidString)",
            content: content,
            trigger: nil // 立即发送
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to send completion notification: \(error)")
            } else {
                print("📱 Fortune task completion notification sent")
            }
        }
    }

    func sendFortuneTaskFailedNotification(taskId: UUID, errorMessage: String) {
        let strings = LocalizationManager.shared.strings
        let content = UNMutableNotificationContent()
        content.title = strings.failed
        content.body = strings.language == .english
            ? "Chart generation failed: \(errorMessage). Please retry."
            : "命盘生成失败：\(errorMessage)，请重试"
        content.sound = .default
        content.badge = 1
        content.userInfo = ["taskId": taskId.uuidString, "type": "task_failed"]

        let request = UNNotificationRequest(
            identifier: "task_failed_\(taskId.uuidString)",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to send failure notification: \(error)")
            } else {
                print("📱 Fortune task failure notification sent")
            }
        }
    }

    private func sendTaskContinuingNotification() {
        let strings = LocalizationManager.shared.strings
        let content = UNMutableNotificationContent()
        content.title = strings.analyzing
        content.body = strings.language == .english
            ? "Your chart is being generated in the background. We'll notify you when it's ready."
            : "您的命盘正在后台生成，完成后我们会通知您"
        content.sound = .default
        content.badge = 1

        let request = UNNotificationRequest(
            identifier: "task_continuing_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to send continuing notification: \(error)")
            } else {
                print("📱 Task continuing notification sent")
            }
        }
    }

    // MARK: - App State Monitoring

    func handleAppWillEnterBackground() {
        print("🌙 App entering background with \(activeTasks.count) active tasks")

        if !activeTasks.isEmpty {
            // 扩展后台时间
            for taskId in activeTasks {
                startBackgroundTask(for: taskId, taskName: "Fortune Analysis - \(taskId)")
            }
        }
    }

    func handleAppDidBecomeActive() {
        print("☀️ App became active")

        // 检查是否有待恢复的任务
        let pendingTasks = getAllPendingFortuneTasks()
        if !pendingTasks.isEmpty {
            print("🔄 Found \(pendingTasks.count) pending fortune tasks to potentially resume")
            // 这里可以通知 FortuneTaskManager 恢复任务
            NotificationCenter.default.post(
                name: .shouldResumePendingTasks,
                object: nil,
                userInfo: ["pendingTasks": pendingTasks]
            )
        }
    }
}

// MARK: - Data Models

struct PersistentFortuneTaskData: Codable {
    let id: UUID
    let birthInfo: BirthInfo
    let startTime: Date
    var status: TaskStatus
    var errorMessage: String?

    enum TaskStatus: String, Codable {
        case analyzing
        case completed
        case failed
    }
}

// MARK: - Notification Extensions

extension Notification.Name {
    static let notificationTapped = Notification.Name("notificationTapped")
}
