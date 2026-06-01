import Foundation
import CoreData

// ReadingHistory 是 FortuneReading 的轻量级包装，用于列表显示
struct ReadingHistory: Identifiable {
    let id: UUID
    let birthInfo: BirthInfo
    let timestamp: Date
    let status: TaskStatus
    let errorMessage: String?
    let entity: ReadingHistoryEntity // 保持对 CoreData entity 的引用
    let isInvalidData: Bool // 标记数据是否有效
    let isSynastry: Bool // 缓存：是否为合盘记录

    init(from entity: ReadingHistoryEntity) {
        self.id = entity.id ?? UUID()
        self.timestamp = entity.createdAt ?? Date()
        self.entity = entity
        self.errorMessage = entity.errorMessage

        // 解析状态
        if let statusString = entity.status {
            self.status = TaskStatus(rawValue: statusString) ?? .completed
        } else {
            self.status = .completed
        }

        // 解析 birthInfo
        if let birthInfoJSON = entity.birthInfoJSON,
           let data = birthInfoJSON.data(using: .utf8) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601 // 使用 ISO8601 日期解码策略

            // Try decoding as SynastryInfo first (covers both completed synastry and in-progress synastry)
            if let synInfo = try? decoder.decode(SynastryInfo.self, from: data) {
                self.birthInfo = synInfo.personA
                self.isInvalidData = false
                self.isSynastry = true
            } else if let decoded = try? decoder.decode(BirthInfo.self, from: data) {
                self.birthInfo = decoded
                self.isInvalidData = false
                self.isSynastry = false
            } else {
                // 如果解析失败，使用默认值，并标记为无效数据
                print("❌ Failed to decode birthInfo from JSON: \(birthInfoJSON)")
                self.birthInfo = BirthInfo(
                    solarDate: Date(),
                    birthTime: "",
                    birthHour: 0,
                    birthMinute: 0,
                    location: "",
                    longitude: 0,
                    latitude: 0,
                    gender: .male
                )
                self.isInvalidData = true
                self.isSynastry = false
            }
        } else {
            // 如果没有 birthInfoJSON，标记为无效数据
            print("❌ No birthInfoJSON found in entity")
            self.birthInfo = BirthInfo(
                solarDate: Date(),
                birthTime: "",
                birthHour: 0,
                birthMinute: 0,
                location: "",
                longitude: 0,
                latitude: 0,
                gender: .male
            )
            self.isInvalidData = true
            self.isSynastry = false
        }
    }

    var displayDateString: String {
        return LocalizationManager.shared.strings.formatTimestamp(timestamp)
    }

    var shortDescription: String {
        let dateStr = birthInfo.displayDateString
        let timeStr = birthInfo.localizedBirthTime
        return "\(dateStr) \(timeStr)"
    }

    var statusDisplayString: String {
        let strings = LocalizationManager.shared.strings
        switch status {
        case .analyzing:
            return strings.analyzing
        case .completed, .synastry:
            return strings.completed
        case .failed:
            return strings.failed
        }
    }

    var statusIcon: String {
        switch status {
        case .analyzing:
            return "hourglass"
        case .completed, .synastry:
            return "checkmark.circle.fill"
        case .failed:
            return "exclamationmark.circle.fill"
        }
    }

    // 从 entity 获取完整的 FortuneReading
    func getFullReading() throws -> FortuneReading {
        guard status == .completed else {
            print("❌ getFullReading failed: status is not completed, current status: \(status)")
            throw FortuneReadingError.invalidData
        }

        guard let birthInfoJSON = entity.birthInfoJSON,
              let chartDataJSON = entity.chartDataJSON,
              let analysisText = entity.analysisText else {
            print("❌ getFullReading failed: missing data")
            print("  birthInfoJSON: \(entity.birthInfoJSON != nil)")
            print("  chartDataJSON: \(entity.chartDataJSON != nil)")
            print("  analysisText: \(entity.analysisText != nil)")
            throw FortuneReadingError.invalidData
        }

        // 验证 chartDataJSON 不为空字符串或空对象
        let trimmedChartJSON = chartDataJSON.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedChartJSON.isEmpty && trimmedChartJSON != "{}" && trimmedChartJSON != "[]" else {
            print("❌ getFullReading failed: chartDataJSON is empty or invalid")
            throw FortuneReadingError.invalidData
        }

        let decoder = JSONDecoder()
        // 使用 ISO8601 日期解码策略，与 FortuneReading 保持一致
        decoder.dateDecodingStrategy = .iso8601

        // 解析 birthInfo
        guard let birthData = birthInfoJSON.data(using: .utf8) else {
            print("❌ getFullReading failed: cannot convert birthInfoJSON to data")
            throw FortuneReadingError.decodingFailed
        }

        let birthInfo: BirthInfo
        do {
            birthInfo = try decoder.decode(BirthInfo.self, from: birthData)
        } catch {
            print("❌ getFullReading failed: cannot decode birthInfo - \(error)")
            throw FortuneReadingError.decodingFailed
        }

        // 解析 chart
        guard let chartData = chartDataJSON.data(using: .utf8) else {
            print("❌ getFullReading failed: cannot convert chartDataJSON to data")
            throw FortuneReadingError.decodingFailed
        }

        let chart: ZiWeiChart
        do {
            chart = try decoder.decode(ZiWeiChart.self, from: chartData)

            // 验证 chart 数据完整性
            guard !chart.palaces.isEmpty else {
                print("❌ getFullReading failed: chart has no palaces")
                throw FortuneReadingError.invalidData
            }
        } catch {
            print("❌ getFullReading failed: cannot decode chart - \(error)")
            print("  chartDataJSON content: \(String(chartDataJSON.prefix(200)))...")
            throw FortuneReadingError.decodingFailed
        }

        return FortuneReading(
            id: id,
            birthInfo: birthInfo,
            chart: chart,
            analysis: analysisText,
            timestamp: timestamp
        )
    }

    // 获取命盘数据（即使任务还在分析中）
    func getChartOnly() -> ZiWeiChart? {
        guard let chartDataJSON = entity.chartDataJSON else {
            return nil
        }

        // 验证 chartDataJSON 不为空字符串或空对象
        let trimmedChartJSON = chartDataJSON.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedChartJSON.isEmpty && trimmedChartJSON != "{}" && trimmedChartJSON != "[]" else {
            return nil
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard let chartData = chartDataJSON.data(using: .utf8) else {
            return nil
        }

        do {
            let chart = try decoder.decode(ZiWeiChart.self, from: chartData)
            guard !chart.palaces.isEmpty else {
                return nil
            }
            return chart
        } catch {
            print("❌ Failed to decode chart: \(error)")
            return nil
        }
    }

    // 检查命盘数据是否已就绪
    var hasChart: Bool {
        return getChartOnly() != nil
    }

    // MARK: - Synastry Support

    /// Decode synastry info from JSON (stored in birthInfoJSON field for synastry readings)
    func getSynastryInfo() -> SynastryInfo? {
        guard let json = entity.birthInfoJSON,
              let data = json.data(using: .utf8) else {
            return nil
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(SynastryInfo.self, from: data)
    }

    /// Get synastry analysis text
    var synastryAnalysis: String? {
        guard isSynastry else { return nil }
        return entity.analysisText
    }
}

enum TaskStatus: String {
    case analyzing = "analyzing"
    case completed = "completed"
    case failed = "failed"
    case synastry = "synastry"
}
