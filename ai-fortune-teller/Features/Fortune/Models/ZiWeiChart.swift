import Foundation

// MARK: - Star (星曜)
struct Star: Codable, Equatable, Identifiable {
    let id = UUID()
    let name: String // 星曜名称，如 "紫微"、"天机"、"太阳"
    let type: StarType
    let brightness: String? // 庙、旺、得、利、平、陷
    let fourTransform: FourTransformType? // 禄、权、科、忌

    enum StarType: String, Codable {
        case major = "主星" // 14主星
        case support = "辅星" // 六吉六煞等辅星
        case minor = "杂曜" // 其他小星
        case jiXing = "吉星"
        case shaXing = "煞星"
    }

    enum CodingKeys: String, CodingKey {
        case name, type, brightness, fourTransform
    }
}

// MARK: - Four Transform (四化)
enum FourTransformType: String, Codable {
    case lu = "禄" // 化禄
    case quan = "权" // 化权
    case ke = "科" // 化科
    case ji = "忌" // 化忌

    var color: String {
        switch self {
        case .lu: return "#10B981" // 绿色
        case .quan: return "#F59E0B" // 金色
        case .ke: return "#3B82F6" // 蓝色
        case .ji: return "#EF4444" // 红色
        }
    }
}

struct FourTransforms: Codable, Equatable {
    let luStar: String? // 化禄星
    let quanStar: String? // 化权星
    let keStar: String? // 化科星
    let jiStar: String? // 化忌星
}

// MARK: - Self Mutation (自化)
struct SelfMutation: Codable, Equatable {
    let type: FourTransformType // 禄、权、科、忌
    let star: String? // 自化的星曜名称 (可选，因为有些自化可能只论四化不论星)
}

// MARK: - Flying Star (飞星)
struct FlyingStar: Codable, Equatable {
    let type: FourTransformType // 禄、权、科、忌
    let toPalaceName: String // 飞入的宫位名称 (如 "夫妻宫")
    let toPalacePosition: Int // 飞入的宫位索引
    let star: String // 引发飞星的星曜 (如 "廉贞")
}

// MARK: - Palace (宫位)
struct Palace: Codable, Equatable, Identifiable {
    let id = UUID()
    let name: PalaceName
    let earthlyBranch: String // 地支，如 "子"、"丑"、"寅"
    let heavenlyStem: String? // 天干，如 "甲"、"乙"、"丙"
    let stars: [Star] // 该宫的所有星曜
    let position: Int // 宫位位置 (0-11)
    let isBodyPalace: Bool // 是否为身宫
    let majorLimit: String? // 大限年龄范围，如 "6-15岁"
    let relationships: PalaceRelationships? // 三方四正关系 (可选)

    // 新增字段
    let changsheng12: String? // 长生十二神
    let boshi12: String? // 博士十二神
    let selfMutations: [SelfMutation]? // 自化信息
    let flyingStars: [FlyingStar]? // 飞星信息 (宫干飞化)

    enum CodingKeys: String, CodingKey {
        case name, earthlyBranch, heavenlyStem, stars, position, isBodyPalace, majorLimit, relationships
        case changsheng12, boshi12, selfMutations, flyingStars
    }
}

// MARK: - Palace Relationships
struct PalaceRelationships: Codable, Equatable {
    let oppositeIndex: Int // 对宫索引
    let wealthIndex: Int // 财帛位索引
    let careerIndex: Int // 官禄位索引
    // names mainly for reference
    let oppositeName: String?
    let wealthName: String?
    let careerName: String?
}

// MARK: - Palace Name (宫位名称)
enum PalaceName: String, Codable, CaseIterable {
    case ming = "命宫"
    case xiongdi = "兄弟宫"
    case fuqi = "夫妻宫"
    case zinv = "子女宫"
    case caibo = "财帛宫"
    case jie = "疾厄宫"
    case qianyi = "迁移宫"
    case jiaoyou = "交友宫"
    case guanlu = "官禄宫"
    case tianzhai = "田宅宫"
    case fumu = "父母宫"
    case fude = "福德宫"

    var shortName: String {
        return String(self.rawValue.prefix(2))
    }

    var localizedName: String {
        // Check if LocalizationManager is available, otherwise fallback to rawValue
        // Since this is a model file, referencing singleton is acceptable
        switch LocalizationManager.shared.currentLanguage {
        case .english:
            switch self {
            case .ming: return "Life"
            case .xiongdi: return "Brothers"
            case .fuqi: return "Spouse"
            case .zinv: return "Children"
            case .caibo: return "Wealth"
            case .jie: return "Health"
            case .qianyi: return "Travel"
            case .jiaoyou: return "Friends"
            case .guanlu: return "Career"
            case .tianzhai: return "Property"
            case .fude: return "Mental"
            case .fumu: return "Parents"
            }
        case .traditionalChinese:
            switch self {
            case .ming: return "命宮"
            case .xiongdi: return "兄弟宮"
            case .fuqi: return "夫妻宮"
            case .zinv: return "子女宮"
            case .caibo: return "財帛宮"
            case .jie: return "疾厄宮"
            case .qianyi: return "遷移宮"
            case .jiaoyou: return "交友宮"
            case .guanlu: return "官祿宮"
            case .tianzhai: return "田宅宮"
            case .fude: return "福德宮"
            case .fumu: return "父母宮"
            }
        case .simplifiedChinese:
            return self.rawValue
        }
    }

    var shortLocalizedName: String {
        switch LocalizationManager.shared.currentLanguage {
        case .english:
            switch self {
            case .ming: return "Life"
            case .xiongdi: return "Bros"
            case .fuqi: return "Wife"
            case .zinv: return "Kids"
            case .caibo: return "Weal"
            case .jie: return "Hlth"
            case .qianyi: return "Trvl"
            case .jiaoyou: return "Frds"
            case .guanlu: return "Job"
            case .tianzhai: return "Home"
            case .fude: return "Ment"
            case .fumu: return "Prnt"
            }
        case .traditionalChinese:
             return String(localizedName.prefix(2))
        case .simplifiedChinese:
             return String(rawValue.prefix(2))
        }
    }

    var description: String {
        switch self {
        case .ming: return "主个性、思想、外貌、人生态度"
        case .xiongdi: return "兄弟姐妹关系、同事关系"
        case .fuqi: return "婚姻、配偶、恋爱对象"
        case .zinv: return "子女、学生、下属"
        case .caibo: return "财运、理财能力、收入"
        case .jie: return "健康、疾病、体质"
        case .qianyi: return "外出运、变动、贵人"
        case .jiaoyou: return "朋友、人际关系、社交"
        case .guanlu: return "事业、工作、成就"
        case .tianzhai: return "家庭、不动产、居住"
        case .fumu: return "父母、长辈、上司"
        case .fude: return "精神享受、兴趣爱好、福气"
        }
    }
}

// MARK: - Major Limit (大限)
struct MajorLimit: Codable, Equatable, Identifiable {
    let id = UUID()
    let startAge: Int
    let endAge: Int
    let palace: PalaceName
    let earthlyBranch: String

    var ageRange: String {
        return LocalizationManager.shared.strings.ageRange(start: startAge, end: endAge)
    }

    enum CodingKeys: String, CodingKey {
        case startAge, endAge, palace, earthlyBranch
    }
}

// MARK: - Year Fortune (流年)
struct YearFortune: Codable, Equatable, Identifiable {
    let id = UUID()
    let age: Int
    let year: Int
    let palace: PalaceName
    let earthlyBranch: String
    let stars: [String]? // 流年星曜 (如流羊、流陀等)

    enum CodingKeys: String, CodingKey {
        case age, year, palace, earthlyBranch, stars
    }
}

// MARK: - Zi Wei Chart (紫微命盘)
struct ZiWeiChart: Codable, Equatable, Identifiable {
    let id: UUID
    let palaces: [Palace] // 12宫
    let birthYear: String // 年柱，如 "乙亥年"
    let fiveElementBureau: String // 五行局，如 "火六局"
    let bodyMaster: String // 身主
    let lifeMaster: String // 命主
    let mingPalace: PalaceName // 命宫所在位置
    let bodyPalace: PalaceName // 身宫所在位置
    let fourTransforms: FourTransforms // 生年四化
    let majorLimits: [MajorLimit] // 大限（通常12个）
    let yearFortunes: [YearFortune]? // 流年信息（可选）
    let rawJSONData: String? // 原始JSON数据（从iztro返回）

    init(id: UUID = UUID(),
         palaces: [Palace],
         birthYear: String,
         fiveElementBureau: String,
         bodyMaster: String,
         lifeMaster: String,
         mingPalace: PalaceName,
         bodyPalace: PalaceName,
         fourTransforms: FourTransforms,
         majorLimits: [MajorLimit],
         yearFortunes: [YearFortune]? = nil,
         rawJSONData: String? = nil) {
        self.id = id
        self.palaces = palaces
        self.birthYear = birthYear
        self.fiveElementBureau = fiveElementBureau
        self.bodyMaster = bodyMaster
        self.lifeMaster = lifeMaster
        self.mingPalace = mingPalace
        self.bodyPalace = bodyPalace
        self.fourTransforms = fourTransforms
        self.majorLimits = majorLimits
        self.yearFortunes = yearFortunes
        self.rawJSONData = rawJSONData
    }

    // 获取指定宫位
    func palace(named name: PalaceName) -> Palace? {
        return palaces.first { $0.name == name }
    }

    // 获取命宫
    var lifePalace: Palace? {
        return palace(named: mingPalace)
    }

    // 获取身宫
    var bodyPalaceObj: Palace? {
        return palace(named: bodyPalace)
    }
}
