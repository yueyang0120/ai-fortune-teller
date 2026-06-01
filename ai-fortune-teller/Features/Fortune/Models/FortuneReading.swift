import Foundation

struct FortuneReading: Codable, Equatable, Identifiable {
    let id: UUID
    let birthInfo: BirthInfo
    let chart: ZiWeiChart
    let analysis: String // Markdown格式的分析文本
    let timestamp: Date

    init(id: UUID = UUID(),
         birthInfo: BirthInfo,
         chart: ZiWeiChart,
         analysis: String,
         timestamp: Date = Date()) {
        self.id = id
        self.birthInfo = birthInfo
        self.chart = chart
        self.analysis = analysis
        self.timestamp = timestamp
    }

    var displayDateString: String {
        return LocalizationManager.shared.strings.formatTimestamp(timestamp)
    }

    var shortDescription: String {
        let dateStr = birthInfo.displayDateString
        let timeStr = birthInfo.localizedBirthTime
        let genderStr = birthInfo.gender == .male ? LocalizationManager.shared.strings.male : LocalizationManager.shared.strings.female
        return "\(dateStr) \(timeStr) - \(genderStr)"
    }

    // 将 reading 转换为 JSON 字符串（用于存储到 CoreData）
    func toJSONString() throws -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(self)
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw FortuneReadingError.encodingFailed
        }
        return jsonString
    }

    // 从 JSON 字符串创建 reading
    static func fromJSONString(_ jsonString: String) throws -> FortuneReading {
        guard let data = jsonString.data(using: .utf8) else {
            throw FortuneReadingError.decodingFailed
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(FortuneReading.self, from: data)
    }
}

enum FortuneReadingError: Error, LocalizedError {
    case encodingFailed
    case decodingFailed
    case invalidData

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "无法编码排盘数据"
        case .decodingFailed:
            return "无法解码排盘数据"
        case .invalidData:
            return "数据格式无效"
        }
    }
}
