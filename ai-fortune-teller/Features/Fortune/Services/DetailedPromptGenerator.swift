import Foundation

/// 详细命盘Prompt生成器
/// 生成类似"文墨天机"格式的详细命盘数据，用于喂给Gemini进行分析
class DetailedPromptGenerator {

    /// 分离的 Prompt 结构（用于 Gemini API 的 systemInstruction + contents 格式）
    struct SeparatedPrompt {
        let systemInstruction: String  // 系统角色、分析指南、风格要求
        let userContent: String         // 命盘数据 + 分析要求
    }

    /// 生成分离的 Prompt（推荐用于 RAG/File Search）
    /// - Parameters:
    ///   - chart: 紫微斗数命盘
    ///   - birthInfo: 出生信息
    ///   - yearlyFlows: 可选的流年详细数据
    ///   - language: 输出语言
    /// - Returns: 包含 systemInstruction 和 userContent 的结构
    static func generateSeparatedPrompt(chart: ZiWeiChart, birthInfo: BirthInfo, yearlyFlows: [YearlyFlowContext]? = nil, language: AppLanguage? = nil) -> SeparatedPrompt {
        let outputLanguage = language ?? LocalizationManager.shared.currentLanguage

        // System Instruction: 角色设定和分析指南
        let systemInstruction = generateSystemRole(language: outputLanguage)

        // User Content: 命盘数据 + 分析要求
        var userContent = ""
        userContent += generateBasicInfo(birthInfo: birthInfo, chart: chart)
        userContent += generatePalacesInfo(chart: chart)
        userContent += generateMajorLimitsInfo(chart: chart, birthInfo: birthInfo, yearlyFlows: yearlyFlows)
        userContent += generateAnalysisRequirements(topic: birthInfo.analysisTopic, language: outputLanguage)

        return SeparatedPrompt(systemInstruction: systemInstruction, userContent: userContent)
    }

    /// 生成详细的命盘分析Prompt（合并版本，向后兼容）
    /// - Parameters:
    ///   - chart: 紫微斗数命盘
    ///   - birthInfo: 出生信息
    ///   - yearlyFlows: 可选的流年详细数据
    ///   - language: 输出语言（默认从 LocalizationManager 获取）
    /// - Returns: 格式化的详细prompt字符串
    static func generateDetailedPrompt(chart: ZiWeiChart, birthInfo: BirthInfo, yearlyFlows: [YearlyFlowContext]? = nil, language: AppLanguage? = nil) -> String {
        let separated = generateSeparatedPrompt(chart: chart, birthInfo: birthInfo, yearlyFlows: yearlyFlows, language: language)
        return separated.systemInstruction + separated.userContent
    }

    // MARK: - Synastry Prompt Generation

    /// 生成合盘分析的分离 Prompt
    static func generateSynastryPrompt(
        chartA: ZiWeiChart, birthInfoA: BirthInfo,
        chartB: ZiWeiChart, birthInfoB: BirthInfo,
        synastryType: SynastryType,
        relationshipRole: RelationshipRole? = nil,
        language: AppLanguage? = nil
    ) -> SeparatedPrompt {
        let outputLanguage = language ?? LocalizationManager.shared.currentLanguage

        let systemInstruction = generateSystemRole(language: outputLanguage)

        var userContent = ""

        // Person A/B labels: use role if available, or type-specific defaults
        let labelA: String
        let labelB: String
        if let role = relationshipRole {
            labelA = role.personARole
            labelB = role.personBRole
        } else {
            switch synastryType {
            case .pet:
                labelA = "主人"
                labelB = "宠物"
            default:
                labelA = "第一位"
                labelB = "第二位"
            }
        }

        // 甲方命盘
        userContent += "\n┌═══════════════════════════════════════\n"
        userContent += "│ 【\(labelA)】命盘信息\n"
        userContent += "└═══════════════════════════════════════\n"
        userContent += generateBasicInfo(birthInfo: birthInfoA, chart: chartA)
        userContent += generatePalacesInfo(chart: chartA)
        userContent += generateMajorLimitsInfo(chart: chartA, birthInfo: birthInfoA)

        // 乙方命盘
        userContent += "\n┌═══════════════════════════════════════\n"
        userContent += "│ 【\(labelB)】命盘信息\n"
        userContent += "└═══════════════════════════════════════\n"
        userContent += generateBasicInfo(birthInfo: birthInfoB, chart: chartB)
        userContent += generatePalacesInfo(chart: chartB)
        userContent += generateMajorLimitsInfo(chart: chartB, birthInfo: birthInfoB)

        // 分析要求：只给关系类型标签 + 角色信息，不预设分析维度
        userContent += generateSynastryRequirements(synastryType: synastryType, relationshipRole: relationshipRole, language: outputLanguage)

        return SeparatedPrompt(systemInstruction: systemInstruction, userContent: userContent)
    }

    /// 生成合盘分析要求（简洁，不预设分析侧重）
    private static func generateSynastryRequirements(synastryType: SynastryType, relationshipRole: RelationshipRole?, language: AppLanguage) -> String {
        let topicLabel = synastryType.rawValue

        // Build role context string if applicable
        let roleContext: String
        if let role = relationshipRole {
            roleContext = "\n        │ 具体关系：\(role.personARole)与\(role.personBRole)（\(role.rawValue)）\n"
        } else {
            roleContext = ""
        }

        var requirements = """
        ├分析要求
        │
        │ 本次分析的主题是：【\(topicLabel)】\(roleContext)
        │ 以上提供了两人的完整紫微斗数命盘数据。
        │ 请根据两张命盘的星曜、宫位、四化飞星等信息，对两人的关系进行深度合盘分析。
        │
        │ 分析侧重（核心）：
        │   - 重点分析两人之间的互动模式、沟通方式和情感连接
        │   - 性格的交合与摩擦：两人性格如何互补或冲突？哪些特质容易产生共鸣，哪些容易引起矛盾？
        │   - 相处模式：日常互动中的默契与分歧，权力与付出的平衡
        │   - 沟通风格：各自的表达方式和需求理解方式，如何减少误解
        │   - 情感纽带：两人关系中的核心吸引力和深层连接
        │   - 潜在挑战：关系中可能遇到的考验，以及化解之道
        │   - 相处建议：如何增进理解、深化连接
        │
        │ 注意：不需要过多展开个人的大限、流年推演。分析应聚焦在两人之间的关系层面，
        │ 而非各自的个人运势。个人命盘特质仅作为分析互动模式的基础参考。
        │
        """

        let languageReminder: String
        switch language {
        case .simplifiedChinese:
            languageReminder = """
            │ └───────────────────────────────────────────

            请用清晰的Markdown格式输出分析结果，使用标题、列表、重点标注等格式。

            **重要：请确保整个输出使用简体中文。**

            **知识库引用要求（核心）**：请在分析过程中**深度依赖**知识库中的专业论述。每一个关键论断，都应尽量找到知识库中的理论支持。请大量引用经典著作中的术语和口诀，体现深厚的命理底蕴，拒绝泛泛而谈。

            最后，请务必提醒用户：**以上分析结果仅供研究和娱乐参考，不应作为人生重大决策的唯一依据。命运掌握在自己手中，积极努力才是改变人生的关键。**
            """
        case .traditionalChinese:
            languageReminder = """
            │ └───────────────────────────────────────────

            請用清晰的Markdown格式輸出分析結果，使用標題、列表、重點標註等格式。

            **重要：請確保整個輸出使用繁體中文。所有漢字必須使用繁體字書寫。**

            **知識庫引用要求（核心）**：請在分析過程中**深度依賴**知識庫中的專業論述。每一個關鍵論斷，都應盡量找到知識庫中的理論支持。請大量引用經典著作中的術語和口訣，體現深厚的命理底蘊，拒絕泛泛而談。

            最後，請務必提醒用戶：**以上分析結果僅供研究和娛樂參考，不應作為人生重大決策的唯一依據。命運掌握在自己手中，積極努力才是改變人生的關鍵。**
            """
        case .english:
            languageReminder = """
            │ └───────────────────────────────────────────

            Please output the analysis in clear Markdown format, using headings, lists, and emphasis where appropriate.

            **CRITICAL: The ENTIRE output MUST be in English. Do not use Chinese characters in the main text except when providing original terminology in parentheses.**

            **Knowledge Base Citation Requirement**: Please extensively reference the professional knowledge base during your analysis. The more you cite wisdom from classic texts, the more authoritative and profound the analysis will be.

            End with a disclaimer: **This analysis is for entertainment and reference purposes only and should not be the sole basis for major life decisions. Your destiny is in your own hands—positive effort is the key to changing your life.**
            """
        }

        requirements += languageReminder
        return requirements
    }

    // MARK: - Private Methods

    /// 获取语言相关的指令文本
    private static func getLanguageInstruction(language: AppLanguage) -> String {
        switch language {
        case .simplifiedChinese:
            return """

            # 语言要求

            请使用**简体中文**输出所有分析内容。确保用词准确、语句流畅，符合简体中文的表达习惯。

            """
        case .traditionalChinese:
            return """

            # 語言要求

            請使用**繁體中文**輸出所有分析內容。確保用詞準確、語句流暢，符合繁體中文的表達習慣。所有專業術語、宮位名稱、星曜名稱都應使用繁體字書寫。

            **用語習慣**：請盡量使用符合台灣、香港地區的用語習慣和表達方式，避免使用大陸地區特有的詞彙或語法結構。

            """
        case .english:
            return """

            # Language Requirement

            Please output ALL analysis content in **English**. This includes:
            - All explanations, interpretations, and advice
            - Section titles and headings
            - The disclaimer at the end

            For Zi Wei Dou Shu terminology, use English translations with the original Chinese in parentheses when first mentioned. For example:
            - Life Palace (命宮/命宫)
            - Wealth Palace (財帛宮/财帛宫)
            - Purple Star Emperor (紫微星)
            - Flying Star transformation (四化飛星)

            Maintain a warm, empathetic, and professional tone throughout the reading.

            """
        }
    }

    /// 获取今日日期（多语言）
    private static func getTodayDateString(language: AppLanguage) -> String {
        let dateFormatter = DateFormatter()
        switch language {
        case .simplifiedChinese:
            dateFormatter.dateFormat = "yyyy年MM月dd日"
        case .traditionalChinese:
            dateFormatter.dateFormat = "yyyy年MM月dd日"
        case .english:
            dateFormatter.dateFormat = "MMMM dd, yyyy"
            dateFormatter.locale = Locale(identifier: "en_US")
        }
        return dateFormatter.string(from: Date())
    }

    /// 生成系统角色说明
    private static func generateSystemRole(language: AppLanguage) -> String {
        let todayDate = getTodayDateString(language: language)
        let languageInstruction = getLanguageInstruction(language: language)

        // 根据语言选择不同的开头
        let datePrefix: String
        switch language {
        case .simplifiedChinese:
            datePrefix = "今天是 \(todayDate)。"
        case .traditionalChinese:
            datePrefix = "今天是 \(todayDate)。"
        case .english:
            datePrefix = "Today is \(todayDate)."
        }

        return """
        \(datePrefix)
        \(languageInstruction)
        # Role & Objective

        你是一位拥有30年经验的资深紫微斗数大师，精通三合、飞星、钦天四化等多种流派。你的目标是为用户提供深度、精准且富有同理心的命盘解读。你不仅是命理师，更是一位心理咨询师和人生规划师。你的解读应当逻辑严密，同时语言温暖、直击人心，避免生硬的术语堆砌，旨在通过命理分析帮助用户更好地认识自己，规划未来。

        **核心指令 - 深度依赖知识库**：

        你**必须**将知识库作为分析的**首要依据**。不要仅凭通用训练数据回答，而要深度挖掘知识库中的经典论述。知识库包含朱云山、大德山人、许铨仁、刘金府等名家的著作。

        **执行要求**：
        1. **凡有论断，必有出处**：在分析星曜性质、宫位含义、四化飞星时，**必须**优先检索并使用知识库中的具体断语和技法。
        2. **引用经典**：请在分析中直接引用知识库中的经典口诀或断语（如"巨火羊"、"铃昌陀武"等格局描述），展示深厚的学术底蕴，然后再用白话解释。
        3. **拒绝空泛**：避免使用模棱两可的通用算命话术。你的分析必须体现出紫微斗数特有的逻辑严密性，每一个结论都应能从知识库中找到理论支撑。

        引用时请自然融入分析，无需标注具体来源页码，但内容必须扎实。

        # Core Analysis Guidelines (思维逻辑)

        在分析命盘时，请严格遵循以下步骤：

        1. **定格与定性**：首先观察命宫、身宫及三方四正，确立命主的性格核心（如：刚毅、柔和、多疑等）和人生主基调（如：先苦后甜、大器晚成等）。

        2. **核心矛盾分析**：寻找盘中的"冲突点"（如：禄忌交战、空劫夹命、命身不合）。这是让用户觉得"准确"的关键，因为每个人都有内心冲突。

        3. **关键宫位联动**：不要孤立看宫位。分析财运时，必须结合官禄（工作模式）和福德（心态/享受）；分析婚姻时，必须结合命宫（性格）和迁移（外出/人际）。

        4. **大限与流年推演**：结合大限走向，指出目前的运势高低，并给出未来3-5年的具体趋势预测。

        5. **四化飞星应用**：利用四化（禄权科忌）寻找因果关系。例如：为什么财帛宫化忌冲父母？解释背后的现实意义（如：因钱财问题与长辈不和，或需承担家庭重担）。

        # Tone & Style Guidelines (风格与温度)

        1. **既专业又通俗**：使用专业术语（如"化忌"、"空宫"）后，必须紧跟一句通俗、形象的比喻或现实场景描述。

           * *Bad:* 你的财帛宫化忌。

           * *Good:* 你的财帛宫化忌，这意味着你对钱财有一种近乎执着的掌控欲，或者说，每一分钱你都希望花在刀刃上，但这反而让你在花钱时容易感到焦虑。

        2. **巴纳姆效应 (Barnum Effect) 的高级应用**：

           a) **双面性人格刻画**：每个人都是矛盾的综合体。：

           b) **条件化触发器**：使用情境限定让描述更真实：
              - "当你真正信任一个人的时候，你会..."
              - "在压力之下，你倾向于..."
              - "独处时，你常常会思考..."

           c) **潜意识挖掘**：揭示用户可能从未意识到、但一说就"恍然大悟"的特质：
              - "你可能自己都没意识到，你其实非常在意别人怎么看你"
              - "在你潇洒的外表下，藏着一个追求完美的灵魂"

           d) **未被理解的共鸣**：几乎每个人都觉得自己不被完全理解：
              - "你常常觉得身边的人并不真正懂你"
              - "你有一面是很少对人展示的"

           e) **共性的深层渴望与恐惧**：
              - 渴望：被认可、被爱、有意义、自由、安全
              - 恐惧：被抛弃、被否定、失控、平庸、孤独

        3. **同理心与建设性**：面对凶星（如空劫、羊陀），不要恐吓用户。要将其解释为一种"磨砺"或"特殊的才华"，并给出化解之道。

           * *Bad:* 你婚姻宫有地空，注定离婚。

           * *Good:* 你的感情世界比较追求精神契合，普通的柴米油盐可能让你感到乏味。这可能导致感情路上的孤独感，但只要找到那个能懂你精神世界的人，这种"空"就会转化为深层的默契。

        4. **直接且真诚**：像一位老朋友一样说话，不仅给出分析，还要给出"如果是我，我会怎么做"的具体建议。


        # Constraints

        - 严禁输出纯粹的古文断语而不做解释。

        - 遇到敏感话题（健康重症、死亡预测）需委婉处理，侧重于养生和预防。

        - 始终保持鼓励和赋能的态度。

        - **不要在输出中提及"30年经验"、"篇幅应占30%"等Prompt中的指令性描述

        紫微斗数命盘信息如下：

        """
    }

    /// 生成基本信息部分
    private static func generateBasicInfo(birthInfo: BirthInfo, chart: ZiWeiChart) -> String {
        // 使用日期部分 + 用户选择的时间
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFormatter.string(from: birthInfo.solarDate)
        let timeStr = String(format: "%02d:%02d", birthInfo.birthHour, birthInfo.birthMinute)
        let solarDateStr = "\(dateStr) \(timeStr)"

        // 计算真太阳时（与排盘逻辑保持一致，包含EOT校正）
        let trueSolarTime: String
        if birthInfo.useRealSolarTime {
            let (h, m) = SolarTimeCalculator.calculateTrueSolarTime(date: birthInfo.solarDate, hour: birthInfo.birthHour, minute: birthInfo.birthMinute, longitude: birthInfo.longitude)
            trueSolarTime = String(format: "%@ %02d:%02d", dateStr, h, m)
        } else {
            trueSolarTime = solarDateStr
        }

        var info = """
        ├基本信息
        │
        │ ├性别 : \(birthInfo.gender.rawValue)
        │ ├地理经度 : \(String(format: "%.3f", birthInfo.longitude))
        │ ├钟表时间 : \(solarDateStr)
        │ ├真太阳时 : \(trueSolarTime)
        """

        // 添加农历信息
        if let lunar = birthInfo.lunarDate {
            info += "\n│ ├农历时间 : \(lunar.displayString) \(birthInfo.birthTime)"
        }

        info += """

        │ ├出生地点 : \(birthInfo.location)
        │ ├五行局数 : \(chart.fiveElementBureau)
        │ └身主:\(chart.bodyMaster); 命主:\(chart.lifeMaster); 命宫:\(chart.mingPalace.rawValue); 身宫:\(chart.bodyPalace.rawValue)
        │
        """

        return info
    }

    /// 生成十二宫详细信息
    private static func generatePalacesInfo(chart: ZiWeiChart) -> String {
        var info = """
        ├命盘十二宫
        │
        """

        // 按照命盘顺序排列宫位
        let sortedPalaces = chart.palaces.sorted { $0.position < $1.position }

        for palace in sortedPalaces {
            info += generateSinglePalaceInfo(palace: palace, chart: chart)
        }

        return info
    }

    /// 生成单个宫位的详细信息
    private static func generateSinglePalaceInfo(palace: Palace, chart: ZiWeiChart) -> String {
        var info = "│ ├\(palace.name.rawValue)[\(palace.heavenlyStem ?? "")\(palace.earthlyBranch)]"

        // 标注身宫
        if palace.isBodyPalace {
            info += "[身宫]"
        }

        // 标注来因宫
        if isLaiYinPalace(palace: palace, chart: chart) {
            info += "[来因]"
        }

        // Resolve relationships first
        let oppositeIndex: Int
        let careerIndex: Int
        let wealthIndex: Int

        if let rel = palace.relationships, rel.oppositeIndex != -1 {
            oppositeIndex = rel.oppositeIndex
            careerIndex = rel.careerIndex
            wealthIndex = rel.wealthIndex
        } else {
            // Fallback calculation
            oppositeIndex = (palace.position + 6) % 12
            careerIndex = (palace.position + 4) % 12
            wealthIndex = (palace.position + 8) % 12
        }

        info += "\n"

        // 主星
        let majorStars = palace.stars.filter { $0.type == .major }
        if !majorStars.isEmpty {
            let starsStr = majorStars.map { formatStar($0) }.joined(separator: ",")
            info += "│ │ ├主星 : \(starsStr)\n"
        } else {
            // 空宫：借对宫星曜
            if let oppositePalace = chart.palaces.first(where: { $0.position == oppositeIndex }) {
                let borrowedStars = oppositePalace.stars.filter { $0.type == .major }
                if !borrowedStars.isEmpty {
                    let starsStr = borrowedStars.map { formatStar($0) }.joined(separator: ",")
                    info += "│ │ ├主星 : 无 (需借对宫[\(oppositePalace.name.rawValue)]星曜: \(starsStr))\n"
                } else {
                    info += "│ │ ├主星 : 无 (对宫亦无主星)\n"
                }
            } else {
                info += "│ │ ├主星 : 无\n"
            }
        }

        // 辅星（吉星和煞星）
        let supportStars = palace.stars.filter { $0.type == .support || $0.type == .jiXing || $0.type == .shaXing }
        if !supportStars.isEmpty {
            let starsStr = supportStars.map { formatStar($0) }.joined(separator: ",")
            info += "│ │ ├辅星 : \(starsStr)\n"
        }

        // 杂曜
        let minorStars = palace.stars.filter { $0.type == .minor }
        if !minorStars.isEmpty {
            let starsStr = minorStars.map { formatStar($0) }.joined(separator: ",")
            info += "│ │ ├小星 : \(starsStr)\n"
        }

        // 三方四正 (Three Directions and Four Squares)
        // Indices already resolved above

        // Helper to format stars short (inner function not allowed here easily, using inline closure or just code)
        let formatStarsShort: ([Star]) -> String = { stars in
            // 筛选重要星曜：主星、四化星、禄存
            // 这些是判断格局和暗合力量的核心
            let importantStars = stars.filter { star in
                star.type == .major ||
                star.fourTransform != nil ||
                star.name == "禄存"
            }

            if importantStars.isEmpty { return "无重要星" }

            return importantStars.map { star in
                var s = star.name
                if let m = star.fourTransform { s += "[\(m.rawValue)]" }
                return s
            }.joined(separator: ",")
        }

        let opposite = chart.palaces.first { $0.position == oppositeIndex }
        let career = chart.palaces.first { $0.position == careerIndex }
        let wealth = chart.palaces.first { $0.position == wealthIndex }

        if let opp = opposite, let car = career, let wea = wealth {
            info += "│ │ ├三方四正 (San Fang Si Zheng):\n"
            info += "│ │ │ ├对宫[\(opp.name.rawValue)] : \(formatStarsShort(opp.stars))\n"
            info += "│ │ │ ├财位[\(wea.name.rawValue)] : \(formatStarsShort(wea.stars))\n"
            info += "│ │ │ └官位[\(car.name.rawValue)] : \(formatStarsShort(car.stars))\n"
        }

        // 暗合宫 (Hidden Agreement / Liu He)
        // 计算公式：基于地支六合 (寅0-亥9, 卯1-戌8, ..., 子10-丑11)
        let darkIndex = (palace.position < 10) ? (9 - palace.position) : (21 - palace.position)
        if let darkPalace = chart.palaces.first(where: { $0.position == darkIndex }) {
             info += "│ │ ├暗合宫 (Hidden Agreement): [\(darkPalace.name.rawValue)] - \(formatStarsShort(darkPalace.stars))\n"
        }

        // 长生十二神 & 博士十二神
        if let changsheng = palace.changsheng12, !changsheng.isEmpty {
             info += "│ │ ├长生十二神 : \(changsheng)\n"
        }
        if let boshi = palace.boshi12, !boshi.isEmpty {
             info += "│ │ ├博士十二神 : \(boshi)\n"
        }

        // 自化
        if let selfMutations = palace.selfMutations, !selfMutations.isEmpty {
             let smStr = selfMutations.map { sm in
                if let star = sm.star {
                    return "\(star)自化\(sm.type.rawValue)"
                } else {
                    return "自化\(sm.type.rawValue)"
                }
             }.joined(separator: ", ")
             info += "│ │ ├自化 (Self-Hua) : \(smStr)\n"
        }

        // 飞星 (Flying Stars) - 核心因果逻辑
        if let flyingStars = palace.flyingStars, !flyingStars.isEmpty {
            // 按照 禄-权-科-忌 的顺序排序，方便阅读
            let sortedFlying = flyingStars.sorted { (a, b) -> Bool in
                let order: [FourTransformType] = [.lu, .quan, .ke, .ji]
                let idxA = order.firstIndex(of: a.type) ?? 99
                let idxB = order.firstIndex(of: b.type) ?? 99
                return idxA < idxB
            }

            let flyStr = sortedFlying.map { fly in
                return "\(fly.type.rawValue)入\(fly.toPalaceName)[\(fly.star)]"
            }.joined(separator: "; ")

            info += "│ │ ├飞星 (Flying Stars) : \(flyStr)\n"
        }

        // 大限信息
        if let majorLimit = palace.majorLimit {
            info += "│ │ ├大限 : \(majorLimit)\n"
        }

        // 宫位说明
        info += "│ │ └说明 : \(palace.name.description)\n"
        info += "│ │\n"

        return info
    }

    /// 格式化星曜显示
    private static func formatStar(_ star: Star) -> String {
        var result = star.name

        // 添加亮度
        if let brightness = star.brightness, !brightness.isEmpty {
            result += "[\(brightness)]"
        }

        // 添加四化
        if let transform = star.fourTransform {
            result += "[\(transform.rawValue)]"
        }

        return result
    }

    /// 判断是否为来因宫
    private static func isLaiYinPalace(palace: Palace, chart: ZiWeiChart) -> Bool {
        // 来因宫是由出生年的天干决定的，与生年天干同宫干的宫位即为来因宫
        // 获取出生年的天干（取第一个字）
        guard !chart.birthYear.isEmpty, let yearStem = chart.birthYear.first else {
            return false
        }

        // 检查当前宫位的天干是否与生年天干相同
        // 注意：palace.heavenlyStem 是字符串，如 "甲"
        if let palaceStem = palace.heavenlyStem {
            return palaceStem == String(yearStem)
        }

        return false
    }

    /// 生成大限流年信息 (集成动态流年数据)
    private static func generateMajorLimitsInfo(chart: ZiWeiChart, birthInfo: BirthInfo, yearlyFlows: [YearlyFlowContext]? = nil) -> String {
        var info = """
        │
        ├大限流年信息
        │
        │ 前八个大限：
        """

        let majorLimitsToAnalyze = Array(chart.majorLimits.prefix(8))

        // 计算出生年份，用于反推流年
        let calendar = Calendar.current
        let birthYear = calendar.component(.year, from: birthInfo.solarDate)

        for (index, limit) in majorLimitsToAnalyze.enumerated() {
            // 计算大限叠宫 (Decadal Overlap)
            // limit.earthlyBranch 是大限命宫的地支 (如 "子")
            // 我们需要找到本命盘中，地支也是 "子" 的那个宫位
            var overlapDesc = ""
            if let overlayPalace = chart.palaces.first(where: { $0.earthlyBranch == limit.earthlyBranch }) {
                // 增强描述：带上天干，明确“气”的变化
                // 例如：大限命宫在"子"，本命"夫妻宫"也在"子" -> "大限命 叠 本夫妻"
                let stem = overlayPalace.heavenlyStem ?? ""
                overlapDesc = " [大限命 叠 本\(overlayPalace.name.shortName)(\(stem)\(limit.earthlyBranch))]"
            }

            info += "\n│ ├第\(index + 1)大限 : \(limit.ageRange) - \(limit.palace.rawValue)[\(limit.earthlyBranch)]\(overlapDesc)"

            // 在大限下展示属于该大限的流年信息
            if let flows = yearlyFlows {
                // 筛选属于该大限的流年数据
                // 大限年龄范围通常是虚岁。流年年份对应的虚岁 = 流年年份 - 出生年份 + 1
                let matchingFlows = flows.filter { flow in
                    let nominalAge = flow.year - birthYear + 1
                    return nominalAge >= limit.startAge && nominalAge <= limit.endAge
                }

                // Display Decadal Four Transforms (from the first matching flow)
                if let firstFlow = matchingFlows.first, !firstFlow.decadalMutagens.isEmpty && firstFlow.decadalMutagens.count >= 4 {
                     let lu = firstFlow.decadalMutagens[0]
                     let quan = firstFlow.decadalMutagens[1]
                     let ke = firstFlow.decadalMutagens[2]
                     let ji = firstFlow.decadalMutagens[3]
                     info += " [本限四化: 禄:\(lu), 权:\(quan), 科:\(ke), 忌:\(ji)]"
                }

                if !matchingFlows.isEmpty {
                    for flow in matchingFlows {
                        let nominalAge = flow.year - birthYear + 1

                        // 计算流年叠宫 (Yearly Overlap)
                        // flow.yearlyBranch 即为流年地支 (如 "辰")
                        // 找到本命盘中地支为 "辰" 的宫位
                        var yearlyOverlap = ""
                        if let overlayPalace = chart.palaces.first(where: { $0.earthlyBranch == flow.yearlyBranch }) {
                             // 例如：流年命宫在"辰"，本命"财帛宫"也在"辰" -> "流命 叠 本财帛"
                             yearlyOverlap = " [流命 叠 本\(overlayPalace.name.shortName)]"
                        }

                        info += "\n│ │ └ \(flow.year)年 (\(flow.yearlyStem)\(flow.yearlyBranch)) [\(nominalAge)岁]:\(yearlyOverlap)"

                        // Display Yearly Four Transforms
                        if !flow.yearlyMutagens.isEmpty && flow.yearlyMutagens.count >= 4 {
                            let lu = flow.yearlyMutagens[0]
                            let quan = flow.yearlyMutagens[1]
                            let ke = flow.yearlyMutagens[2]
                            let ji = flow.yearlyMutagens[3]
                            info += " [流四化: 禄:\(lu), 权:\(quan), 科:\(ke), 忌:\(ji)]"
                        }

                        // 遍历所有宫位，提取有重要流耀的宫位
                        // 过滤出重要的流耀，避免信息过载
                        // 比如只显示：流禄、流权、流科、流忌、流羊、流陀、流魁、流钺、流昌、流曲
                        let importantStarKeywords = ["流禄", "流权", "流科", "流忌", "流羊", "流陀", "流魁", "流钺", "流昌", "流曲"]

                        var importantPalaces: [String] = []

                        // 按地支顺序遍历宫位 (保证顺序一致性)
                        // Merge keys from stars and gods
                        var allPalaceNames = Set(flow.stars.keys)
                        if let godKeys = flow.yearlyGods?.keys {
                            allPalaceNames.formUnion(godKeys)
                        }
                        let palaceNames = allPalaceNames.sorted()

                        for palaceName in palaceNames {
                            var items: [String] = []

                            // Stars
                            if let stars = flow.stars[palaceName], !stars.isEmpty {
                                let importantStars = stars.filter { name in
                                    importantStarKeywords.contains { keyword in name.contains(keyword) }
                                }
                                if !importantStars.isEmpty {
                                    items.append(contentsOf: importantStars)
                                }
                            }

                            // Gods
                            if let gods = flow.yearlyGods?[palaceName], !gods.isEmpty {
                                items.append(contentsOf: gods)
                            }

                            if !items.isEmpty {
                                importantPalaces.append("\(palaceName): \(items.joined(separator: ","))")
                            }
                        }

                        if !importantPalaces.isEmpty {
                            info += " " + importantPalaces.joined(separator: "; ")
                        } else {
                            info += " (无特殊流耀)"
                        }
                    }
                }
            }
        }

        info += "\n│\n│ 请对前八个大限的所有流年进行分析，结合上述动态星象数据，给出每一年需要关注的重大事件和注意事项。\n│\n"

        return info
    }

    /// 生成分析要求
    private static func generateAnalysisRequirements(topic: AnalysisTopic, language: AppLanguage) -> String {
        var requirements = """
        ├分析要求
        │
        │ 本次分析的主题是：【\(topic.rawValue)】
        │ 请按照以下结构进行重点分析：
        │
        """

        switch topic {
        case .overall:
            requirements += """
            │ 请确保涵盖以下深度内容：
            │
            │ 1. **性格深层剖析**（重点！篇幅应占全文30%以上）：
            │
            │    A. 【人格底色】命宫主星决定的核心人格
            │       - 用2-3个精准的词汇定义其人格基调
            │       - 这种人格在生活中如何具体表现
            │
            │    B. 【隐藏的另一面】身宫或对宫揭示的潜意识人格
            │       - 用户"私下里"或"内心深处"的另一面是什么
            │       - 这一面何时会被触发
            │       - 使用"你可能自己都没意识到，但你其实..."的句式
            │
            │    C. 【内心的矛盾与冲突】
            │       - 基于盘中的禄忌对冲、空劫夹等格局
            │       - 描述内心两股力量的拉扯（如：追求自由 vs 渴望安全）
            │       - 解释这种冲突如何影响其决策模式
            │
            │    D. 【独特的天赋与才华】
            │       - 化禄/化权/化科所在宫位对应的天赋
            │       - 这种天赋在什么情境下能发挥到极致
            │
            │    E. 【性格的痛点与软肋】
            │       - 化忌/煞星揭示的性格脆弱处
            │       - 什么类型的事情最容易让TA感到受伤或焦虑
            │       - 如何自我保护与疗愈
            │
            │    F. 【人际互动模式】
            │       - 在亲密关系中的表现
            │       - 面对陌生人 vs 熟人的差异
            │       - 在团队协作中扮演的角色
            │
            │    G. 【压力下的反应模式】
            │       - 面对压力时倾向于战斗/逃避/僵住
            │       - 情绪低落时的自我调节方式
            │
            │    H. 【未被理解的渴望】
            │       - 揭示TA内心深处真正想要的是什么
            │       - 为什么TA总觉得"别人不完全理解我"
            │       - 如何表达能让TA感到被真正看见
            │
            │ 2. **事业与财富运势**：
            │    - 结合性格特质，定性事业格局与财富层级。
            │    - 给出核心职业赛道建议与理财风控提示。
            │
            │ 3. **情感与人际关系**：
            │    - 分析感情模式与宿命剧本。
            │    - 提及贵人运与人际互动。
            │
            │ 4. **运程推演**：
            │    - 重点分析当前大限的吉凶主旋律。
            │    - 扫描未来3-5年的关键流年。
            │
            │ 5. **专家锦囊**：
            │    - 给出3条具体的改运造命建议。
            """

        case .career:
            requirements += """
            │ 一、事业格局深度分析（核心）
            │   1. 官禄宫与命宫详批
            │      - 分析官禄宫主星、辅星及四化，判断事业格局高低
            │      - 结合命宫三方四正，分析个人能力与事业的匹配度
            │   2. 适合的职业方向
            │      - 基于星曜特质推荐具体行业和职能
            │      - 分析适合创业、公职、还是企业任职
            │      - 潜在的副业或第二职业机会
            │   3. 职场人际与管理能力
            │      - 与上司、同事、下属的相处模式
            │      - 领导力与执行力分析
            │      - 职场贵人运与小人防范
            │
            │ 二、事业运势起伏
            │   - 分析大限官禄宫的变化，指出事业发展的黄金期
            │   - 结合近十年流年，预测升职加薪或变动的关键年份
            │   - 警惕事业低谷期和潜在风险
            │
            │ 三、财官互动分析
            │   - 结合财帛宫，分析工作带来的收入情况
            │   - 事业对个人社会地位的影响
            │
            │ 四、针对性建议
            │   - 职业规划的具体步骤
            │   - 提升职场竞争力的策略
            │   - 近期事业决策建议
            """

        case .wealth:
            requirements += """
            │ 一、财运格局深度分析（核心）
            │   1. 财帛宫与田宅宫详批
            │      - 分析财帛宫星曜，判断理财能力与消费观念
            │      - 分析田宅宫，判断不动产运势与守财能力
            │      - 结合福德宫，分析财源是否深厚
            │   2. 财富来源分析
            │      - 正财运（工作收入）vs 偏财运（投资/意外之财）
            │      - 适合的求财方式（技术、管理、口才、冒险等）
            │      - 合作求财还是独立求财
            │
            │ 二、财运周期趋势分析
            │   - 分析大限财帛宫的变化，指出财富积累的爆发期
            │   - 结合近十年流年，分析进财与破财的关键年份
            │   - 特别警惕投资陷阱和破财风险
            │
            │ 三、投资与理财建议
            │   - 适合的投资领域（股票、房产、实业等）
            │   - 风险承受能力评估
            │   - 具体的守财与增值策略
            │
            │ 四、综合建议
            │   - 提升财运的风水或行为建议
            │   - 近期财务决策指导
            """

        case .love:
            requirements += """
            │ 一、感情婚姻格局深度分析（核心）
            │   1. 夫妻宫与命宫详批
            │      - 分析夫妻宫主星、辅星，判断伴侣特质与相处模式
            │      - 结合命宫与福德宫，分析个人对感情的态度与需求
            │      - 桃花星分布（红鸾、天喜、咸池、天姚等）分析
            │   2. 伴侣特征画像
            │      - 预测伴侣的性格、外貌、职业方向
            │      - 伴侣与你的互动关系（互补、相似、刑克）
            │      - 理想的伴侣类型建议
            │
            │ 二、感情运势起伏
            │   - 分析大限夫妻宫，指出建立长期关系、结婚或感情危机的关键时期
            │   - 结合流年红鸾/天喜，预测脱单或婚嫁年份
            │   - 警惕烂桃花与感情纠纷
            │
            │ 三、感情经营建议
            │   - 双方可能存在的矛盾点及化解之道
            │   - 提升感情质量的沟通技巧
            │   - 适合的相处距离与模式
            │
            │ 四、子女缘分简述
            │   - 结合子女宫，简述子女缘分对婚姻的影响
            │
            │ 五、针对性建议
            │   - 单身者脱单攻略
            │   - 已婚者婚姻保鲜建议
            """

        case .health:
            requirements += """
            │ 一、健康体质深度分析（核心）
            │   1. 疾厄宫与命宫详批
            │      - 分析疾厄宫星曜，判断先天体质强弱
            │      - 结合命宫，分析性格对健康的影响
            │   2. 易患疾病预测
            │      - 根据五行与星曜性质，指出身体最脆弱的系统（呼吸、消化、心脑血管等）
            │      - 分析潜在的慢性病风险
            │   3. 意外伤害防范
            │      - 结合迁移宫，分析外出意外风险
            │
            │ 二、健康运势起伏
            │   - 分析大限疾厄宫，指出身体机能变化的关键时期
            │   - 结合流年，预测需要特别注意健康的年份
            │
            │ 三、养生与保健建议
            │   - 适合的运动方式与饮食习惯
            │   - 心理健康调节建议
            │   - 适合的就医方向（中医/西医）与方位
            │
            │ 四、综合建议
            │   - 改善体质的具体行动方案
            │   - 年度健康检查重点
            """

        case .yearFortune:
            requirements += """
            │ 一、本年流年总体运势（核心）
            │   1. 流年命宫详批
            │      - 分析流年命宫主星、辅星及四化
            │      - 判断今年整体气场（顺遂、动荡、压抑、突破）
            │   2. 关键领域运势
            │      - 流年事业：升迁、变动、压力
            │      - 流年财运：进财、破财、投资
            │      - 流年感情：桃花、争吵、结婚
            │      - 流年健康：疾病、意外
            │
            │ 二、流月运势扫描
            │   - 简要扫描今年运势波动较大的月份（吉或凶）
            │   - 指出需要特别谨慎的月份
            │
            │ 三、吉凶祸福与关键事件
            │   - 预测今年可能发生的重大事件
            │   - 贵人方位与小人防范
            │
            │ 四、趋吉避凶建议
            │   - 针对今年的具体行动指南
            │   - 心态调整建议
            │   - 关键决策的参考意见
            """

        case .fiveElements:
            requirements += """
            │ 本次分析主题是：【八字五行分析】
            │
            │ 重要：请根据上方提供的出生信息（阳历日期、真太阳时、农历日期、出生地点），
            │ 自行推算此人的四柱八字（年柱、月柱、日柱、时柱），每柱包含天干和地支。
            │
            │ 一、八字排盘（核心基础）
            │   1. 四柱推算
            │      - 根据出生的阳历/农历日期和真太阳时，推算年柱、月柱、日柱、时柱
            │      - 明确标注每柱的天干和地支（如：甲子、乙丑等）
            │      - 标注日主（日柱天干）及其五行属性（如：壬水、丁火等）
            │   2. 五行统计
            │      - 八字中金、木、水、火、土各有几个
            │      - 标注天干五行和地支藏干五行的完整分布
            │      - 判断五行的旺衰强弱
            │
            │ 二、日主分析
            │   - 日主的五行属性及特质（如壬水为阳水，主智慧流动等）
            │   - 日主在当令的旺衰状态（得令/失令、得地/失地、得势/失势）
            │   - 日主的身强身弱判断及依据
            │
            │ 三、喜用神与忌神分析
            │   - 根据日主强弱和八字格局，推断喜用神（需要补充的五行）
            │   - 分析忌神五行（过旺需要克制的五行）
            │   - 阐述喜用神对命主的具体助益
            │
            │ 四、十神关系分析
            │   - 分析八字中的十神配置（正官、偏官、正印、偏印、食神、伤官等）
            │   - 十神对命主性格和运势的影响
            │
            │ 五、五行开运建议
            │   - 根据喜用五行推荐有利的颜色、方位、行业
            │   - 日常可佩戴或摆放的五行开运物
            │   - 饮食、运动等生活方式的五行调理建议
            │   - 四季养生重点（春木/夏火/长夏土/秋金/冬水）
            """
        }

        // 添加语言特定的结尾说明
        let languageReminder: String
        switch language {
        case .simplifiedChinese:
            languageReminder = """
            │
            │ └───────────────────────────────────────────

            请用清晰的Markdown格式输出分析结果，使用标题、列表、重点标注等格式。

            **重要：请确保整个输出使用简体中文。**

            **知识库引用要求（核心）**：请在分析过程中**深度依赖**知识库中的专业论述。每一个关键论断，都应尽量找到知识库中的理论支持（如星曜特性、格局断语、四化技法）。请大量引用经典著作中的术语和口诀，体现深厚的命理底蕴，拒绝泛泛而谈。

            最后，请务必提醒用户：**以上分析结果仅供研究和娱乐参考，不应作为人生重大决策的唯一依据。命运掌握在自己手中，积极努力才是改变人生的关键。**
            """
        case .traditionalChinese:
            languageReminder = """
            │
            │ └───────────────────────────────────────────

            請用清晰的Markdown格式輸出分析結果，使用標題、列表、重點標註等格式。

            **重要：請確保整個輸出使用繁體中文。所有漢字必須使用繁體字書寫。**

            **知識庫引用要求（核心）**：請在分析過程中**深度依賴**知識庫中的專業論述。每一個關鍵論斷，都應盡量找到知識庫中的理論支持（如星曜特性、格局斷語、四化技法）。請大量引用經典著作中的術語和口訣，體現深厚的命理底蘊，拒絕泛泛而談。

            最後，請務必提醒用戶：**以上分析結果僅供研究和娛樂參考，不應作為人生重大決策的唯一依據。命運掌握在自己手中，積極努力才是改變人生的關鍵。**
            """
        case .english:
            languageReminder = """
            │
            │ └───────────────────────────────────────────

            Please output the analysis in clear Markdown format, using headings, lists, and emphasis where appropriate.

            **CRITICAL: The ENTIRE output MUST be in English. Do not use Chinese characters in the main text except when providing original terminology in parentheses.**

            **Knowledge Base Citation Requirement**: Please extensively reference the professional knowledge base during your analysis, including star characteristics, pattern interpretations, and Four Transformations techniques. The more you cite wisdom from classic texts, the more authoritative and profound the analysis will be.

            End with a disclaimer: **This analysis is for entertainment and reference purposes only and should not be the sole basis for major life decisions. Your destiny is in your own hands—positive effort is the key to changing your life.**
            """
        }

        requirements += languageReminder

        return requirements
    }

}
