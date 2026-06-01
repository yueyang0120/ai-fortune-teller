import Foundation

// MARK: - Localized Interpretation Text

struct LocalizedInsight {
    let zhHans: String
    let zhHant: String
    let en: String

    var localized: String {
        switch LocalizationManager.shared.currentLanguage {
        case .simplifiedChinese: return zhHans
        case .traditionalChinese: return zhHant
        case .english: return en
        }
    }
}

// MARK: - Insight Item (UI-ready)

struct ChartInsightItem: Identifiable {
    let id: String
    let icon: String
    let label: LocalizedInsight
    let title: LocalizedInsight
    let body: LocalizedInsight
    let category: InsightCategory
}

enum InsightCategory {
    case fiveElementBureau
    case lifeMaster
    case bodyMaster
    case majorStar
    case emptyPalace
}

// MARK: - Five Element Bureau Descriptions
// Source: Classical ZWDS texts (《紫微斗数全书》), cross-referenced with iztro library data.
// These describe the elemental quality — NOT fortune predictions.

enum FiveElementBureauInsights {
    static func insight(for bureau: String) -> (label: LocalizedInsight, body: LocalizedInsight)? {
        switch bureau {
        case _ where bureau.contains("水二"):
            return (
                label: LocalizedInsight(
                    zhHans: "水二局",
                    zhHant: "水二局",
                    en: "Water 2nd Bureau"
                ),
                body: LocalizedInsight(
                    zhHans: "水主智，性灵活善变通。水二局局数最小，代表生命能量如水般流动，善于适应环境变化。",
                    zhHant: "水主智，性靈活善變通。水二局局數最小，代表生命能量如水般流動，善於適應環境變化。",
                    en: "Water governs wisdom and adaptability. As the smallest bureau number, it represents life energy that flows like water — flexible and responsive to change."
                )
            )
        case _ where bureau.contains("木三"):
            return (
                label: LocalizedInsight(
                    zhHans: "木三局",
                    zhHant: "木三局",
                    en: "Wood 3rd Bureau"
                ),
                body: LocalizedInsight(
                    zhHans: "木主仁，性生长向上。木三局代表生命能量如树木般扎根成长，注重发展与进取。",
                    zhHant: "木主仁，性生長向上。木三局代表生命能量如樹木般扎根成長，注重發展與進取。",
                    en: "Wood governs benevolence and growth. It represents life energy that grows upward like a tree — rooted, progressive, and development-oriented."
                )
            )
        case _ where bureau.contains("金四"):
            return (
                label: LocalizedInsight(
                    zhHans: "金四局",
                    zhHant: "金四局",
                    en: "Metal 4th Bureau"
                ),
                body: LocalizedInsight(
                    zhHans: "金主义，性刚毅果决。金四局代表生命能量如金属般坚韧，原则性强，重视规则与秩序。",
                    zhHant: "金主義，性剛毅果決。金四局代表生命能量如金屬般堅韌，原則性強，重視規則與秩序。",
                    en: "Metal governs righteousness and resolve. It represents life energy that is firm like metal — principled, decisive, and valuing structure."
                )
            )
        case _ where bureau.contains("土五"):
            return (
                label: LocalizedInsight(
                    zhHans: "土五局",
                    zhHant: "土五局",
                    en: "Earth 5th Bureau"
                ),
                body: LocalizedInsight(
                    zhHans: "土主信，性稳重包容。土五局代表生命能量如大地般承载万物，厚德载物，稳健踏实。",
                    zhHant: "土主信，性穩重包容。土五局代表生命能量如大地般承載萬物，厚德載物，穩健踏實。",
                    en: "Earth governs trust and stability. It represents life energy that is grounding like the earth — supportive, tolerant, and steady."
                )
            )
        case _ where bureau.contains("火六"):
            return (
                label: LocalizedInsight(
                    zhHans: "火六局",
                    zhHant: "火六局",
                    en: "Fire 6th Bureau"
                ),
                body: LocalizedInsight(
                    zhHans: "火主礼，性热情明亮。火六局局数最大，代表生命能量如火焰般炽热向上，行动力强，热情奔放。",
                    zhHant: "火主禮，性熱情明亮。火六局局數最大，代表生命能量如火焰般熾熱向上，行動力強，熱情奔放。",
                    en: "Fire governs propriety and passion. As the largest bureau number, it represents life energy that blazes upward like flame — dynamic, enthusiastic, and action-oriented."
                )
            )
        default:
            return nil
        }
    }
}

// MARK: - 14 Major Star Archetype Descriptions
// Source: Classical ZWDS texts, cross-referenced across 王亭之, 陆斌兆, 紫云 authorities.
// These are archetypal traits only — NOT fortune predictions.

enum MajorStarInsights {
    static func insight(for starName: String) -> (title: LocalizedInsight, body: LocalizedInsight)? {
        let data = allStars[starName]
        return data
    }

    static let allStars: [String: (title: LocalizedInsight, body: LocalizedInsight)] = [
        "紫微": (
            title: LocalizedInsight(zhHans: "帝王之星", zhHant: "帝王之星", en: "The Emperor Star"),
            body: LocalizedInsight(
                zhHans: "紫微属己土，为斗数之主。代表领导力、尊贵与主见，有号令之气。",
                zhHant: "紫微屬己土，為斗數之主。代表領導力、尊貴與主見，有號令之氣。",
                en: "Ziwei belongs to Yin Earth. The sovereign of all stars — it represents leadership, dignity, and authority."
            )
        ),
        "天机": (
            title: LocalizedInsight(zhHans: "智慧之星", zhHant: "智慧之星", en: "The Advisor Star"),
            body: LocalizedInsight(
                zhHans: "天机属乙木，为谋臣之星。代表智慧、思虑与机变，善于策划分析。",
                zhHant: "天機屬乙木，為謀臣之星。代表智慧、思慮與機變，善於策劃分析。",
                en: "Tianji belongs to Yin Wood. The advisor — it represents intelligence, strategic thinking, and adaptability."
            )
        ),
        "太阳": (
            title: LocalizedInsight(zhHans: "光明之星", zhHant: "光明之星", en: "The Sun Star"),
            body: LocalizedInsight(
                zhHans: "太阳属丙火，为光明之星。代表热情、博爱与给予，光明磊落，乐于付出。",
                zhHant: "太陽屬丙火，為光明之星。代表熱情、博愛與給予，光明磊落，樂於付出。",
                en: "Taiyang belongs to Yang Fire. The sun — it represents warmth, generosity, and selfless giving."
            )
        ),
        "武曲": (
            title: LocalizedInsight(zhHans: "财将之星", zhHant: "財將之星", en: "The Finance Star"),
            body: LocalizedInsight(
                zhHans: "武曲属辛金，为财星兼将星。代表刚毅果断、务实，重视执行力与实际成果。",
                zhHant: "武曲屬辛金，為財星兼將星。代表剛毅果斷、務實，重視執行力與實際成果。",
                en: "Wuqu belongs to Yin Metal. Both finance and general star — it represents decisiveness, pragmatism, and execution."
            )
        ),
        "天同": (
            title: LocalizedInsight(zhHans: "福星", zhHant: "福星", en: "The Blessing Star"),
            body: LocalizedInsight(
                zhHans: "天同属壬水，为福星。代表温和善良、知足常乐，心性柔软，追求安逸与和谐。",
                zhHant: "天同屬壬水，為福星。代表溫和善良、知足常樂，心性柔軟，追求安逸與和諧。",
                en: "Tiantong belongs to Yang Water. The blessing star — it represents gentleness, contentment, and a peaceful nature."
            )
        ),
        "廉贞": (
            title: LocalizedInsight(zhHans: "政星", zhHant: "政星", en: "The Power Star"),
            body: LocalizedInsight(
                zhHans: "廉贞属丙火，为政星。代表精明能干、善交际、情感丰富，兼具正邪两面性。",
                zhHant: "廉貞屬丙火，為政星。代表精明能幹、善交際、情感豐富，兼具正邪兩面性。",
                en: "Lianzhen belongs to Yang Fire. The power star — it represents shrewdness, social skill, and emotional depth with dual nature."
            )
        ),
        "天府": (
            title: LocalizedInsight(zhHans: "库藏之星", zhHant: "庫藏之星", en: "The Treasury Star"),
            body: LocalizedInsight(
                zhHans: "天府属戊土，为库藏之星。代表稳重保守、包容大度，善于积蓄，注重安全感。",
                zhHant: "天府屬戊土，為庫藏之星。代表穩重保守、包容大度，善於積蓄，注重安全感。",
                en: "Tianfu belongs to Yang Earth. The treasury — it represents stability, tolerance, and a talent for accumulation."
            )
        ),
        "太阴": (
            title: LocalizedInsight(zhHans: "月亮之星", zhHant: "月亮之星", en: "The Moon Star"),
            body: LocalizedInsight(
                zhHans: "太阴属癸水，为月亮之星。代表温柔细腻、内向含蓄，富有想象力与感性之美。",
                zhHant: "太陰屬癸水，為月亮之星。代表溫柔細膩、內向含蓄，富有想像力與感性之美。",
                en: "Taiyin belongs to Yin Water. The moon — it represents gentleness, introversion, and imaginative beauty."
            )
        ),
        "贪狼": (
            title: LocalizedInsight(zhHans: "欲望之星", zhHant: "慾望之星", en: "The Desire Star"),
            body: LocalizedInsight(
                zhHans: "贪狼属甲木癸水，为桃花星。代表多才多艺、好奇心旺盛、交际广泛，善于应变。",
                zhHant: "貪狼屬甲木癸水，為桃花星。代表多才多藝、好奇心旺盛、交際廣泛，善於應變。",
                en: "Tanlang belongs to Wood/Water. The desire star — it represents versatility, curiosity, and broad social connections."
            )
        ),
        "巨门": (
            title: LocalizedInsight(zhHans: "暗星", zhHant: "暗星", en: "The Orator Star"),
            body: LocalizedInsight(
                zhHans: "巨门属癸水，为暗星。代表口才出众、善于分析辩论，有研究精神，直言不讳。",
                zhHant: "巨門屬癸水，為暗星。代表口才出眾、善於分析辯論，有研究精神，直言不諱。",
                en: "Jumen belongs to Yin Water. The orator — it represents eloquence, analytical ability, and a probing mind."
            )
        ),
        "天相": (
            title: LocalizedInsight(zhHans: "印星", zhHant: "印星", en: "The Seal Star"),
            body: LocalizedInsight(
                zhHans: "天相属壬水，为印星。代表端正有礼、做事有条理，善于协调辅佐，重视形象。",
                zhHant: "天相屬壬水，為印星。代表端正有禮、做事有條理，善於協調輔佐，重視形象。",
                en: "Tianxiang belongs to Yang Water. The seal — it represents propriety, organization, and a talent for coordination."
            )
        ),
        "天梁": (
            title: LocalizedInsight(zhHans: "荫星", zhHant: "蔭星", en: "The Elder Star"),
            body: LocalizedInsight(
                zhHans: "天梁属戊土，为荫星。代表慈祥稳重、乐于助人、正直有原则，有化解困难之力。",
                zhHant: "天梁屬戊土，為蔭星。代表慈祥穩重、樂於助人、正直有原則，有化解困難之力。",
                en: "Tianliang belongs to Yang Earth. The elder — it represents benevolence, integrity, and the power to resolve difficulties."
            )
        ),
        "七杀": (
            title: LocalizedInsight(zhHans: "将星", zhHant: "將星", en: "The Commander Star"),
            body: LocalizedInsight(
                zhHans: "七杀属庚金，为将星。代表刚烈果敢、独立自主、行动力强，有开拓变革之力。",
                zhHant: "七殺屬庚金，為將星。代表剛烈果敢、獨立自主、行動力強，有開拓變革之力。",
                en: "Qisha belongs to Yang Metal. The commander — it represents courage, independence, and the power of transformation."
            )
        ),
        "破军": (
            title: LocalizedInsight(zhHans: "先锋之星", zhHant: "先鋒之星", en: "The Pioneer Star"),
            body: LocalizedInsight(
                zhHans: "破军属癸水，为先锋之星。代表不安现状、敢于冒险、破旧立新，先破后立。",
                zhHant: "破軍屬癸水，為先鋒之星。代表不安現狀、敢於冒險、破舊立新，先破後立。",
                en: "Pojun belongs to Yin Water. The pioneer — it represents restlessness, risk-taking, and the power to break and rebuild."
            )
        ),
    ]
}

// MARK: - Life Master & Body Master Descriptions
// 命主由命宫地支决定，身主由出生年支决定。

enum MasterStarInsights {
    static func lifeMasterInsight(for starName: String) -> LocalizedInsight? {
        return lifeMasterDescriptions[starName]
    }

    static func bodyMasterInsight(for starName: String) -> LocalizedInsight? {
        return bodyMasterDescriptions[starName]
    }

    // 命主星：先天本质倾向
    static let lifeMasterDescriptions: [String: LocalizedInsight] = [
        "贪狼": LocalizedInsight(
            zhHans: "命主贪狼，先天多欲多才，好奇心旺盛，对新事物有强烈探索欲。",
            zhHant: "命主貪狼，先天多慾多才，好奇心旺盛，對新事物有強烈探索慾。",
            en: "Life Master Tanlang — innately versatile and curious, with a strong drive to explore new experiences."
        ),
        "巨门": LocalizedInsight(
            zhHans: "命主巨门，先天善于思辨，有研究精神，内心追求真实与透彻。",
            zhHant: "命主巨門，先天善於思辨，有研究精神，內心追求真實與透徹。",
            en: "Life Master Jumen — innately analytical with a probing mind, seeking truth and clarity."
        ),
        "禄存": LocalizedInsight(
            zhHans: "命主禄存，先天重视实际利益与安全感，为人谨慎务实。",
            zhHant: "命主祿存，先天重視實際利益與安全感，為人謹慎務實。",
            en: "Life Master Lucun — innately values security and practical benefit, prudent by nature."
        ),
        "文曲": LocalizedInsight(
            zhHans: "命主文曲，先天感性细腻，有艺术天赋，注重精神世界的丰富。",
            zhHant: "命主文曲，先天感性細膩，有藝術天賦，注重精神世界的豐富。",
            en: "Life Master Wenqu — innately sensitive with artistic inclination, valuing inner richness."
        ),
        "廉贞": LocalizedInsight(
            zhHans: "命主廉贞，先天精明敏锐，情感丰富，内在有强烈的驱动力。",
            zhHant: "命主廉貞，先天精明敏銳，情感豐富，內在有強烈的驅動力。",
            en: "Life Master Lianzhen — innately sharp and emotionally rich, with a strong inner drive."
        ),
        "武曲": LocalizedInsight(
            zhHans: "命主武曲，先天刚毅务实，注重效率与成果，有执行力。",
            zhHant: "命主武曲，先天剛毅務實，注重效率與成果，有執行力。",
            en: "Life Master Wuqu — innately resolute and pragmatic, focused on results and execution."
        ),
        "破军": LocalizedInsight(
            zhHans: "命主破军，先天不安于现状，有变革的内在冲动，敢于突破。",
            zhHant: "命主破軍，先天不安於現狀，有變革的內在衝動，敢於突破。",
            en: "Life Master Pojun — innately restless, with an inner urge for change and breakthrough."
        ),
    ]

    // 身主星：后天行为倾向
    static let bodyMasterDescriptions: [String: LocalizedInsight] = [
        "火星": LocalizedInsight(
            zhHans: "身主火星，行事风格急切果断，有爆发力，追求快速行动。",
            zhHant: "身主火星，行事風格急切果斷，有爆發力，追求快速行動。",
            en: "Body Master Huoxing — acts with urgency and decisiveness, driven by swift action."
        ),
        "天相": LocalizedInsight(
            zhHans: "身主天相，行事端正有条理，注重协调与辅佐，外在追求和谐。",
            zhHant: "身主天相，行事端正有條理，注重協調與輔佐，外在追求和諧。",
            en: "Body Master Tianxiang — acts with propriety and order, pursuing harmony through coordination."
        ),
        "天梁": LocalizedInsight(
            zhHans: "身主天梁，行为上倾向庇护他人，追求正义，有长辈风范。",
            zhHant: "身主天梁，行為上傾向庇護他人，追求正義，有長輩風範。",
            en: "Body Master Tianliang — tends to protect others, pursuing justice with an elder's bearing."
        ),
        "天同": LocalizedInsight(
            zhHans: "身主天同，行事温和随和，追求安逸舒适，外在给人亲切感。",
            zhHant: "身主天同，行事溫和隨和，追求安逸舒適，外在給人親切感。",
            en: "Body Master Tiantong — acts gently and agreeably, pursuing comfort with an approachable manner."
        ),
        "文昌": LocalizedInsight(
            zhHans: "身主文昌，行为上注重文化修养与学识，外在追求知识与表达。",
            zhHant: "身主文昌，行為上注重文化修養與學識，外在追求知識與表達。",
            en: "Body Master Wenchang — focused on cultural cultivation and knowledge in outward pursuits."
        ),
        "天机": LocalizedInsight(
            zhHans: "身主天机，行事灵活善变，外在追求智慧与策略，善于应对变化。",
            zhHant: "身主天機，行事靈活善變，外在追求智慧與策略，善於應對變化。",
            en: "Body Master Tianji — acts with flexibility and strategy, adept at navigating change."
        ),
    ]
}

// MARK: - Empty Palace Description

enum EmptyPalaceInsight {
    static let description = LocalizedInsight(
        zhHans: "此宫位无主星坐守，称为「空宫」。空宫并非空无，其特质受对宫主星及三方四正星曜影响。",
        zhHant: "此宮位無主星坐守，稱為「空宮」。空宮並非空無，其特質受對宮主星及三方四正星曜影響。",
        en: "This palace has no major star — called an \"empty palace.\" Its character is shaped by the opposite palace and surrounding stars."
    )
}

// MARK: - Chart Insights Engine

struct ChartInsightsEngine {
    let chart: ZiWeiChart

    func generateInsights() -> [ChartInsightItem] {
        var items: [ChartInsightItem] = []

        // 1. Five Element Bureau
        if let bureau = FiveElementBureauInsights.insight(for: chart.fiveElementBureau) {
            items.append(ChartInsightItem(
                id: "bureau",
                icon: "drop.fill",
                label: bureau.label,
                title: LocalizedInsight(
                    zhHans: "你的五行局",
                    zhHant: "你的五行局",
                    en: "Your Five Element Bureau"
                ),
                body: bureau.body,
                category: .fiveElementBureau
            ))
        }

        // 2. Life Master Star
        if let lifeMasterBody = MasterStarInsights.lifeMasterInsight(for: chart.lifeMaster) {
            items.append(ChartInsightItem(
                id: "lifeMaster",
                icon: "sparkle",
                label: LocalizedInsight(
                    zhHans: "命主 \(chart.lifeMaster)",
                    zhHant: "命主 \(chart.lifeMaster)",
                    en: "Life Master: \(chart.lifeMaster)"
                ),
                title: LocalizedInsight(
                    zhHans: "你的命主星",
                    zhHant: "你的命主星",
                    en: "Your Life Master"
                ),
                body: lifeMasterBody,
                category: .lifeMaster
            ))
        }

        // 3. Body Master Star
        if let bodyMasterBody = MasterStarInsights.bodyMasterInsight(for: chart.bodyMaster) {
            items.append(ChartInsightItem(
                id: "bodyMaster",
                icon: "figure.stand",
                label: LocalizedInsight(
                    zhHans: "身主 \(chart.bodyMaster)",
                    zhHant: "身主 \(chart.bodyMaster)",
                    en: "Body Master: \(chart.bodyMaster)"
                ),
                title: LocalizedInsight(
                    zhHans: "你的身主星",
                    zhHant: "你的身主星",
                    en: "Your Body Master"
                ),
                body: bodyMasterBody,
                category: .bodyMaster
            ))
        }

        // 4. Major stars in Life Palace (命宫)
        if let lifePalace = chart.palace(named: .ming) {
            let majorStars = lifePalace.stars.filter { $0.type == .major }
            if majorStars.isEmpty {
                items.append(ChartInsightItem(
                    id: "emptyPalace",
                    icon: "circle.dashed",
                    label: LocalizedInsight(
                        zhHans: "命宫",
                        zhHant: "命宮",
                        en: "Life Palace"
                    ),
                    title: LocalizedInsight(
                        zhHans: "命宫格局",
                        zhHant: "命宮格局",
                        en: "Life Palace Pattern"
                    ),
                    body: EmptyPalaceInsight.description,
                    category: .emptyPalace
                ))
            } else {
                for star in majorStars {
                    if let starInsight = MajorStarInsights.insight(for: star.name) {
                        items.append(ChartInsightItem(
                            id: "star-\(star.name)",
                            icon: "star.fill",
                            label: LocalizedInsight(
                                zhHans: "命宫 · \(star.name)",
                                zhHant: "命宮 · \(star.name)",
                                en: "Life Palace · \(star.name)"
                            ),
                            title: starInsight.title,
                            body: starInsight.body,
                            category: .majorStar
                        ))
                    }
                }
            }
        }

        return items
    }
}
