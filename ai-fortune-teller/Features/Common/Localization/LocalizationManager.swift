import Foundation
import SwiftUI

// MARK: - Language Enum
/// 语言选择 - 使用中性命名，避免政治敏感
enum AppLanguage: String, CaseIterable, Codable {
    case simplifiedChinese = "zh-Hans"   // 简体中文
    case traditionalChinese = "zh-Hant"  // 繁體中文
    case english = "en"                   // English

    var displayName: String {
        switch self {
        case .simplifiedChinese: return "简体中文"
        case .traditionalChinese: return "繁體中文"
        case .english: return "English"
        }
    }

    var nativeDisplayName: String {
        switch self {
        case .simplifiedChinese: return "简体中文"
        case .traditionalChinese: return "繁體中文"
        case .english: return "English"
        }
    }

    /// 用于 iztro 库的语言代码
    var iztroLanguageCode: String {
        switch self {
        case .simplifiedChinese: return "zh-CN"
        case .traditionalChinese: return "zh-TW"
        case .english: return "en-US"
        }
    }
}

// MARK: - Localization Manager
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    @Published var currentLanguage: AppLanguage = .simplifiedChinese
    @Published var hasSelectedLanguage: Bool = false

    private let languageKey = "app_language"
    private let hasSelectedLanguageKey = "has_selected_language"

    private init() {
        loadLanguageSettings()
    }

    private func loadLanguageSettings() {
        hasSelectedLanguage = UserDefaults.standard.bool(forKey: hasSelectedLanguageKey)

        if let savedLang = UserDefaults.standard.string(forKey: languageKey),
           let language = AppLanguage(rawValue: savedLang) {
            currentLanguage = language
        } else {
            // 根据系统语言自动选择默认语言
            currentLanguage = detectSystemLanguage()
        }
    }

    private func detectSystemLanguage() -> AppLanguage {
        // 默认使用简体中文
        return .simplifiedChinese
    }

    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
        hasSelectedLanguage = true
        UserDefaults.standard.set(language.rawValue, forKey: languageKey)
        UserDefaults.standard.set(true, forKey: hasSelectedLanguageKey)
    }

    // MARK: - Localized Strings Access
    var strings: LocalizedStrings {
        LocalizedStrings(language: currentLanguage)
    }
}

// MARK: - Localized Strings
struct LocalizedStrings {
    let language: AppLanguage

    // MARK: - Common
    var back: String {
        switch language {
        case .simplifiedChinese: return "返回"
        case .traditionalChinese: return "返回"
        case .english: return "Back"
        }
    }

    var done: String {
        switch language {
        case .simplifiedChinese: return "完成"
        case .traditionalChinese: return "完成"
        case .english: return "Done"
        }
    }

    var cancel: String {
        switch language {
        case .simplifiedChinese: return "取消"
        case .traditionalChinese: return "取消"
        case .english: return "Cancel"
        }
    }

    var confirm: String {
        switch language {
        case .simplifiedChinese: return "确定"
        case .traditionalChinese: return "確定"
        case .english: return "Confirm"
        }
    }

    var delete: String {
        switch language {
        case .simplifiedChinese: return "删除"
        case .traditionalChinese: return "刪除"
        case .english: return "Delete"
        }
    }

    var retry: String {
        switch language {
        case .simplifiedChinese: return "重试"
        case .traditionalChinese: return "重試"
        case .english: return "Retry"
        }
    }

    var error: String {
        switch language {
        case .simplifiedChinese: return "错误"
        case .traditionalChinese: return "錯誤"
        case .english: return "Error"
        }
    }

    var unknownError: String {
        switch language {
        case .simplifiedChinese: return "未知错误"
        case .traditionalChinese: return "未知錯誤"
        case .english: return "Unknown error"
        }
    }

    var loading: String {
        switch language {
        case .simplifiedChinese: return "加载中..."
        case .traditionalChinese: return "載入中..."
        case .english: return "Loading..."
        }
    }

    // MARK: - Language Selection
    var welcomeTitle: String {
        switch language {
        case .simplifiedChinese: return "紫微天命"
        case .traditionalChinese: return "紫微天命"
        case .english: return "Ziwei Lab"
        }
    }

    var selectLanguage: String {
        switch language {
        case .simplifiedChinese: return "选择语言"
        case .traditionalChinese: return "選擇語言"
        case .english: return "Select Language"
        }
    }

    var selectLanguageHint: String {
        switch language {
        case .simplifiedChinese: return "请选择您偏好的语言"
        case .traditionalChinese: return "請選擇您偏好的語言"
        case .english: return "Please select your preferred language"
        }
    }

    var continueButton: String {
        switch language {
        case .simplifiedChinese: return "继续"
        case .traditionalChinese: return "繼續"
        case .english: return "Continue"
        }
    }

    // MARK: - Home Screen
    var appTitle: String {
        switch language {
        case .simplifiedChinese: return "紫微天命"
        case .traditionalChinese: return "紫微天命"
        case .english: return "Ziwei Lab"
        }
    }

    var appLogo: String {
        switch language {
        case .simplifiedChinese: return "紫微"
        case .traditionalChinese: return "紫微"
        case .english: return "紫微"
        }
    }

    var swipeHint: String {
        switch language {
        case .simplifiedChinese: return "左右滑动选择功能"
        case .traditionalChinese: return "左右滑動選擇功能"
        case .english: return "Swipe to select"
        }
    }

    var tapToEnter: String {
        switch language {
        case .simplifiedChinese: return "点击进入"
        case .traditionalChinese: return "點擊進入"
        case .english: return "Tap to enter"
        }
    }

    var motto: String {
        switch language {
        case .simplifiedChinese: return "命由己造"
        case .traditionalChinese: return "命由己造"
        case .english: return "Fate is in your hands"
        }
    }

    // Card titles
    var historyCardTitle: String {
        switch language {
        case .simplifiedChinese: return "历史记录"
        case .traditionalChinese: return "歷史記錄"
        case .english: return "History"
        }
    }

    var historyCardSubtitle: String {
        switch language {
        case .simplifiedChinese: return "查看过往测算"
        case .traditionalChinese: return "查看過去的測算"
        case .english: return "View past readings"
        }
    }

    var readingCardTitle: String {
        switch language {
        case .simplifiedChinese: return "开始测算"
        case .traditionalChinese: return "開始測算"
        case .english: return "Start Reading"
        }
    }

    var readingCardSubtitle: String {
        switch language {
        case .simplifiedChinese: return "探索你的命盘"
        case .traditionalChinese: return "探索你的命盤"
        case .english: return "Explore your chart"
        }
    }

    var settingsCardTitle: String {
        switch language {
        case .simplifiedChinese: return "个人设置"
        case .traditionalChinese: return "個人設定"
        case .english: return "Settings"
        }
    }

    var settingsCardSubtitle: String {
        switch language {
        case .simplifiedChinese: return "自定义偏好"
        case .traditionalChinese: return "自訂偏好"
        case .english: return "Customize preferences"
        }
    }

    // MARK: - Category Selection
    var selectCategory: String {
        switch language {
        case .simplifiedChinese: return "选择测算项目"
        case .traditionalChinese: return "選擇測算項目"
        case .english: return "Select Category"
        }
    }

    var selectCategoryHint: String {
        switch language {
        case .simplifiedChinese: return "多角度命盘分析"
        case .traditionalChinese: return "多角度命盤分析"
        case .english: return "Multi-dimensional chart analysis"
        }
    }

    func categoryTitle(for topic: AnalysisTopic) -> String {
        switch topic {
        case .overall:
            switch language {
            case .simplifiedChinese: return "综合测算"
            case .traditionalChinese: return "綜合測算"
            case .english: return "Overall Reading"
            }
        case .love:
            switch language {
            case .simplifiedChinese: return "感情姻缘"
            case .traditionalChinese: return "感情姻緣"
            case .english: return "Love & Marriage"
            }
        case .career:
            switch language {
            case .simplifiedChinese: return "事业发展"
            case .traditionalChinese: return "事業發展"
            case .english: return "Career Prospects"
            }
        case .wealth:
            switch language {
            case .simplifiedChinese: return "财运分析"
            case .traditionalChinese: return "財運分析"
            case .english: return "Wealth Analysis"
            }
        case .health:
            switch language {
            case .simplifiedChinese: return "健康运势"
            case .traditionalChinese: return "健康運勢"
            case .english: return "Health Outlook"
            }
        case .yearFortune:
            switch language {
            case .simplifiedChinese: return "流年运势"
            case .traditionalChinese: return "流年運勢"
            case .english: return "Annual Fortune"
            }
        case .fiveElements:
            switch language {
            case .simplifiedChinese: return "八字五行"
            case .traditionalChinese: return "八字五行"
            case .english: return "Ba Zi Five Elements"
            }
        }
    }

    func categoryDescription(for topic: AnalysisTopic) -> String {
        switch topic {
        case .overall:
            switch language {
            case .simplifiedChinese: return "性格、事业、财运、感情全面分析"
            case .traditionalChinese: return "性格、事業、財運、感情全面分析"
            case .english: return "Personality, career, wealth & love"
            }
        case .love:
            switch language {
            case .simplifiedChinese: return "姻缘桃花运势"
            case .traditionalChinese: return "姻緣桃花運勢"
            case .english: return "Romance & relationships"
            }
        case .career:
            switch language {
            case .simplifiedChinese: return "职场发展前景"
            case .traditionalChinese: return "職場發展前景"
            case .english: return "Career prospects"
            }
        case .wealth:
            switch language {
            case .simplifiedChinese: return "财富进出趋势"
            case .traditionalChinese: return "財富進出趨勢"
            case .english: return "Financial prospects"
            }
        case .health:
            switch language {
            case .simplifiedChinese: return "身心健康状态"
            case .traditionalChinese: return "身心健康狀態"
            case .english: return "Health & wellness"
            }
        case .yearFortune:
            switch language {
            case .simplifiedChinese: return "今年运势走向"
            case .traditionalChinese: return "今年運勢走向"
            case .english: return "This year's fortune trends"
            }
        case .fiveElements:
            switch language {
            case .simplifiedChinese: return "四柱八字、天干地支与喜用神"
            case .traditionalChinese: return "四柱八字、天干地支與喜用神"
            case .english: return "Four Pillars, Heavenly Stems & Earthly Branches"
            }
        }
    }

    // MARK: - Synastry (合盘)

    var synastrySelectionTitle: String {
        switch language {
        case .simplifiedChinese: return "选择合盘类型"
        case .traditionalChinese: return "選擇合盤類型"
        case .english: return "Select Synastry Type"
        }
    }

    var synastrySelectionHint: String {
        switch language {
        case .simplifiedChinese: return "两人命盘深度对比分析"
        case .traditionalChinese: return "兩人命盤深度對比分析"
        case .english: return "Deep comparison of two charts"
        }
    }

    func synastryTitle(for type: SynastryType) -> String {
        switch type {
        case .love:
            switch language {
            case .simplifiedChinese: return "爱情合盘"
            case .traditionalChinese: return "愛情合盤"
            case .english: return "Love Synastry"
            }
        case .parentChild:
            switch language {
            case .simplifiedChinese: return "亲子合盘"
            case .traditionalChinese: return "親子合盤"
            case .english: return "Parent-Child Synastry"
            }
        case .pet:
            switch language {
            case .simplifiedChinese: return "宠物合盘"
            case .traditionalChinese: return "寵物合盤"
            case .english: return "Pet Synastry"
            }
        case .siblings:
            switch language {
            case .simplifiedChinese: return "手足合盘"
            case .traditionalChinese: return "手足合盤"
            case .english: return "Siblings Synastry"
            }
        case .friends:
            switch language {
            case .simplifiedChinese: return "朋友合盘"
            case .traditionalChinese: return "朋友合盤"
            case .english: return "Friends Synastry"
            }
        case .business:
            switch language {
            case .simplifiedChinese: return "合伙合盘"
            case .traditionalChinese: return "合夥合盤"
            case .english: return "Business Partnership"
            }
        }
    }

    func synastryDescription(for type: SynastryType) -> String {
        switch type {
        case .love:
            switch language {
            case .simplifiedChinese: return "两人的爱情缘分深度解读"
            case .traditionalChinese: return "兩人的愛情緣分深度解讀"
            case .english: return "Love compatibility analysis"
            }
        case .parentChild:
            switch language {
            case .simplifiedChinese: return "亲子关系与教育互动分析"
            case .traditionalChinese: return "親子關係與教育互動分析"
            case .english: return "Parent-child relationship analysis"
            }
        case .pet:
            switch language {
            case .simplifiedChinese: return "你与毛孩子的缘分解读"
            case .traditionalChinese: return "你與毛孩子的緣分解讀"
            case .english: return "Bond with your furry friend"
            }
        case .siblings:
            switch language {
            case .simplifiedChinese: return "兄弟姐妹关系与互动模式"
            case .traditionalChinese: return "兄弟姊妹關係與互動模式"
            case .english: return "Sibling dynamics analysis"
            }
        case .friends:
            switch language {
            case .simplifiedChinese: return "朋友间的情感联结与默契"
            case .traditionalChinese: return "朋友間的情感聯結與默契"
            case .english: return "Friendship bond analysis"
            }
        case .business:
            switch language {
            case .simplifiedChinese: return "合伙人的互补与合作潜力"
            case .traditionalChinese: return "合夥人的互補與合作潛力"
            case .english: return "Business partnership potential"
            }
        }
    }

    var synastryPersonA: String {
        switch language {
        case .simplifiedChinese: return "第一位"
        case .traditionalChinese: return "第一位"
        case .english: return "First Person"
        }
    }

    var synastryPersonB: String {
        switch language {
        case .simplifiedChinese: return "第二位"
        case .traditionalChinese: return "第二位"
        case .english: return "Second Person"
        }
    }

    var synastryPetOwner: String {
        switch language {
        case .simplifiedChinese: return "主人信息"
        case .traditionalChinese: return "主人資訊"
        case .english: return "Owner's Info"
        }
    }

    var synastryPetAnimal: String {
        switch language {
        case .simplifiedChinese: return "宠物信息"
        case .traditionalChinese: return "寵物資訊"
        case .english: return "Pet's Info"
        }
    }

    var synastryStepA: String {
        switch language {
        case .simplifiedChinese: return "请输入第一位的出生信息"
        case .traditionalChinese: return "請輸入第一位的出生資訊"
        case .english: return "Enter first person's birth info"
        }
    }

    var synastryStepB: String {
        switch language {
        case .simplifiedChinese: return "请输入第二位的出生信息"
        case .traditionalChinese: return "請輸入第二位的出生資訊"
        case .english: return "Enter second person's birth info"
        }
    }

    var synastrySelectFromProfiles: String {
        switch language {
        case .simplifiedChinese: return "从已有档案选择"
        case .traditionalChinese: return "從已有檔案選擇"
        case .english: return "Select from profiles"
        }
    }

    var synastryEnterNewInfo: String {
        switch language {
        case .simplifiedChinese: return "输入新的出生信息"
        case .traditionalChinese: return "輸入新的出生資訊"
        case .english: return "Enter new birth info"
        }
    }

    var synastryNextStep: String {
        switch language {
        case .simplifiedChinese: return "下一步"
        case .traditionalChinese: return "下一步"
        case .english: return "Next Step"
        }
    }

    var synastryStartAnalysis: String {
        switch language {
        case .simplifiedChinese: return "开始合盘分析"
        case .traditionalChinese: return "開始合盤分析"
        case .english: return "Start Synastry Analysis"
        }
    }

    var synastryResultSubtitle: String {
        switch language {
        case .simplifiedChinese: return "双盘对比分析结果"
        case .traditionalChinese: return "雙盤對比分析結果"
        case .english: return "Dual chart comparison results"
        }
    }

    var synastryMingPalace: String {
        switch language {
        case .simplifiedChinese: return "命宫"
        case .traditionalChinese: return "命宮"
        case .english: return "Life Palace"
        }
    }

    var synastryCardTitle: String {
        switch language {
        case .simplifiedChinese: return "合盘分析"
        case .traditionalChinese: return "合盤分析"
        case .english: return "Synastry"
        }
    }

    var synastrySection: String {
        switch language {
        case .simplifiedChinese: return "双人合盘"
        case .traditionalChinese: return "雙人合盤"
        case .english: return "Two-Person Synastry"
        }
    }

    var personalSection: String {
        switch language {
        case .simplifiedChinese: return "个人分析"
        case .traditionalChinese: return "個人分析"
        case .english: return "Personal Analysis"
        }
    }

    var newBadge: String {
        switch language {
        case .simplifiedChinese: return "新"
        case .traditionalChinese: return "新"
        case .english: return "New"
        }
    }

    var synastryCardSubtitle: String {
        switch language {
        case .simplifiedChinese: return "两人命盘对比"
        case .traditionalChinese: return "兩人命盤對比"
        case .english: return "Compare two charts"
        }
    }

    // MARK: - Relationship Role Selection

    var synastrySelectRole: String {
        switch language {
        case .simplifiedChinese: return "请选择具体关系"
        case .traditionalChinese: return "請選擇具體關係"
        case .english: return "Select relationship"
        }
    }

    func roleTitle(for role: RelationshipRole) -> String {
        switch role {
        case .fatherSon:
            switch language {
            case .simplifiedChinese: return "父子"
            case .traditionalChinese: return "父子"
            case .english: return "Father & Son"
            }
        case .fatherDaughter:
            switch language {
            case .simplifiedChinese: return "父女"
            case .traditionalChinese: return "父女"
            case .english: return "Father & Daughter"
            }
        case .motherSon:
            switch language {
            case .simplifiedChinese: return "母子"
            case .traditionalChinese: return "母子"
            case .english: return "Mother & Son"
            }
        case .motherDaughter:
            switch language {
            case .simplifiedChinese: return "母女"
            case .traditionalChinese: return "母女"
            case .english: return "Mother & Daughter"
            }
        case .brothers:
            switch language {
            case .simplifiedChinese: return "兄弟"
            case .traditionalChinese: return "兄弟"
            case .english: return "Brothers"
            }
        case .sisters:
            switch language {
            case .simplifiedChinese: return "姐妹"
            case .traditionalChinese: return "姊妹"
            case .english: return "Sisters"
            }
        case .olderBrotherYoungerSister:
            switch language {
            case .simplifiedChinese: return "兄妹"
            case .traditionalChinese: return "兄妹"
            case .english: return "Brother & Sister"
            }
        case .olderSisterYoungerBrother:
            switch language {
            case .simplifiedChinese: return "姐弟"
            case .traditionalChinese: return "姊弟"
            case .english: return "Sister & Brother"
            }
        }
    }

    func roleDescription(for role: RelationshipRole) -> String {
        switch role {
        case .fatherSon:
            switch language {
            case .simplifiedChinese: return "先输入父亲，再输入儿子"
            case .traditionalChinese: return "先輸入父親，再輸入兒子"
            case .english: return "Enter father first, then son"
            }
        case .fatherDaughter:
            switch language {
            case .simplifiedChinese: return "先输入父亲，再输入女儿"
            case .traditionalChinese: return "先輸入父親，再輸入女兒"
            case .english: return "Enter father first, then daughter"
            }
        case .motherSon:
            switch language {
            case .simplifiedChinese: return "先输入母亲，再输入儿子"
            case .traditionalChinese: return "先輸入母親，再輸入兒子"
            case .english: return "Enter mother first, then son"
            }
        case .motherDaughter:
            switch language {
            case .simplifiedChinese: return "先输入母亲，再输入女儿"
            case .traditionalChinese: return "先輸入母親，再輸入女兒"
            case .english: return "Enter mother first, then daughter"
            }
        case .brothers:
            switch language {
            case .simplifiedChinese: return "先输入兄长，再输入弟弟"
            case .traditionalChinese: return "先輸入兄長，再輸入弟弟"
            case .english: return "Enter older brother first, then younger"
            }
        case .sisters:
            switch language {
            case .simplifiedChinese: return "先输入姐姐，再输入妹妹"
            case .traditionalChinese: return "先輸入姊姊，再輸入妹妹"
            case .english: return "Enter older sister first, then younger"
            }
        case .olderBrotherYoungerSister:
            switch language {
            case .simplifiedChinese: return "先输入哥哥，再输入妹妹"
            case .traditionalChinese: return "先輸入哥哥，再輸入妹妹"
            case .english: return "Enter older brother first, then younger sister"
            }
        case .olderSisterYoungerBrother:
            switch language {
            case .simplifiedChinese: return "先输入姐姐，再输入弟弟"
            case .traditionalChinese: return "先輸入姊姊，再輸入弟弟"
            case .english: return "Enter older sister first, then younger brother"
            }
        }
    }

    func rolePersonALabel(for role: RelationshipRole) -> String {
        switch role {
        case .fatherSon, .fatherDaughter:
            switch language {
            case .simplifiedChinese: return "父亲信息"
            case .traditionalChinese: return "父親資訊"
            case .english: return "Father's Info"
            }
        case .motherSon, .motherDaughter:
            switch language {
            case .simplifiedChinese: return "母亲信息"
            case .traditionalChinese: return "母親資訊"
            case .english: return "Mother's Info"
            }
        case .brothers, .olderBrotherYoungerSister:
            switch language {
            case .simplifiedChinese: return "兄长信息"
            case .traditionalChinese: return "兄長資訊"
            case .english: return "Older Brother's Info"
            }
        case .sisters, .olderSisterYoungerBrother:
            switch language {
            case .simplifiedChinese: return "姐姐信息"
            case .traditionalChinese: return "姊姊資訊"
            case .english: return "Older Sister's Info"
            }
        }
    }

    func rolePersonBLabel(for role: RelationshipRole) -> String {
        switch role {
        case .fatherSon, .motherSon:
            switch language {
            case .simplifiedChinese: return "儿子信息"
            case .traditionalChinese: return "兒子資訊"
            case .english: return "Son's Info"
            }
        case .fatherDaughter, .motherDaughter:
            switch language {
            case .simplifiedChinese: return "女儿信息"
            case .traditionalChinese: return "女兒資訊"
            case .english: return "Daughter's Info"
            }
        case .brothers, .olderSisterYoungerBrother:
            switch language {
            case .simplifiedChinese: return "弟弟信息"
            case .traditionalChinese: return "弟弟資訊"
            case .english: return "Younger Brother's Info"
            }
        case .sisters, .olderBrotherYoungerSister:
            switch language {
            case .simplifiedChinese: return "妹妹信息"
            case .traditionalChinese: return "妹妹資訊"
            case .english: return "Younger Sister's Info"
            }
        }
    }

    // MARK: - Birth Info Form
    var fillBirthInfo: String {
        switch language {
        case .simplifiedChinese: return "请填写出生信息"
        case .traditionalChinese: return "請填寫出生資訊"
        case .english: return "Please enter birth info"
        }
    }

    var gender: String {
        switch language {
        case .simplifiedChinese: return "性别"
        case .traditionalChinese: return "性別"
        case .english: return "Gender"
        }
    }

    var male: String {
        switch language {
        case .simplifiedChinese: return "乾造 (男)"
        case .traditionalChinese: return "乾造 (男)"
        case .english: return "Male"
        }
    }

    var female: String {
        switch language {
        case .simplifiedChinese: return "坤造 (女)"
        case .traditionalChinese: return "坤造 (女)"
        case .english: return "Female"
        }
    }

    var maleShort: String {
        switch language {
        case .simplifiedChinese: return "男"
        case .traditionalChinese: return "男"
        case .english: return "Male"
        }
    }

    var femaleShort: String {
        switch language {
        case .simplifiedChinese: return "女"
        case .traditionalChinese: return "女"
        case .english: return "Female"
        }
    }

    var birthDate: String {
        switch language {
        case .simplifiedChinese: return "出生日期"
        case .traditionalChinese: return "出生日期"
        case .english: return "Birth Date"
        }
    }

    var solarCalendar: String {
        switch language {
        case .simplifiedChinese: return "公历"
        case .traditionalChinese: return "國曆"
        case .english: return "Solar"
        }
    }

    var lunarCalendar: String {
        switch language {
        case .simplifiedChinese: return "农历"
        case .traditionalChinese: return "農曆"
        case .english: return "Lunar"
        }
    }

    var leapMonth: String {
        switch language {
        case .simplifiedChinese: return "闰月"
        case .traditionalChinese: return "閏月"
        case .english: return "Leap Month"
        }
    }

    var year: String {
        switch language {
        case .simplifiedChinese: return "年"
        case .traditionalChinese: return "年"
        case .english: return ""
        }
    }

    var month: String {
        switch language {
        case .simplifiedChinese: return "月"
        case .traditionalChinese: return "月"
        case .english: return ""
        }
    }

    var day: String {
        switch language {
        case .simplifiedChinese: return "日"
        case .traditionalChinese: return "日"
        case .english: return ""
        }
    }

    var birthTime: String {
        switch language {
        case .simplifiedChinese: return "出生时辰"
        case .traditionalChinese: return "出生時辰"
        case .english: return "Birth Time"
        }
    }

    var exactTime: String {
        switch language {
        case .simplifiedChinese: return "精确时间"
        case .traditionalChinese: return "精確時間"
        case .english: return "Exact Time"
        }
    }

    var shichenTime: String {
        switch language {
        case .simplifiedChinese: return "时辰选择"
        case .traditionalChinese: return "時辰選擇"
        case .english: return "Chinese Hour"
        }
    }

    var hour: String {
        switch language {
        case .simplifiedChinese: return "时"
        case .traditionalChinese: return "時"
        case .english: return ""
        }
    }

    var minute: String {
        switch language {
        case .simplifiedChinese: return "分"
        case .traditionalChinese: return "分"
        case .english: return ""
        }
    }

    var timeHint: String {
        switch language {
        case .simplifiedChinese: return "支持选择时辰或精确到分钟的出生时间"
        case .traditionalChinese: return "支援選擇時辰或精確到分鐘的出生時間"
        case .english: return "Select Chinese hour or exact time"
        }
    }

    var birthPlace: String {
        switch language {
        case .simplifiedChinese: return "出生地点"
        case .traditionalChinese: return "出生地點"
        case .english: return "Birth Place"
        }
    }

    var locationHint: String {
        switch language {
        case .simplifiedChinese: return "支持城市查找、手动输入"
        case .traditionalChinese: return "支援城市查找、手動輸入"
        case .english: return "Search cities or enter manually"
        }
    }

    var enableTrueSolarTime: String {
        switch language {
        case .simplifiedChinese: return "启用真太阳时"
        case .traditionalChinese: return "啟用真太陽時"
        case .english: return "True Solar Time"
        }
    }

    var trueSolarTimeHint: String {
        switch language {
        case .simplifiedChinese: return "根据出生地经度调整时辰"
        case .traditionalChinese: return "根據出生地經度調整時辰"
        case .english: return "Adjust time by longitude"
        }
    }

    var trueSolarTimeWillBeCalculated: String {
        switch language {
        case .simplifiedChinese: return "真太阳时将在转换公历后计算"
        case .traditionalChinese: return "真太陽時將在轉換國曆後計算"
        case .english: return "True solar time will be calculated after conversion"
        }
    }

    var startReading: String {
        switch language {
        case .simplifiedChinese: return "开始测算"
        case .traditionalChinese: return "開始測算"
        case .english: return "Start Reading"
        }
    }

    // MARK: - Location Picker
    var selectLocation: String {
        switch language {
        case .simplifiedChinese: return "选择地点"
        case .traditionalChinese: return "選擇地點"
        case .english: return "Select Location"
        }
    }

    var selectInputMethod: String {
        switch language {
        case .simplifiedChinese: return "选择输入方式"
        case .traditionalChinese: return "選擇輸入方式"
        case .english: return "Input Method"
        }
    }

    var commonCities: String {
        switch language {
        case .simplifiedChinese: return "常用城市"
        case .traditionalChinese: return "常用城市"
        case .english: return "Common Cities"
        }
    }

    var provinceCitySelection: String {
        switch language {
        case .simplifiedChinese: return "地区选择"
        case .traditionalChinese: return "地區選擇"
        case .english: return "Region Selection"
        }
    }

    var manualInput: String {
        switch language {
        case .simplifiedChinese: return "手动输入"
        case .traditionalChinese: return "手動輸入"
        case .english: return "Manual Input"
        }
    }

    var searchCity: String {
        switch language {
        case .simplifiedChinese: return "搜索城市"
        case .traditionalChinese: return "搜尋城市"
        case .english: return "Search city"
        }
    }

    var searchResults: String {
        switch language {
        case .simplifiedChinese: return "搜索结果"
        case .traditionalChinese: return "搜尋結果"
        case .english: return "Search Results"
        }
    }

    var noCityFound: String {
        switch language {
        case .simplifiedChinese: return "未找到匹配的城市"
        case .traditionalChinese: return "未找到匹配的城市"
        case .english: return "No matching city found"
        }
    }

    var selectRegion: String {
        switch language {
        case .simplifiedChinese: return "选择地区或国家"
        case .traditionalChinese: return "選擇地區或國家"
        case .english: return "Select Region or Country"
        }
    }

    var selectProvince: String {
        switch language {
        case .simplifiedChinese: return "选择地区或国家"
        case .traditionalChinese: return "選擇地區或國家"
        case .english: return "Select Region or Country"
        }
    }

    var selectProvinceOrCity: String {
        switch language {
        case .simplifiedChinese: return "请选择地区或国家"
        case .traditionalChinese: return "請選擇地區或國家"
        case .english: return "Select a region or country"
        }
    }

    var selectCity: String {
        switch language {
        case .simplifiedChinese: return "选择城市"
        case .traditionalChinese: return "選擇城市"
        case .english: return "Select City"
        }
    }

    var currentLocation: String {
        switch language {
        case .simplifiedChinese: return "当前位置"
        case .traditionalChinese: return "目前位置"
        case .english: return "Current Location"
        }
    }

    var manualCoordinates: String {
        switch language {
        case .simplifiedChinese: return "手动输入坐标"
        case .traditionalChinese: return "手動輸入座標"
        case .english: return "Enter Coordinates"
        }
    }

    var locationName: String {
        switch language {
        case .simplifiedChinese: return "地点名称（可选）"
        case .traditionalChinese: return "地點名稱（可選）"
        case .english: return "Location name (optional)"
        }
    }

    var locationRequired: String {
        switch language {
        case .simplifiedChinese: return "请选择出生地点"
        case .traditionalChinese: return "請選擇出生地點"
        case .english: return "Location is required"
        }
    }

    var longitude: String {
        switch language {
        case .simplifiedChinese: return "经度"
        case .traditionalChinese: return "經度"
        case .english: return "Longitude"
        }
    }

    var latitude: String {
        switch language {
        case .simplifiedChinese: return "纬度"
        case .traditionalChinese: return "緯度"
        case .english: return "Latitude"
        }
    }

    var applyCoordinates: String {
        switch language {
        case .simplifiedChinese: return "应用坐标"
        case .traditionalChinese: return "套用座標"
        case .english: return "Apply"
        }
    }

    var coordinatesHint: String {
        switch language {
        case .simplifiedChinese: return "经度范围：-180 到 180\n纬度范围：-90 到 90"
        case .traditionalChinese: return "經度範圍：-180 到 180\n緯度範圍：-90 到 90"
        case .english: return "Longitude: -180 to 180\nLatitude: -90 to 90"
        }
    }

    var customLocation: String {
        switch language {
        case .simplifiedChinese: return "自定义位置"
        case .traditionalChinese: return "自訂位置"
        case .english: return "Custom Location"
        }
    }

    var noCityData: String {
        switch language {
        case .simplifiedChinese: return "暂无城市数据"
        case .traditionalChinese: return "暫無城市資料"
        case .english: return "No city data"
        }
    }

    // MARK: - Birth Profiles
    var selectProfile: String {
        switch language {
        case .simplifiedChinese: return "选择测算对象"
        case .traditionalChinese: return "選擇測算對象"
        case .english: return "Select Profile"
        }
    }

    var selectProfileHint: String {
        switch language {
        case .simplifiedChinese: return "选择已保存的档案或添加新档案"
        case .traditionalChinese: return "選擇已儲存的檔案或新增檔案"
        case .english: return "Choose a saved profile or add a new one"
        }
    }

    var addNewProfile: String {
        switch language {
        case .simplifiedChinese: return "添加新档案"
        case .traditionalChinese: return "新增檔案"
        case .english: return "Add New Profile"
        }
    }

    var addNewProfileHint: String {
        switch language {
        case .simplifiedChinese: return "输入新的生辰资料"
        case .traditionalChinese: return "輸入新的生辰資料"
        case .english: return "Enter new birth information"
        }
    }

    // 中性表达（用于测算流程，不强调"保存档案"）
    var enterNewInfo: String {
        switch language {
        case .simplifiedChinese: return "输入新资料"
        case .traditionalChinese: return "輸入新資料"
        case .english: return "Enter New Info"
        }
    }

    var enterNewInfoHint: String {
        switch language {
        case .simplifiedChinese: return "填写生辰信息开始测算"
        case .traditionalChinese: return "填寫生辰資訊開始測算"
        case .english: return "Fill in birth info to start reading"
        }
    }

    var noProfilesYet: String {
        switch language {
        case .simplifiedChinese: return "暂无已保存的档案"
        case .traditionalChinese: return "尚無已儲存的檔案"
        case .english: return "No Profiles Yet"
        }
    }

    var noProfilesHint: String {
        switch language {
        case .simplifiedChinese: return "添加您或家人的生辰资料，方便下次快速测算"
        case .traditionalChinese: return "新增您或家人的生辰資料，方便下次快速測算"
        case .english: return "Add your or family members' birth data for quick access next time"
        }
    }

    // MARK: - Profile Management
    var manageProfiles: String {
        switch language {
        case .simplifiedChinese: return "档案管理"
        case .traditionalChinese: return "檔案管理"
        case .english: return "Manage Profiles"
        }
    }

    var manageProfilesHint: String {
        switch language {
        case .simplifiedChinese: return "管理您保存的生辰档案"
        case .traditionalChinese: return "管理您儲存的生辰檔案"
        case .english: return "Manage your saved birth profiles"
        }
    }

    var profileCount: String {
        switch language {
        case .simplifiedChinese: return "个档案"
        case .traditionalChinese: return "個檔案"
        case .english: return " profile(s)"
        }
    }

    var createFirstProfile: String {
        switch language {
        case .simplifiedChinese: return "创建您的第一个档案"
        case .traditionalChinese: return "建立您的第一個檔案"
        case .english: return "Create Your First Profile"
        }
    }

    var createFirstProfileHint: String {
        switch language {
        case .simplifiedChinese: return "输入您的生辰资料，开始命理测算之旅"
        case .traditionalChinese: return "輸入您的生辰資料，開始命理測算之旅"
        case .english: return "Enter your birth information to start your fortune reading journey"
        }
    }

    var newProfileWillBeSaved: String {
        switch language {
        case .simplifiedChinese: return "此档案将自动保存，方便您下次快速使用"
        case .traditionalChinese: return "此檔案將自動儲存，方便您下次快速使用"
        case .english: return "This profile will be saved automatically for quick access"
        }
    }

    var oneTimeReading: String {
        switch language {
        case .simplifiedChinese: return "仅本次测算"
        case .traditionalChinese: return "僅本次測算"
        case .english: return "One-time reading only"
        }
    }

    var oneTimeReadingHint: String {
        switch language {
        case .simplifiedChinese: return "不保存此次输入的资料"
        case .traditionalChinese: return "不儲存此次輸入的資料"
        case .english: return "Don't save this information"
        }
    }

    var defaultBadge: String {
        switch language {
        case .simplifiedChinese: return "默认"
        case .traditionalChinese: return "預設"
        case .english: return "Default"
        }
    }

    var editProfile: String {
        switch language {
        case .simplifiedChinese: return "编辑档案"
        case .traditionalChinese: return "編輯檔案"
        case .english: return "Edit Profile"
        }
    }

    var editProfileHint: String {
        switch language {
        case .simplifiedChinese: return "修改出生信息"
        case .traditionalChinese: return "修改出生資訊"
        case .english: return "Modify birth information"
        }
    }

    var setAsDefault: String {
        switch language {
        case .simplifiedChinese: return "设为默认"
        case .traditionalChinese: return "設為預設"
        case .english: return "Set as Default"
        }
    }

    var deleteProfileConfirmation: String {
        switch language {
        case .simplifiedChinese: return "删除档案"
        case .traditionalChinese: return "刪除檔案"
        case .english: return "Delete Profile"
        }
    }

    func deleteProfileMessage(_ name: String) -> String {
        switch language {
        case .simplifiedChinese: return "确定要删除「\(name)」的档案吗？此操作无法撤销。"
        case .traditionalChinese: return "確定要刪除「\(name)」的檔案嗎？此操作無法復原。"
        case .english: return "Are you sure you want to delete \"\(name)\"? This action cannot be undone."
        }
    }

    var profileName: String {
        switch language {
        case .simplifiedChinese: return "档案名称"
        case .traditionalChinese: return "檔案名稱"
        case .english: return "Profile Name"
        }
    }

    var profileNamePlaceholder: String {
        switch language {
        case .simplifiedChinese: return "例如：我自己、妈妈、爸爸"
        case .traditionalChinese: return "例如：我自己、媽媽、爸爸"
        case .english: return "e.g., Myself, Mom, Dad"
        }
    }

    var defaultProfileName: String {
        switch language {
        case .simplifiedChinese: return "我自己"
        case .traditionalChinese: return "我自己"
        case .english: return "Myself"
        }
    }

    var saveAsProfile: String {
        switch language {
        case .simplifiedChinese: return "保存为档案"
        case .traditionalChinese: return "儲存為檔案"
        case .english: return "Save as Profile"
        }
    }

    var saveAsProfileHint: String {
        switch language {
        case .simplifiedChinese: return "保存后下次可快速选择"
        case .traditionalChinese: return "儲存後下次可快速選擇"
        case .english: return "Save for quick access next time"
        }
    }

    var save: String {
        switch language {
        case .simplifiedChinese: return "保存"
        case .traditionalChinese: return "儲存"
        case .english: return "Save"
        }
    }

    var birthInfo: String {
        switch language {
        case .simplifiedChinese: return "生辰信息"
        case .traditionalChinese: return "生辰資訊"
        case .english: return "Birth Information"
        }
    }

    // MARK: - History
    var historyTitle: String {
        switch language {
        case .simplifiedChinese: return "历史记录"
        case .traditionalChinese: return "歷史記錄"
        case .english: return "History"
        }
    }

    func historyCount(_ count: Int) -> String {
        switch language {
        case .simplifiedChinese: return "共 \(count) 条测算记录"
        case .traditionalChinese: return "共 \(count) 筆測算紀錄"
        case .english: return "\(count) reading\(count == 1 ? "" : "s")"
        }
    }

    var manage: String {
        switch language {
        case .simplifiedChinese: return "管理"
        case .traditionalChinese: return "管理"
        case .english: return "Manage"
        }
    }

    var noHistory: String {
        switch language {
        case .simplifiedChinese: return "暂无历史记录"
        case .traditionalChinese: return "暫無歷史記錄"
        case .english: return "No history yet"
        }
    }

    var startFirstReading: String {
        switch language {
        case .simplifiedChinese: return "开启您的第一次命盘测算"
        case .traditionalChinese: return "開始您的第一次命盤測算"
        case .english: return "Start your first reading"
        }
    }

    var readingTime: String {
        switch language {
        case .simplifiedChinese: return "生成时间"
        case .traditionalChinese: return "生成時間"
        case .english: return "Created"
        }
    }

    var shichen: String {
        switch language {
        case .simplifiedChinese: return "时辰"
        case .traditionalChinese: return "時辰"
        case .english: return "Hour"
        }
    }

    // MARK: - Chinese Hours (时辰) Localization
    func chineseHourName(index: Int) -> String {
        let names: [String]
        switch language {
        case .simplifiedChinese:
            names = ["子时", "丑时", "寅时", "卯时", "辰时", "巳时",
                     "午时", "未时", "申时", "酉时", "戌时", "亥时"]
        case .traditionalChinese:
            names = ["子時", "丑時", "寅時", "卯時", "辰時", "巳時",
                     "午時", "未時", "申時", "酉時", "戌時", "亥時"]
        case .english:
            names = ["Zi (23-01)", "Chou (01-03)", "Yin (03-05)", "Mao (05-07)",
                     "Chen (07-09)", "Si (09-11)", "Wu (11-13)", "Wei (13-15)",
                     "Shen (15-17)", "You (17-19)", "Xu (19-21)", "Hai (21-23)"]
        }
        guard index >= 0 && index < names.count else { return names[0] }
        return names[index]
    }

    var allChineseHours: [String] {
        (0..<12).map { chineseHourName(index: $0) }
    }

    // MARK: - Date Format Localization
    var dateFormatPattern: String {
        switch language {
        case .simplifiedChinese: return "yyyy年MM月dd日"
        case .traditionalChinese: return "yyyy年MM月dd日"
        case .english: return "MMM dd, yyyy"
        }
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormatPattern
        if language == .english {
            formatter.locale = Locale(identifier: "en_US")
        }
        return formatter.string(from: date)
    }

    // Lunar date display
    func formatLunarDate(year: Int, month: Int, day: Int, isLeapMonth: Bool) -> String {
        switch language {
        case .simplifiedChinese:
            return "\(year)年\(month)月\(day)日\(isLeapMonth ? "(闰)" : "")"
        case .traditionalChinese:
            return "\(year)年\(month)月\(day)日\(isLeapMonth ? "(閏)" : "")"
        case .english:
            let leapStr = isLeapMonth ? " (Leap)" : ""
            return "Lunar \(year)/\(month)/\(day)\(leapStr)"
        }
    }

    // Solar time correction explanation
    func solarTimeExplanation(inputTime: String, locationName: String, correction: String, finalTime: String, chineseHour: String) -> String {
        switch language {
        case .simplifiedChinese:
            return "您输入的钟表时间是 \(inputTime)，经【\(locationName)】经度及真太阳时校正（\(correction)分），实际天文时间为 \(finalTime)，属于【\(chineseHour)】。"
        case .traditionalChinese:
            return "您輸入的鐘錶時間是 \(inputTime)，經【\(locationName)】經度及真太陽時校正（\(correction)分），實際天文時間為 \(finalTime)，屬於【\(chineseHour)】。"
        case .english:
            return "Your input clock time is \(inputTime). After longitude and true solar time correction for \(locationName) (\(correction) min), the actual astronomical time is \(finalTime), corresponding to the \(chineseHour) hour."
        }
    }

    // Locale identifier for date/time formatting
    var localeIdentifier: String {
        switch language {
        case .simplifiedChinese: return "zh_Hans_CN"
        case .traditionalChinese: return "zh_Hant_TW"
        case .english: return "en_US"
        }
    }

    // Format timestamp for display (e.g., for reading history)
    func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: localeIdentifier)
        return formatter.string(from: date)
    }

    var location: String {
        switch language {
        case .simplifiedChinese: return "地点"
        case .traditionalChinese: return "地點"
        case .english: return "Location"
        }
    }

    var analyzing: String {
        switch language {
        case .simplifiedChinese: return "测算中"
        case .traditionalChinese: return "測算中"
        case .english: return "Analyzing"
        }
    }

    var completed: String {
        switch language {
        case .simplifiedChinese: return "已完成"
        case .traditionalChinese: return "已完成"
        case .english: return "Completed"
        }
    }

    var failed: String {
        switch language {
        case .simplifiedChinese: return "失败"
        case .traditionalChinese: return "失敗"
        case .english: return "Failed"
        }
    }

    var confirmRetry: String {
        switch language {
        case .simplifiedChinese: return "确认重试"
        case .traditionalChinese: return "確認重試"
        case .english: return "Confirm Retry"
        }
    }

    func confirmRetryMessage(date: String) -> String {
        switch language {
        case .simplifiedChinese: return "确定要重新测算 \(date) 的命盘吗？\n\n原来的失败记录将被删除。"
        case .traditionalChinese: return "確定要重新測算 \(date) 的命盤嗎？\n\n原本的失敗紀錄將被刪除。"
        case .english: return "Retry reading for \(date)?\n\nThe failed record will be deleted."
        }
    }

    var retrySuccess: String {
        switch language {
        case .simplifiedChinese: return "重试成功"
        case .traditionalChinese: return "重試成功"
        case .english: return "Retry Started"
        }
    }

    var retrySuccessMessage: String {
        switch language {
        case .simplifiedChinese: return "已重新开始测算，请稍候查看结果"
        case .traditionalChinese: return "已重新開始測算，請稍後查看結果"
        case .english: return "Reading restarted, please check results later"
        }
    }

    var confirmDelete: String {
        switch language {
        case .simplifiedChinese: return "确认删除"
        case .traditionalChinese: return "確認刪除"
        case .english: return "Confirm Delete"
        }
    }

    var deleteReadingMessage: String {
        switch language {
        case .simplifiedChinese: return "确定要删除这条测算记录吗？此操作不可撤销。"
        case .traditionalChinese: return "確定要刪除這筆測算紀錄嗎？此操作無法復原。"
        case .english: return "Delete this reading? This cannot be undone."
        }
    }

    var invalidData: String {
        switch language {
        case .simplifiedChinese: return "数据无效，无法重试"
        case .traditionalChinese: return "資料無效，無法重試"
        case .english: return "Invalid data, cannot retry"
        }
    }

    var cannotLoadReading: String {
        switch language {
        case .simplifiedChinese: return "无法加载记录"
        case .traditionalChinese: return "無法載入紀錄"
        case .english: return "Cannot load record"
        }
    }

    var analysisGenerating: String {
        switch language {
        case .simplifiedChinese: return "测算生成中..."
        case .traditionalChinese: return "測算產生中..."
        case .english: return "Generating reading..."
        }
    }

    var analysisGeneratingHint: String {
        switch language {
        case .simplifiedChinese: return "AI正在分析您的命盘，请稍候"
        case .traditionalChinese: return "AI 正在分析您的命盤，請稍候"
        case .english: return "AI is analyzing your chart, please wait"
        }
    }

    var chartReady: String {
        switch language {
        case .simplifiedChinese: return "命盘已生成"
        case .traditionalChinese: return "命盤已生成"
        case .english: return "Chart Generated"
        }
    }

    var viewChartWhileLoading: String {
        switch language {
        case .simplifiedChinese: return "您可以先查看命盘，测算完成后会自动更新"
        case .traditionalChinese: return "您可以先查看命盤，測算完成後會自動更新"
        case .english: return "You can view the chart now. Reading will update when ready."
        }
    }

    var canLeaveAndComeBack: String {
        switch language {
        case .simplifiedChinese: return "您也可以离开做其他事情，稍后回来查看。如果开启了通知，测算完成时我们会通知您。"
        case .traditionalChinese: return "您也可以離開做其他事情，稍後回來查看。如果開啟了通知，測算完成時我們會通知您。"
        case .english: return "You can also leave and come back later. We'll notify you when done if notifications are enabled."
        }
    }

    // MARK: - Settings
    var settingsTitle: String {
        switch language {
        case .simplifiedChinese: return "设置"
        case .traditionalChinese: return "設定"
        case .english: return "Settings"
        }
    }

    var personalSettings: String {
        switch language {
        case .simplifiedChinese: return "个人设置"
        case .traditionalChinese: return "個人設定"
        case .english: return "Personal Settings"
        }
    }

    var guestUser: String {
        switch language {
        case .simplifiedChinese: return "访客用户"
        case .traditionalChinese: return "訪客用戶"
        case .english: return "Guest User"
        }
    }

    func readingCountText(_ count: Int) -> String {
        switch language {
        case .simplifiedChinese: return "已测算 \(count) 次"
        case .traditionalChinese: return "已測算 \(count) 次"
        case .english: return "\(count) reading\(count == 1 ? "" : "s")"
        }
    }

    var notificationSettings: String {
        switch language {
        case .simplifiedChinese: return "通知设置"
        case .traditionalChinese: return "通知設定"
        case .english: return "Notifications"
        }
    }

    var languageSettings: String {
        switch language {
        case .simplifiedChinese: return "语言设置"
        case .traditionalChinese: return "語言設定"
        case .english: return "Language"
        }
    }

    var aiModelSettings: String {
        switch language {
        case .simplifiedChinese: return "AI 模型设置"
        case .traditionalChinese: return "AI 模型設定"
        case .english: return "AI Model Settings"
        }
    }

    var selectModel: String {
        switch language {
        case .simplifiedChinese: return "选择模型"
        case .traditionalChinese: return "選擇模型"
        case .english: return "Select Model"
        }
    }

    var apiKeyConfig: String {
        switch language {
        case .simplifiedChinese: return "API Key 配置"
        case .traditionalChinese: return "API Key 配置"
        case .english: return "API Key Config"
        }
    }

    var configured: String {
        switch language {
        case .simplifiedChinese: return "已配置"
        case .traditionalChinese: return "已配置"
        case .english: return "Configured"
        }
    }

    var notConfigured: String {
        switch language {
        case .simplifiedChinese: return "未配置"
        case .traditionalChinese: return "未配置"
        case .english: return "Not Configured"
        }
    }

    var privacyAndSecurity: String {
        switch language {
        case .simplifiedChinese: return "隐私与安全"
        case .traditionalChinese: return "隱私與安全"
        case .english: return "Privacy & Security"
        }
    }

    var privacySettings: String {
        switch language {
        case .simplifiedChinese: return "隐私设置"
        case .traditionalChinese: return "隱私設定"
        case .english: return "Privacy Settings"
        }
    }

    var about: String {
        switch language {
        case .simplifiedChinese: return "关于"
        case .traditionalChinese: return "關於"
        case .english: return "About"
        }
    }

    var helpAndFeedback: String {
        switch language {
        case .simplifiedChinese: return "帮助与反馈"
        case .traditionalChinese: return "幫助與回饋"
        case .english: return "Help & Feedback"
        }
    }

    var aboutApp: String {
        switch language {
        case .simplifiedChinese: return "关于紫微 Lab"
        case .traditionalChinese: return "關於紫微 Lab"
        case .english: return "About Ziwei Lab"
        }
    }

    var clearAllData: String {
        switch language {
        case .simplifiedChinese: return "清除所有数据"
        case .traditionalChinese: return "清除所有資料"
        case .english: return "Clear All Data"
        }
    }

    var confirmClear: String {
        switch language {
        case .simplifiedChinese: return "确认清除"
        case .traditionalChinese: return "確認清除"
        case .english: return "Confirm Clear"
        }
    }

    var clearAllDataMessage: String {
        switch language {
        case .simplifiedChinese: return "确定要清除所有历史记录吗？此操作无法撤销。"
        case .traditionalChinese: return "確定要清除所有歷史紀錄嗎？此操作無法復原。"
        case .english: return "Clear all history? This cannot be undone."
        }
    }

    var clear: String {
        switch language {
        case .simplifiedChinese: return "清除"
        case .traditionalChinese: return "清除"
        case .english: return "Clear"
        }
    }

    var notificationPermission: String {
        switch language {
        case .simplifiedChinese: return "通知权限"
        case .traditionalChinese: return "通知權限"
        case .english: return "Notification Permission"
        }
    }

    var notificationPermissionMessage: String {
        switch language {
        case .simplifiedChinese: return "请在系统设置中开启通知权限，以便接收测算完成通知。"
        case .traditionalChinese: return "請在系統設定中開啟通知權限，以便接收測算完成通知。"
        case .english: return "Please enable notifications in Settings to receive reading completion alerts."
        }
    }

    var goToSettings: String {
        switch language {
        case .simplifiedChinese: return "去设置"
        case .traditionalChinese: return "前往設定"
        case .english: return "Go to Settings"
        }
    }

    var appFooter: String {
        switch language {
        case .simplifiedChinese: return "命由己造 · 运随心转"
        case .traditionalChinese: return "命由己造 · 運隨心轉"
        case .english: return "Shape your destiny"
        }
    }

    // MARK: - Loading
    var generatingChart: String {
        switch language {
        case .simplifiedChinese: return "正在生成您的紫微命盘..."
        case .traditionalChinese: return "正在生成您的紫微命盤..."
        case .english: return "Generating your chart..."
        }
    }

    var preparing: String {
        switch language {
        case .simplifiedChinese: return "正在准备..."
        case .traditionalChinese: return "正在準備..."
        case .english: return "Preparing..."
        }
    }

    var analysisWaitMessage: String {
        switch language {
        case .simplifiedChinese: return "测算需要几分钟时间，请耐心等待"
        case .traditionalChinese: return "測算需要幾分鐘，請耐心等候"
        case .english: return "Reading takes a few minutes, please wait"
        }
    }

    var notificationHint: String {
        switch language {
        case .simplifiedChinese: return "测算完成后会通知您（如已开启系统通知）"
        case .traditionalChinese: return "測算完成後會通知您（若已開啟系統通知）"
        case .english: return "You'll be notified when complete (if enabled)"
        }
    }

    // MARK: - Reading Result
    var fortuneAnalysis: String {
        switch language {
        case .simplifiedChinese: return "命盘测算"
        case .traditionalChinese: return "命盤測算"
        case .english: return "Reading"
        }
    }

    var chart: String {
        switch language {
        case .simplifiedChinese: return "命盘"
        case .traditionalChinese: return "命盤"
        case .english: return "Chart"
        }
    }

    var birthPlaceLabel: String {
        switch language {
        case .simplifiedChinese: return "出生地"
        case .traditionalChinese: return "出生地"
        case .english: return "Birth place"
        }
    }

    var trueSolarTime: String {
        switch language {
        case .simplifiedChinese: return "真太阳时"
        case .traditionalChinese: return "真太陽時"
        case .english: return "True Solar Time"
        }
    }

    var fiveElements: String {
        switch language {
        case .simplifiedChinese: return "五行局"
        case .traditionalChinese: return "五行局"
        case .english: return "Five Elements"
        }
    }

    var lifeMaster: String {
        switch language {
        case .simplifiedChinese: return "命主"
        case .traditionalChinese: return "命主"
        case .english: return "Life Master"
        }
    }

    var bodyMaster: String {
        switch language {
        case .simplifiedChinese: return "身主"
        case .traditionalChinese: return "身主"
        case .english: return "Body Master"
        }
    }

    var generatedTime: String {
        switch language {
        case .simplifiedChinese: return "生成时间"
        case .traditionalChinese: return "生成時間"
        case .english: return "Generated"
        }
    }

    var aiDisclaimer: String {
        switch language {
        case .simplifiedChinese: return "本分析由 AI 生成，仅供参考"
        case .traditionalChinese: return "本分析由 AI 生成，僅供參考"
        case .english: return "AI-generated analysis for reference only"
        }
    }

    // MARK: - Chart Display
    var centerTitle: String {
        switch language {
        case .simplifiedChinese: return "紫微斗数"
        case .traditionalChinese: return "紫微斗數"
        case .english: return "Zi Wei Dou Shu"
        }
    }

    var birthYearFourTransforms: String {
        switch language {
        case .simplifiedChinese: return "生年四化"
        case .traditionalChinese: return "生年四化"
        case .english: return "Birth Year Transforms"
        }
    }

    var decadalCycle: String {
        switch language {
        case .simplifiedChinese: return "大限周期"
        case .traditionalChinese: return "大限週期"
        case .english: return "Decadal Cycle"
        }
    }

    var noMajorStars: String {
        switch language {
        case .simplifiedChinese: return "本宫无主星"
        case .traditionalChinese: return "本宮無主星"
        case .english: return "No Major Stars"
        }
    }

    var bodyPalaceBadge: String {
        switch language {
        case .simplifiedChinese: return "身宫"
        case .traditionalChinese: return "身宮"
        case .english: return "Body"
        }
    }

    var yearSuffix: String {
        switch language {
        case .simplifiedChinese: return "年"
        case .traditionalChinese: return "年"
        case .english: return " Year"
        }
    }

    var ageSuffix: String {
        switch language {
        case .simplifiedChinese: return "岁"
        case .traditionalChinese: return "歲"
        case .english: return ""
        }
    }

    func ageRange(start: Int, end: Int) -> String {
        switch language {
        case .simplifiedChinese: return "\(start)-\(end)岁"
        case .traditionalChinese: return "\(start)-\(end)歲"
        case .english: return "Age \(start)-\(end)"
        }
    }

    // MARK: - Chart Guide Hints
    var chartTapHint: String {
        switch language {
        case .simplifiedChinese: return "点击任意宫位查看详细星曜"
        case .traditionalChinese: return "點擊任意宮位查看詳細星曜"
        case .english: return "Tap any palace to view star details"
        }
    }

    var gotIt: String {
        switch language {
        case .simplifiedChinese: return "知道了"
        case .traditionalChinese: return "知道了"
        case .english: return "Got it"
        }
    }

    // MARK: - Post-Analysis Hints
    var postAnalysisTitle: String {
        switch language {
        case .simplifiedChinese: return "接下来"
        case .traditionalChinese: return "接下來"
        case .english: return "What's Next"
        }
    }

    var postAnalysisHistory: String {
        switch language {
        case .simplifiedChinese: return "查看历史记录"
        case .traditionalChinese: return "查看歷史紀錄"
        case .english: return "View Reading History"
        }
    }

    var postAnalysisHistoryHint: String {
        switch language {
        case .simplifiedChinese: return "回顾所有测算结果"
        case .traditionalChinese: return "回顧所有測算結果"
        case .english: return "Review all your past readings"
        }
    }

    var postAnalysisTryAnother: String {
        switch language {
        case .simplifiedChinese: return "换个分类测算"
        case .traditionalChinese: return "換個分類測算"
        case .english: return "Try Another Category"
        }
    }

    var postAnalysisTryAnotherHint: String {
        switch language {
        case .simplifiedChinese: return "探索命盘的不同方面"
        case .traditionalChinese: return "探索命盤的不同方面"
        case .english: return "Explore different aspects of your chart"
        }
    }

    var postAnalysisShare: String {
        switch language {
        case .simplifiedChinese: return "分享测算结果"
        case .traditionalChinese: return "分享測算結果"
        case .english: return "Share This Reading"
        }
    }

    var postAnalysisShareHint: String {
        switch language {
        case .simplifiedChinese: return "将分析结果分享给朋友"
        case .traditionalChinese: return "將分析結果分享給朋友"
        case .english: return "Share your analysis with friends"
        }
    }

    // MARK: - Chart Insights (Loading State)
    var chartInsightsTitle: String {
        switch language {
        case .simplifiedChinese: return "命盘解读"
        case .traditionalChinese: return "命盤解讀"
        case .english: return "Chart Insights"
        }
    }

    var chartInsightsSubtitle: String {
        switch language {
        case .simplifiedChinese: return "根据您的命盘信息"
        case .traditionalChinese: return "根據您的命盤資訊"
        case .english: return "Based on your chart"
        }
    }

    var insightTapToExpand: String {
        switch language {
        case .simplifiedChinese: return "点击展开"
        case .traditionalChinese: return "點擊展開"
        case .english: return "Tap to expand"
        }
    }

    var insightAIGeneratingNote: String {
        switch language {
        case .simplifiedChinese: return "以上为命盘基础信息，AI 深度解读正在生成中…"
        case .traditionalChinese: return "以上為命盤基礎資訊，AI 深度解讀正在產生中…"
        case .english: return "Above are chart basics. AI deep analysis is generating..."
        }
    }

    var insightHistoryReminder: String {
        switch language {
        case .simplifiedChinese: return "返回后可在「历史记录」中查看结果"
        case .traditionalChinese: return "返回後可在「歷史紀錄」中查看結果"
        case .english: return "You can find results in History after leaving"
        }
    }

    var insightAnalysisReady: String {
        switch language {
        case .simplifiedChinese: return "AI 解读已完成"
        case .traditionalChinese: return "AI 解讀已完成"
        case .english: return "AI Analysis Ready"
        }
    }

    var insightViewAnalysis: String {
        switch language {
        case .simplifiedChinese: return "查看完整解读"
        case .traditionalChinese: return "查看完整解讀"
        case .english: return "View Full Analysis"
        }
    }

    // MARK: - Accessibility
    var previousCard: String {
        switch language {
        case .simplifiedChinese: return "上一个"
        case .traditionalChinese: return "上一個"
        case .english: return "Previous"
        }
    }

    var nextCard: String {
        switch language {
        case .simplifiedChinese: return "下一个"
        case .traditionalChinese: return "下一個"
        case .english: return "Next"
        }
    }
}

// MARK: - Legacy Compatibility (to be removed after migration)
// These are kept for backward compatibility during migration
struct MainScreenStrings {
    let appTitle: String
    let subtitle: String
    let startReading: String
    let hint: String
    let newReading: String
    let history: String
    let settings: String
    let analyzingMenu: String
    let back: String
    let note: String
    let error: String
    let unknownError: String
    let scanFailed: String
    let selectLanguage: String
    let languageText: String
    let scanningStartedMessage: String
}

struct HistoryScreenStrings {
    let title: String
    let empty: String
    let emptyHint: String
    let done: String
    let ok: String
    let delete: String
}

extension LocalizationManager {
    // Legacy compatibility
    @available(*, deprecated, message: "Use LocalizationManager.shared.strings instead")
    var mainScreen: MainScreenStrings {
        let s = strings
        return MainScreenStrings(
            appTitle: s.appTitle,
            subtitle: "AI 智能排盘",
            startReading: s.startReading,
            hint: "输入出生信息，获取专属测算",
            newReading: s.readingCardTitle,
            history: s.historyCardTitle,
            settings: s.settingsCardTitle,
            analyzingMenu: s.analyzing,
            back: s.back,
            note: "注意",
            error: s.error,
            unknownError: s.unknownError,
            scanFailed: "解析失败",
            selectLanguage: s.selectLanguage,
            languageText: s.languageSettings,
            scanningStartedMessage: s.generatingChart
        )
    }

    @available(*, deprecated, message: "Use LocalizationManager.shared.strings instead")
    var historyScreen: HistoryScreenStrings {
        let s = strings
        return HistoryScreenStrings(
            title: s.historyTitle,
            empty: s.noHistory,
            emptyHint: s.startFirstReading,
            done: s.done,
            ok: s.confirm,
            delete: s.delete
        )
    }
}
