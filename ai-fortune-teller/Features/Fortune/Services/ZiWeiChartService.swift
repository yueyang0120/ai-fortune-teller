import Foundation
import JavaScriptCore

enum ZiWeiChartError: Error, LocalizedError {
    case jsContextInitFailed
    case jsLibraryLoadFailed
    case jsExecutionFailed(String)
    case dataParsingFailed
    case invalidBirthInfo

    var errorDescription: String? {
        switch self {
        case .jsContextInitFailed:
            return "JavaScript 上下文初始化失败"
        case .jsLibraryLoadFailed:
            return "无法加载 iztro JavaScript 库"
        case .jsExecutionFailed(let message):
            return "JavaScript 执行失败: \(message)"
        case .dataParsingFailed:
            return "命盘数据解析失败"
        case .invalidBirthInfo:
            return "出生信息无效"
        }
    }
}
// Struct to hold yearly flow context (for internal passing or return)
struct YearlyFlowContext: Codable {
    let year: Int
    let yearlyStem: String // 流年天干
    let yearlyBranch: String // 流年地支
    let stars: [String: [String]] // PalaceName -> [Star Names]
    let yearlyMutagens: [String] // [Lu, Quan, Ke, Ji]
    let decadalMutagens: [String] // [Lu, Quan, Ke, Ji]
    let yearlyGods: [String: [String]]? // PalaceName -> [God Names]
}

class ZiWeiChartService {
    private var jsContext: JSContext?
    private var isLibraryLoaded = false

    init() {
        setupJavaScriptContext()
    }

    private func setupJavaScriptContext() {
        jsContext = JSContext()

        guard let context = jsContext else {
            print("❌ Failed to create JSContext")
            return
        }

        // 设置异常处理
        context.exceptionHandler = { context, exception in
            print("❌ JS Exception: \(exception?.toString() ?? "Unknown error")")
        }

        // 添加 console.log 支持
        let consoleLog: @convention(block) (String) -> Void = { message in
            print("🟦 JS: \(message)")
        }
        context.setObject(consoleLog, forKeyedSubscript: "consoleLog" as NSString)
        context.evaluateScript("var console = { log: consoleLog }")

        // 为 JavaScriptCore 添加浏览器环境的全局变量
        // iztro 库需要这些变量来正确运行
        context.evaluateScript("""
            var self = this;
            var window = this;
            var global = this;
            var globalThis = this;
        """)

        // 加载 iztro 库
        loadIztroLibrary()
    }

    private func loadIztroLibrary() {
        guard let context = jsContext else {
            print("❌ JSContext is nil")
            return
        }

        // 尝试加载 iztro.bundle.js
        guard let jsPath = Bundle.main.path(forResource: "iztro.bundle", ofType: "js"),
              let jsCode = try? String(contentsOfFile: jsPath, encoding: .utf8) else {
            print("❌ Failed to load iztro.bundle.js - file not found or not readable")
            print("⚠️ Please run './download-iztro.sh' to download the library")
            return
        }

        // 设置模块环境
        context.evaluateScript("""
            var module = { exports: {} };
            var exports = module.exports;
        """)

        // 加载库
        context.evaluateScript(jsCode)

        // 调试：检查 iztro 的实际结构
        let debugScript = """
            (function() {
                var result = {};

                // 检查全局 iztro
                result.globalIztro = typeof iztro;

                // 检查 module.exports
                result.moduleExports = typeof module.exports;
                result.moduleExportsKeys = module.exports ? Object.keys(module.exports).join(',') : 'none';

                // 检查是否有 astro 函数
                if (typeof module.exports === 'object') {
                    result.hasAstro = typeof module.exports.astro === 'function';
                    result.hasAstrolabe = typeof module.exports.astrolabe === 'function';
                }

                return JSON.stringify(result);
            })();
        """

        if let debugResult = context.evaluateScript(debugScript)?.toString() {
            print("🔍 Debug iztro structure: \(debugResult)")
        }

        // 尝试多种方式访问 iztro
        let setupScript = """
            // 方式1: 直接从全局
            if (typeof iztro === 'undefined') {
                // 方式2: 从 module.exports
                if (typeof module !== 'undefined' && module.exports) {
                    if (typeof module.exports.astro === 'function' || typeof module.exports.astrolabe === 'function') {
                        var iztro = module.exports;
                    } else if (typeof module.exports.default !== 'undefined') {
                        var iztro = module.exports.default;
                    } else {
                        // 整个 module.exports 就是 iztro
                        var iztro = module.exports;
                    }
                }
            }

            // 验证并创建统一接口
            if (typeof iztro !== 'undefined') {
                // 如果 iztro 本身就是 astro 函数
                if (typeof iztro.astro === 'function') {
                    // 已经是正确的结构
                } else if (typeof iztro.astrolabe === 'function') {
                    // iztro 直接包含 astrolabe 函数
                    iztro = { astro: iztro };
                } else if (typeof iztro === 'function') {
                    // iztro 本身是一个函数，可能是 astro
                    iztro = { astro: iztro };
                }
            }

            typeof iztro !== 'undefined'
        """

        if let isLoaded = context.evaluateScript(setupScript)?.toBool(), isLoaded {
            isLibraryLoaded = true
            print("✅ iztro library loaded successfully")
        } else {
            print("❌ Failed to load iztro library")
        }
    }

    func generateChart(from birthInfo: BirthInfo) async throws -> ZiWeiChart {
        guard let context = jsContext else { throw ZiWeiChartError.jsContextInitFailed }
        guard isLibraryLoaded else { throw ZiWeiChartError.jsLibraryLoadFailed }

        let jsCode = try prepareJSCode(birthInfo: birthInfo)

        // 执行 JavaScript
        guard let resultValue = context.evaluateScript(jsCode),
              !resultValue.isUndefined,
              let resultString = resultValue.toString() else {
            throw ZiWeiChartError.jsExecutionFailed("No result returned")
        }

        print("🔍 JS Result length: \(resultString.count) characters")

        // 解析结果
        guard let resultData = resultString.data(using: .utf8) else {
            throw ZiWeiChartError.dataParsingFailed
        }

        do {
            let jsonObject = try JSONSerialization.jsonObject(with: resultData) as? [String: Any]

            // 检查是否有错误
            if let error = jsonObject?["error"] as? String {
                throw ZiWeiChartError.jsExecutionFailed(error)
            }

            // 解析命盘数据
            let chart = try parseChartData(jsonObject: jsonObject, birthInfo: birthInfo, rawJSON: resultString)

            print("✅ Chart generated successfully")
            return chart

        } catch {
            print("❌ Parsing error: \(error)")
            throw ZiWeiChartError.dataParsingFailed
        }
    }

    // 新增：生成特定年份的流年上下文（包含该年流耀）
    func generateYearlyFlowContext(birthInfo: BirthInfo, year: Int) async throws -> YearlyFlowContext {
        guard let context = jsContext else { throw ZiWeiChartError.jsContextInitFailed }
        guard isLibraryLoaded else { throw ZiWeiChartError.jsLibraryLoadFailed }

        // 1. Prepare Astro object JS code (reuse logic, but do not return JSON yet)
        let baseJsCode = try prepareJSCode(birthInfo: birthInfo, returnVariable: false)

        // 2. Call horoscope for specific year
        // Using a date in that year, e.g. June 15th
        let targetDateStr = "\(year)-06-15"

        let script = """
        (function() {
            try {
                \(baseJsCode)

                // 'astrolabe' variable is now available from baseJsCode
                // Call horoscope for the target year
                var horoscope = astrolabe.horoscope('\(targetDateStr)');

                // Extract yearly stars
                var yearlyData = horoscope.yearly;
                var decadalData = horoscope.decadal;
                var palaces = astrolabe.palaces;

                // Map palace index to stars
                var result = {
                    year: \(year),
                    yearlyStem: yearlyData.heavenlyStem,
                    yearlyBranch: yearlyData.earthlyBranch,
                    yearlyMutagens: yearlyData.mutagen || [],
                    decadalMutagens: decadalData.mutagen || [],
                    stars: {},
                    yearlyGods: {}
                };

                // Iterate over 12 palaces to find yearly stars
                if (yearlyData.stars && Array.isArray(yearlyData.stars)) {
                    for (var i = 0; i < 12; i++) {
                        var palaceName = palaces[i].name;
                        var starsInPalace = yearlyData.stars[i] || [];

                        var starNames = starsInPalace.map(function(s) {
                            return s.name;
                        });

                        result.stars[palaceName] = starNames;
                    }
                }

                // Extract yearly gods (JiangQian 12, SuiQian 12)
                // horoscope.yearly.yearlyDecStar contains jiangqian12 and suiqian12 arrays
                if (yearlyData.yearlyDecStar) {
                    var jq = yearlyData.yearlyDecStar.jiangqian12 || [];
                    var sq = yearlyData.yearlyDecStar.suiqian12 || [];

                    for (var i = 0; i < 12; i++) {
                        var palaceName = palaces[i].name;
                        var gods = [];
                        if (jq[i]) gods.push(jq[i]);
                        if (sq[i]) gods.push(sq[i]);

                        if (gods.length > 0) {
                            result.yearlyGods[palaceName] = gods;
                        }
                    }
                }

                return JSON.stringify(result);
            } catch (e) {
                return JSON.stringify({ error: e.message });
            }
        })();
        """

        guard let resultValue = context.evaluateScript(script),
              !resultValue.isUndefined,
              let resultString = resultValue.toString() else {
            throw ZiWeiChartError.jsExecutionFailed("No result for yearly context")
        }

        guard let resultData = resultString.data(using: .utf8) else {
            throw ZiWeiChartError.dataParsingFailed
        }

        if let json = try? JSONSerialization.jsonObject(with: resultData) as? [String: Any],
           let error = json["error"] as? String {
            throw ZiWeiChartError.jsExecutionFailed(error)
        }

        return try JSONDecoder().decode(YearlyFlowContext.self, from: resultData)
    }

    // MARK: - Date Conversion Helper

    /// 将农历日期转换为阳历日期 (利用 iztro 内部逻辑)
    func convertLunarToSolar(lunarYear: Int, lunarMonth: Int, lunarDay: Int, isLeapMonth: Bool) -> Date? {
        guard let context = jsContext else {
            print("❌ JSContext not initialized for date conversion")
            return nil
        }
        if !isLibraryLoaded {
            loadIztroLibrary() // Ensure loaded
        }

        let lunarDateStr = "\(lunarYear)-\(lunarMonth)-\(lunarDay)"
        let isLeap = isLeapMonth ? "true" : "false"

        // We call astro.byLunar with a dummy time and gender just to get the astrolabe object
        // which contains the converted solarDate.
        let script = """
        (function() {
            try {
                if (typeof iztro === 'undefined') return JSON.stringify({error: 'iztro not loaded'});

                var astrolabe = iztro.astro.byLunar(
                    '\(lunarDateStr)',
                    0, // dummy time index
                    '男', // dummy gender
                    \(isLeap),
                    true // fixLeap
                );

                return JSON.stringify({ solarDate: astrolabe.solarDate });
            } catch (e) {
                return JSON.stringify({ error: e.message });
            }
        })();
        """

        guard let resultValue = context.evaluateScript(script),
              !resultValue.isUndefined,
              let resultString = resultValue.toString(),
              let data = resultString.data(using: .utf8) else {
            print("❌ JS execution failed for date conversion")
            return nil
        }

        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let error = json["error"] as? String {
                    print("❌ Date conversion JS error: \(error)")
                    return nil
                }

                if let solarDateStr = json["solarDate"] as? String {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-M-d"
                    formatter.timeZone = TimeZone.current
                    return formatter.date(from: solarDateStr)
                }
            }
        } catch {
            print("❌ Date conversion parsing error: \(error)")
        }

        return nil
    }

    // MARK: - Private Helpers

    private func prepareJSCode(birthInfo: BirthInfo, returnVariable: Bool = true) throws -> String {
        // 准备基本参数
        let gender = birthInfo.gender == .male ? "男" : "女"

        // 修正时辰计算逻辑
        // 1. 计算真太阳时（如果需要）
        var finalHour = birthInfo.birthHour
        var finalMinute = birthInfo.birthMinute

        if birthInfo.useRealSolarTime {
            // 简单的真太阳时计算（包含经度和均时差）
            let (h, m) = SolarTimeCalculator.calculateTrueSolarTime(
                date: birthInfo.solarDate,
                hour: birthInfo.birthHour,
                minute: birthInfo.birthMinute,
                longitude: birthInfo.longitude
            )
            finalHour = h
            finalMinute = m
            print("🌞 真太阳时修正: \(birthInfo.birthHour):\(birthInfo.birthMinute) -> \(finalHour):\(finalMinute)")
        }

        // 2. 计算时辰索引 (0-12)
        var timeIndex = (finalHour + 1) / 2

        // 修正：fixLeap (闰月修正) 不应依赖于 useRealSolarTime (真太阳时)
        // iztro 默认处理方式通常为 true (闰月上半月算上个月，下半月算下个月)，这是主流派别做法
        let fixLeap = true

        // 根据历法类型构建不同的 JavaScript 调用
        let callCode: String

        // 根据用户语言设置选择 iztro 输出语言
        // 简体中文用 zh-CN，繁体中文用 zh-TW，英文用 zh-CN（因为星曜等术语保持中文更自然）
        // 但宫位名称会在 Swift 端根据用户语言单独翻译
        let chartLanguage: String
        switch LocalizationManager.shared.currentLanguage {
        case .simplifiedChinese:
            chartLanguage = "zh-CN"
        case .traditionalChinese:
            chartLanguage = "zh-TW"
        case .english:
            // 英文用户也使用简体中文数据，因为 iztro 的英文翻译（如 "metal 4th", "general"）不自然
            // UI 标签会翻译成英文，但星曜、干支等术语保留中文原文
            chartLanguage = "zh-CN"
        }

        if birthInfo.calendarType == .lunar, let lunarDate = birthInfo.lunarDate {
            // 使用农历 API
            let lunarDateString = "\(lunarDate.year)-\(lunarDate.month)-\(lunarDate.day)"
            let isLeapMonth = lunarDate.isLeapMonth ? "true" : "false"

            print("📅 使用农历排盘: \(lunarDateString), 闰月: \(isLeapMonth), 语言: \(chartLanguage)")

            callCode = """
            var astrolabe = iztro.astro.byLunar(
                '\(lunarDateString)',
                \(timeIndex),
                '\(gender)',
                \(isLeapMonth),
                \(fixLeap ? "true" : "false"),
                '\(chartLanguage)'
            );
            """
        } else {
            // 使用阳历 API
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-M-d"
            let solarDateString = dateFormatter.string(from: birthInfo.solarDate)

            print("📅 使用阳历排盘: \(solarDateString), 语言: \(chartLanguage)")

            callCode = """
            var astrolabe = iztro.astro.bySolar(
                '\(solarDateString)',
                \(timeIndex),
                '\(gender)',
                \(fixLeap ? "true" : "false"),
                '\(chartLanguage)'
            );
            """
        }

        if returnVariable {
            return """
            (function() {
                try {
                    if (typeof iztro === 'undefined') throw new Error('iztro not loaded');
                    \(callCode)

                    // Clone the basic astrolabe data
                    var result = JSON.parse(JSON.stringify(astrolabe));

                    // 十天干四化表 - 用于获取飞化的星曜名称
                    // iztro 的 mutagedPlaces() 方法只返回目标宫位，不返回星曜名称
                    // 因此仍需此表来获取具体的星曜名称
                    var mutagensMap = {
                        '甲': { '禄': '廉贞', '权': '破军', '科': '武曲', '忌': '太阳' },
                        '乙': { '禄': '天机', '权': '天梁', '科': '紫微', '忌': '太阴' },
                        '丙': { '禄': '天同', '权': '天机', '科': '文昌', '忌': '廉贞' },
                        '丁': { '禄': '太阴', '权': '天同', '科': '天机', '忌': '巨门' },
                        '戊': { '禄': '贪狼', '权': '太阴', '科': '右弼', '忌': '天机' },
                        '己': { '禄': '武曲', '权': '贪狼', '科': '天梁', '忌': '文曲' },
                        '庚': { '禄': '太阳', '权': '武曲', '科': '太阴', '忌': '天同' },
                        '辛': { '禄': '巨门', '权': '太阳', '科': '文曲', '忌': '文昌' },
                        '壬': { '禄': '天梁', '权': '紫微', '科': '左辅', '忌': '武曲' },
                        '癸': { '禄': '破军', '权': '巨门', '科': '太阴', '忌': '贪狼' }
                    };

                    // 四化类型映射 (用于 mutagedPlaces 的索引)
                    var mutagenTypes = ['禄', '权', '科', '忌'];

                    // Enrich palaces with surrounded relationships from iztro logic
                    if (result.palaces && Array.isArray(result.palaces)) {
                        result.palaces = result.palaces.map(function(p, i) {
                            // 获取当前宫位的 FunctionalPalace 对象
                            var funcPalace = astrolabe.palace(i);

                            // Call surroundedPalaces for each palace index
                            var sur = astrolabe.surroundedPalaces(i);

                            // Find indices for related palaces.
                            var findIndex = function(palaceObj) {
                                if (!palaceObj) return -1;
                                for (var k = 0; k < astrolabe.palaces.length; k++) {
                                    if (astrolabe.palaces[k].name === palaceObj.name) return k;
                                }
                                return -1;
                            };

                            var relationships = {
                                oppositeIndex: findIndex(sur.opposite),
                                wealthIndex: findIndex(sur.wealth),
                                careerIndex: findIndex(sur.career),
                                oppositeName: sur.opposite ? sur.opposite.name : '',
                                wealthName: sur.wealth ? sur.wealth.name : '',
                                careerName: sur.career ? sur.career.name : ''
                            };

                            p.relationships = relationships;

                            // 使用 iztro 的 selfMutaged() 方法检测自化
                            // 并使用 mutagensMap 获取具体星曜名称
                            var selfMutations = [];
                            if (funcPalace && p.heavenlyStem && mutagensMap[p.heavenlyStem]) {
                                var m = mutagensMap[p.heavenlyStem];
                                mutagenTypes.forEach(function(type) {
                                    // 使用 iztro 的 selfMutaged() API 检测
                                    if (funcPalace.selfMutaged(type)) {
                                        selfMutations.push({ type: type, star: m[type] });
                                    }
                                });
                            }
                            p.selfMutations = selfMutations;

                            // 使用 iztro 的 mutagedPlaces() 方法获取飞星目标宫位
                            // mutagedPlaces() 返回 [禄目标, 权目标, 科目标, 忌目标]
                            var flyingStars = [];
                            if (funcPalace && p.heavenlyStem && mutagensMap[p.heavenlyStem]) {
                                var m = mutagensMap[p.heavenlyStem];
                                var targetPlaces = funcPalace.mutagedPlaces();

                                mutagenTypes.forEach(function(type, idx) {
                                    var targetPalace = targetPlaces[idx];
                                    var starName = m[type];

                                    // 排除自化（飞入本宫的情况）
                                    // 自化已在 selfMutations 中处理
                                    if (targetPalace && targetPalace.name !== p.name) {
                                        flyingStars.push({
                                            type: type,
                                            toPalaceName: targetPalace.name,
                                            toPalacePosition: findIndex(targetPalace),
                                            star: starName
                                        });
                                    }
                                });
                            }
                            p.flyingStars = flyingStars;

                            return p;
                        });
                    }

                    return JSON.stringify(result);
                } catch (e) {
                    return JSON.stringify({ error: e.message });
                }
            })();
            """
        } else {
            // Just execute the assignment
            return """
            if (typeof iztro === 'undefined') throw new Error('iztro not loaded');
            \(callCode)
            """
        }
    }

    private func parseChartData(jsonObject: [String: Any]?, birthInfo: BirthInfo, rawJSON: String) throws -> ZiWeiChart {
        guard let json = jsonObject else {
            throw ZiWeiChartError.dataParsingFailed
        }

        // 提取基本信息 - 根据 iztro 文档
        let fiveElementBureau = json["fiveElementsClass"] as? String ?? "火六局"
        let lifeMaster = json["soul"] as? String ?? "天机"  // 命主
        let bodyMaster = json["body"] as? String ?? "武曲"  // 身主
        let chineseDate = json["chineseDate"] as? String ?? "" // 干支纪年

        // 提取命宫和身宫位置
        let soulBranch = json["earthlyBranchOfSoulPalace"] as? String ?? "寅"
        let bodyBranch = json["earthlyBranchOfBodyPalace"] as? String ?? "寅"

        // 提取十二宫信息
        guard let palacesArray = json["palaces"] as? [[String: Any]] else {
            throw ZiWeiChartError.dataParsingFailed
        }

        var palaces: [Palace] = []
        var mingPalaceName: PalaceName = .ming
        var bodyPalaceName: PalaceName = .ming
        var mingPalaceIndex = 0
        var bodyPalaceIndex = 0

        for (index, palaceData) in palacesArray.enumerated() {
            guard let palaceNameStr = palaceData["name"] as? String,
                  let heavenlyStem = palaceData["heavenlyStem"] as? String,
                  let earthlyBranch = palaceData["earthlyBranch"] as? String else {
                continue
            }

            // 解析宫位名称
            let palaceName = parsePalaceName(palaceNameStr)

            // 检查是否是命宫
            if palaceNameStr.contains("命宫") {
                mingPalaceName = palaceName
                mingPalaceIndex = index
            }

            // 检查是否是身宫
            let isBodyPalace = palaceData["isBodyPalace"] as? Bool ?? false
            if isBodyPalace {
                bodyPalaceName = palaceName
                bodyPalaceIndex = index
            }

            // 提取所有星曜
            var allStars: [Star] = []

            // 提取主星
            if let majorStarsArray = palaceData["majorStars"] as? [[String: Any]] {
                for starData in majorStarsArray {
                    if let star = parseStar(starData, type: .major) {
                        allStars.append(star)
                    }
                }
            }

            // 提取辅星
            if let minorStarsArray = palaceData["minorStars"] as? [[String: Any]] {
                for starData in minorStarsArray {
                    if let star = parseStar(starData, type: .support) {
                        allStars.append(star)
                    }
                }
            }

            // 提取杂耀
            if let adjectiveStarsArray = palaceData["adjectiveStars"] as? [[String: Any]] {
                for starData in adjectiveStarsArray {
                    if let star = parseStar(starData, type: .minor) {
                        allStars.append(star)
                    }
                }
            }

            // 提取大限信息 - 存储为 "start-end" 格式，不带语言后缀
            var majorLimitStr: String?
            if let decadalData = palaceData["decadal"] as? [String: Any],
               let range = decadalData["range"] as? [Int], range.count == 2 {
                majorLimitStr = "\(range[0])-\(range[1])"
            }

            // 提取三方四正关系
            var relationships: PalaceRelationships?
            if let relData = palaceData["relationships"] as? [String: Any] {
                relationships = PalaceRelationships(
                    oppositeIndex: relData["oppositeIndex"] as? Int ?? -1,
                    wealthIndex: relData["wealthIndex"] as? Int ?? -1,
                    careerIndex: relData["careerIndex"] as? Int ?? -1,
                    oppositeName: relData["oppositeName"] as? String,
                    wealthName: relData["wealthName"] as? String,
                    careerName: relData["careerName"] as? String
                )
            }

            // 提取长生十二神和博士十二神
            let changsheng12 = palaceData["changsheng12"] as? String
            let boshi12 = palaceData["boshi12"] as? String

            // 提取自化
            var selfMutations: [SelfMutation] = []
            if let selfMutationsArray = palaceData["selfMutations"] as? [[String: Any]] {
                for smData in selfMutationsArray {
                    if let typeStr = smData["type"] as? String,
                       let type = FourTransformType(rawValue: typeStr) {
                        let star = smData["star"] as? String
                        selfMutations.append(SelfMutation(type: type, star: star))
                    }
                }
            }

            // 提取飞星 (Flying Stars)
            var flyingStars: [FlyingStar] = []
            if let flyingStarsArray = palaceData["flyingStars"] as? [[String: Any]] {
                for fsData in flyingStarsArray {
                    if let typeStr = fsData["type"] as? String,
                       let type = FourTransformType(rawValue: typeStr),
                       let toPalaceName = fsData["toPalaceName"] as? String,
                       let star = fsData["star"] as? String {

                        // toPalacePosition might be missing or -1 from JS, we can try to resolve it if needed,
                        // but for prompt generation name is enough.
                        let position = fsData["toPalacePosition"] as? Int ?? -1

                        flyingStars.append(FlyingStar(
                            type: type,
                            toPalaceName: toPalaceName,
                            toPalacePosition: position,
                            star: star
                        ))
                    }
                }
            }

            let palace = Palace(
                name: palaceName,
                earthlyBranch: earthlyBranch,
                heavenlyStem: heavenlyStem,
                stars: allStars,
                position: index,
                isBodyPalace: isBodyPalace,
                majorLimit: majorLimitStr,
                relationships: relationships,
                changsheng12: changsheng12,
                boshi12: boshi12,
                selfMutations: selfMutations.isEmpty ? nil : selfMutations,
                flyingStars: flyingStars.isEmpty ? nil : flyingStars
            )

            palaces.append(palace)
        }

        // 解析四化
        let fourTransforms = parseFourTransforms(from: palaces)

        // 解析大限
        let majorLimits = parseMajorLimits(from: palaces)

        // 创建星盘对象
        let chart = ZiWeiChart(
            palaces: palaces,
            birthYear: chineseDate,
            fiveElementBureau: fiveElementBureau,
            bodyMaster: bodyMaster,
            lifeMaster: lifeMaster,
            mingPalace: mingPalaceName,
            bodyPalace: bodyPalaceName,
            fourTransforms: fourTransforms,
            majorLimits: majorLimits,
            yearFortunes: nil,
            rawJSONData: rawJSON
        )

        return chart
    }

    // 辅助方法：解析宫位名称
    private func parsePalaceName(_ name: String) -> PalaceName {
        // 移除可能的身宫标记
        let cleanName = name.replacingOccurrences(of: "（身）", with: "")
            .replacingOccurrences(of: "(身)", with: "")
            .trimmingCharacters(in: .whitespaces)

        // Handle English names
        switch cleanName {
        case "Life", "命宫", "命": return .ming
        case "Brothers", "兄弟宫", "兄弟": return .xiongdi
        case "Spouse", "夫妻宫", "夫妻": return .fuqi
        case "Children", "子女宫", "子女": return .zinv
        case "Wealth", "财帛宫", "财帛", "財帛": return .caibo
        case "Health", "疾厄宫", "疾厄": return .jie
        case "Travel", "迁移宫", "迁移", "遷移": return .qianyi
        case "Friends", "交友宫", "仆役宫", "交友", "仆役", "僕役": return .jiaoyou
        case "Career", "官禄宫", "事业宫", "官禄", "事业", "官祿": return .guanlu
        case "Property", "田宅宫", "田宅": return .tianzhai
        case "Mental", "福德宫", "福德": return .fude
        case "Parents", "父母宫", "相貌宫", "父母", "相貌": return .fumu
        default: return .ming
        }
    }

    // 辅助方法：解析星曜
    private func parseStar(_ starData: [String: Any], type: Star.StarType) -> Star? {
        guard let name = starData["name"] as? String else {
            return nil
        }

        let brightness = starData["brightness"] as? String
        let mutagenStr = starData["mutagen"] as? String

        // 解析四化
        var fourTransform: FourTransformType?
        if let mutagen = mutagenStr {
            switch mutagen {
            case "禄": fourTransform = .lu
            case "权": fourTransform = .quan
            case "科": fourTransform = .ke
            case "忌": fourTransform = .ji
            default: break
            }
        }

        return Star(
            name: name,
            type: type,
            brightness: brightness,
            fourTransform: fourTransform
        )
    }

    // 辅助方法：解析四化 (从已解析的宫位数据中提取)
    private func parseFourTransforms(from palaces: [Palace]) -> FourTransforms {
        var lu: String?
        var quan: String?
        var ke: String?
        var ji: String?

        for palace in palaces {
            for star in palace.stars {
                if let transform = star.fourTransform {
                    switch transform {
                    case .lu: lu = star.name
                    case .quan: quan = star.name
                    case .ke: ke = star.name
                    case .ji: ji = star.name
                    }
                }
            }
        }

        return FourTransforms(
            luStar: lu,
            quanStar: quan,
            keStar: ke,
            jiStar: ji
        )
    }

    // 辅助方法：解析大限
    private func parseMajorLimits(from palaces: [Palace]) -> [MajorLimit] {
        var limits: [MajorLimit] = []

        for palace in palaces {
            if let limitStr = palace.majorLimit {
                // 解析 "6-15" 格式 (也兼容旧的 "6-15岁" 格式)
                let cleanStr = limitStr.replacingOccurrences(of: "岁", with: "")
                                       .replacingOccurrences(of: "歲", with: "")
                let components = cleanStr.split(separator: "-")
                if components.count == 2,
                   let start = Int(components[0].trimmingCharacters(in: .whitespaces)),
                   let end = Int(components[1].trimmingCharacters(in: .whitespaces)) {
                    let limit = MajorLimit(
                        startAge: start,
                        endAge: end,
                        palace: palace.name,
                        earthlyBranch: palace.earthlyBranch
                    )
                    limits.append(limit)
                }
            }
        }

        return limits.sorted { $0.startAge < $1.startAge }
    }
}
