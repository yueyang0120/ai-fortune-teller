import Foundation

enum Gender: String, Codable, CaseIterable {
    case male = "男"
    case female = "女"
}

enum CalendarType: String, Codable {
    case solar = "阳历"
    case lunar = "农历"
}

enum AnalysisTopic: String, Codable, CaseIterable {
    case overall = "全面分析"
    case career = "事业周期"
    case wealth = "财运分析"
    case love = "感情婚姻"
    case health = "健康状况"
    case yearFortune = "流年周期"
    case fiveElements = "五行分析"

    var description: String {
        switch self {
        case .overall: return "全方位解析命盘，包含性格、事业、财运、感情等。"
        case .career: return "专注分析职业发展、职场关系、升迁机会及适合行业。"
        case .wealth: return "专注分析正偏财运、理财能力、破财风险及致富机会。"
        case .love: return "专注分析恋爱婚姻、配偶特质、感情波折及桃花运。"
        case .health: return "专注分析先天体质、易患疾病及养生保健建议。"
        case .yearFortune: return "专注分析当年流年周期、吉凶祸福及关键事件。"
        case .fiveElements: return "专注分析五行强弱、喜用神及五行养生建议。"
        }
    }
}

struct LunarDate: Codable, Equatable {
    let year: Int
    let month: Int
    let day: Int
    let isLeapMonth: Bool

    var displayString: String {
        return LocalizationManager.shared.strings.formatLunarDate(year: year, month: month, day: day, isLeapMonth: isLeapMonth)
    }
}

struct BirthInfo: Codable, Equatable, Identifiable {
    let id: UUID
    let solarDate: Date
    let lunarDate: LunarDate?
    let birthTime: String // 时辰，例如 "子时"、"丑时" 等
    let birthHour: Int // 时（0-23）
    let birthMinute: Int // 分（0-59）
    let location: String
    let locationProvince: String // 省份
    let locationCity: String // 城市
    let longitude: Double
    let latitude: Double
    let gender: Gender
    let calendarType: CalendarType
    let useRealSolarTime: Bool // 是否使用真太阳时校正
    let analysisTopic: AnalysisTopic // 分析主题

    init(id: UUID = UUID(),
         solarDate: Date,
         lunarDate: LunarDate? = nil,
         birthTime: String,
         birthHour: Int,
         birthMinute: Int,
         location: String,
         locationProvince: String = "",
         locationCity: String = "",
         longitude: Double,
         latitude: Double,
         gender: Gender,
         calendarType: CalendarType = .solar,
         useRealSolarTime: Bool = true,
         analysisTopic: AnalysisTopic = .overall) {
        self.id = id
        self.solarDate = solarDate
        self.lunarDate = lunarDate
        self.birthTime = birthTime
        self.birthHour = birthHour
        self.birthMinute = birthMinute
        self.location = location
        self.locationProvince = locationProvince
        self.locationCity = locationCity
        self.longitude = longitude
        self.latitude = latitude
        self.gender = gender
        self.calendarType = calendarType
        self.useRealSolarTime = useRealSolarTime
        self.analysisTopic = analysisTopic
    }

    var displayDateString: String {
        return LocalizationManager.shared.strings.formatDate(solarDate)
    }

    var displayTimeString: String {
        return "\(localizedBirthTime) \(String(format: "%02d:%02d", birthHour, birthMinute))"
    }

    var fullDisplayString: String {
        let strings = LocalizationManager.shared.strings
        return "\(displayDateString) \(displayTimeString) \(location) [\(strings.categoryTitle(for: analysisTopic))]"
    }

    /// Localized birth time (e.g., "子时" or "Zi (23-01)")
    var localizedBirthTime: String {
        let hourIndex = ((birthHour + 1) / 2) % 12
        return LocalizationManager.shared.strings.chineseHourName(index: hourIndex)
    }
}

// 时辰对照表
extension BirthInfo {
    static let chineseHours = [
        "子时", "丑时", "寅时", "卯时", "辰时", "巳时",
        "午时", "未时", "申时", "酉时", "戌时", "亥时"
    ]

    static func getChineseHour(from hour: Int) -> String {
        // 23-1点: 子时, 1-3点: 丑时, ..., 21-23点: 亥时
        let index = ((hour + 1) / 2) % 12
        return chineseHours[index]
    }

    /// Returns localized Chinese hour name based on current language setting
    static func getLocalizedChineseHour(from hour: Int) -> String {
        let index = ((hour + 1) / 2) % 12
        return LocalizationManager.shared.strings.chineseHourName(index: index)
    }
}
