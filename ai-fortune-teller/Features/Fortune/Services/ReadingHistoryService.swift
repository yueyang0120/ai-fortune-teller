import Foundation
import CoreData
import Combine

class ReadingHistoryService: ObservableObject {
    static let shared = ReadingHistoryService()
    @Published var readings: [ReadingHistory] = []
    private let coreDataManager = CoreDataManager.shared

    init() {
        fetchReadings()
    }

    func fetchReadings() {
        do {
            let entities = try coreDataManager.fetchAllReadings()
            let newReadings = entities.map { ReadingHistory(from: $0) }
            // Ensure @Published property is updated on main thread
            if Thread.isMainThread {
                readings = newReadings
            } else {
                DispatchQueue.main.async {
                    self.readings = newReadings
                }
            }
            #if DEBUG
            print("Fetched \(newReadings.count) reading(s) from history")
            #endif
        } catch {
            print("Failed to fetch readings: \(error)")
        }
    }

    func saveReading(_ reading: FortuneReading) async {
        await MainActor.run {
            coreDataManager.performBackgroundTask { context in
                let entity = ReadingHistoryEntity(context: context)
                entity.id = reading.id
                entity.createdAt = reading.timestamp
                entity.status = "completed"

                // 使用 ISO8601 日期编码策略
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601

                // 编码 birthInfo
                if let birthData = try? encoder.encode(reading.birthInfo),
                   let birthJSON = String(data: birthData, encoding: .utf8) {
                    entity.birthInfoJSON = birthJSON
                }

                // 编码 chart
                if let chartData = try? encoder.encode(reading.chart),
                   let chartJSON = String(data: chartData, encoding: .utf8) {
                    entity.chartDataJSON = chartJSON
                }

                entity.analysisText = reading.analysis

                do {
                    try context.save()
                    #if DEBUG
                    print("Saved reading to CoreData")
                    #endif
                } catch {
                    print("Failed to save reading: \(error)")
                }
            }

            // 重新获取列表
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.fetchReadings()
            }
        }
    }

    // 添加进行中的任务
    func addInProgressTask(birthInfo: BirthInfo, taskId: UUID) -> UUID {
        coreDataManager.performBackgroundTask { context in
            let entity = ReadingHistoryEntity(context: context)
            entity.id = taskId
            entity.createdAt = Date()
            entity.status = "analyzing"

            // 使用 ISO8601 日期编码策略
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601

            // 编码 birthInfo
            if let birthData = try? encoder.encode(birthInfo),
               let birthJSON = String(data: birthData, encoding: .utf8) {
                entity.birthInfoJSON = birthJSON
                #if DEBUG
                print("Encoded birthInfo: \(birthJSON.prefix(100))...")
                #endif
            } else {
                print("Failed to encode birthInfo")
            }

            do {
                try context.save()
                #if DEBUG
                print("Added in-progress task to CoreData")
                #endif
            } catch {
                print("Failed to save in-progress task: \(error)")
            }
        }

        // 重新获取列表
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.fetchReadings()
        }

        return taskId
    }

    // 更新任务状态
    func updateTaskStatus(taskId: UUID, reading: FortuneReading? = nil, status: TaskStatus, errorMessage: String? = nil) {
        coreDataManager.performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<ReadingHistoryEntity> = ReadingHistoryEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", taskId as CVarArg)

            do {
                let results = try context.fetch(fetchRequest)
                if let entity = results.first {
                    entity.status = status.rawValue
                    entity.errorMessage = errorMessage

                    if let reading = reading {
                        let encoder = JSONEncoder()
                        encoder.dateEncodingStrategy = .iso8601

                        if let chartData = try? encoder.encode(reading.chart),
                           let chartJSON = String(data: chartData, encoding: .utf8) {
                            entity.chartDataJSON = chartJSON
                        }
                        entity.analysisText = reading.analysis
                    }

                    try context.save()
                    #if DEBUG
                    print("Updated task status to \(status.rawValue)")
                    #endif
                }
            } catch {
                print("Failed to update task status: \(error)")
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.fetchReadings()
        }
    }

    /// Update task status with completion callback — use when you need to chain operations after save
    func updateTaskStatus(taskId: UUID, reading: FortuneReading? = nil, status: TaskStatus, errorMessage: String? = nil, completion: @escaping () -> Void) {
        coreDataManager.performBackgroundTaskAsync({ context in
            let fetchRequest: NSFetchRequest<ReadingHistoryEntity> = ReadingHistoryEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", taskId as CVarArg)

            do {
                let results = try context.fetch(fetchRequest)
                if let entity = results.first {
                    entity.status = status.rawValue
                    entity.errorMessage = errorMessage

                    if let reading = reading {
                        let encoder = JSONEncoder()
                        encoder.dateEncodingStrategy = .iso8601

                        if let chartData = try? encoder.encode(reading.chart),
                           let chartJSON = String(data: chartData, encoding: .utf8) {
                            entity.chartDataJSON = chartJSON
                        }
                        entity.analysisText = reading.analysis
                    }

                    try context.save()
                    #if DEBUG
                    print("Updated task status to \(status.rawValue)")
                    #endif
                }
            } catch {
                print("Failed to update task status: \(error)")
            }
        }, completion: {
            self.fetchReadings()
            completion()
        })
    }

    // 更新任务的命盘数据（在AI分析完成前就保存命盘）
    func updateTaskWithChart(taskId: UUID, chart: ZiWeiChart) {
        coreDataManager.performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<ReadingHistoryEntity> = ReadingHistoryEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", taskId as CVarArg)

            do {
                let results = try context.fetch(fetchRequest)
                if let entity = results.first {
                    // 使用 ISO8601 日期编码策略
                    let encoder = JSONEncoder()
                    encoder.dateEncodingStrategy = .iso8601

                    // 保存命盘数据
                    if let chartData = try? encoder.encode(chart),
                       let chartJSON = String(data: chartData, encoding: .utf8) {
                        entity.chartDataJSON = chartJSON
                        #if DEBUG
                        print("Saved chart data to task \(taskId)")
                        #endif
                    }

                    try context.save()
                }
            } catch {
                print("Failed to save chart to task: \(error)")
            }
        }

        // 重新获取列表
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.fetchReadings()
        }
    }

    func deleteReading(_ history: ReadingHistory) {
        coreDataManager.deleteReading(history.entity)
        fetchReadings()
        #if DEBUG
        print("Deleted reading")
        #endif
    }

    func deleteReadings(at offsets: IndexSet) {
        for index in offsets {
            let history = readings[index]
            deleteReading(history)
        }
    }

    func deleteTaskById(_ taskId: UUID) {
        coreDataManager.performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<ReadingHistoryEntity> = ReadingHistoryEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", taskId as CVarArg)

            do {
                let results = try context.fetch(fetchRequest)
                if let entity = results.first {
                    context.delete(entity)
                    try context.save()
                    #if DEBUG
                    print("Deleted task with id: \(taskId)")
                    #endif
                }
            } catch {
                print("Failed to delete task: \(error)")
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.fetchReadings()
        }
    }

    /// Delete task by ID with completion callback — use when you need to chain operations
    func deleteTaskById(_ taskId: UUID, completion: @escaping () -> Void) {
        coreDataManager.performBackgroundTaskAsync({ context in
            let fetchRequest: NSFetchRequest<ReadingHistoryEntity> = ReadingHistoryEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", taskId as CVarArg)

            do {
                let results = try context.fetch(fetchRequest)
                if let entity = results.first {
                    context.delete(entity)
                    try context.save()
                    #if DEBUG
                    print("Deleted task with id: \(taskId)")
                    #endif
                }
            } catch {
                print("Failed to delete task: \(error)")
            }
        }, completion: {
            self.fetchReadings()
            completion()
        })
    }

    // 清除所有历史记录
    func deleteAllReadings() {
        coreDataManager.deleteAllReadings()
        fetchReadings()
        #if DEBUG
        print("All readings deleted")
        #endif
    }

    // MARK: - Synastry History

    /// Add an in-progress synastry entry to history (before analysis starts)
    func addInProgressSynastry(synastryInfo: SynastryInfo) {
        coreDataManager.performBackgroundTask { context in
            let entity = ReadingHistoryEntity(context: context)
            entity.id = synastryInfo.id
            entity.createdAt = Date()
            entity.status = "analyzing"

            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601

            if let data = try? encoder.encode(synastryInfo),
               let json = String(data: data, encoding: .utf8) {
                entity.birthInfoJSON = json
            }

            do {
                try context.save()
                #if DEBUG
                print("Added in-progress synastry to CoreData")
                #endif
            } catch {
                print("Failed to save in-progress synastry: \(error)")
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.fetchReadings()
        }
    }

    /// Update a synastry entry with completed analysis
    func completeSynastryReading(id: UUID, analysis: String) {
        coreDataManager.performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<ReadingHistoryEntity> = ReadingHistoryEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

            do {
                let results = try context.fetch(fetchRequest)
                if let entity = results.first {
                    entity.status = "synastry"
                    entity.analysisText = analysis
                    try context.save()
                    #if DEBUG
                    print("Updated synastry reading with analysis")
                    #endif
                } else {
                    // Fallback: entry not found, create new
                    print("Synastry entry not found for id \(id), skipping update")
                }
            } catch {
                print("Failed to update synastry reading: \(error)")
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.fetchReadings()
        }
    }

    /// Save a completed synastry reading to history (legacy — creates new entry)
    func saveSynastryReading(synastryInfo: SynastryInfo, analysis: String) {
        coreDataManager.performBackgroundTask { context in
            let entity = ReadingHistoryEntity(context: context)
            entity.id = synastryInfo.id
            entity.createdAt = Date()
            entity.status = "synastry"

            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601

            // Store full SynastryInfo as JSON in birthInfoJSON field
            if let data = try? encoder.encode(synastryInfo),
               let json = String(data: data, encoding: .utf8) {
                entity.birthInfoJSON = json
            }

            entity.analysisText = analysis

            do {
                try context.save()
                #if DEBUG
                print("Saved synastry reading to CoreData")
                #endif
            } catch {
                print("Failed to save synastry reading: \(error)")
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.fetchReadings()
        }
    }
}
