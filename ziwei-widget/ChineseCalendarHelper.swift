import Foundation

/// 农历/干支计算工具 - 用于Widget静态展示
/// 纯Swift实现，无需JavaScript依赖
struct ChineseCalendarHelper {

    // MARK: - 天干地支
    static let heavenlyStems = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"]
    static let earthlyBranches = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]

    // MARK: - 生肖
    static let zodiacAnimals = ["鼠", "牛", "虎", "兔", "龙", "蛇", "马", "羊", "猴", "鸡", "狗", "猪"]
    static let zodiacEmojis = ["🐀", "🐂", "🐅", "🐇", "🐉", "🐍", "🐴", "🐑", "🐵", "🐔", "🐕", "🐷"]

    // MARK: - 农历月份名
    static let lunarMonthNames = ["正", "二", "三", "四", "五", "六", "七", "八", "九", "十", "冬", "腊"]
    static let lunarDayNames = [
        "初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
        "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
        "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"
    ]

    // MARK: - 四化表 (根据日干)
    /// 十天干四化对照表
    static let mutagensMap: [String: [String: String]] = [
        "甲": ["禄": "廉贞", "权": "破军", "科": "武曲", "忌": "太阳"],
        "乙": ["禄": "天机", "权": "天梁", "科": "紫微", "忌": "太阴"],
        "丙": ["禄": "天同", "权": "天机", "科": "文昌", "忌": "廉贞"],
        "丁": ["禄": "太阴", "权": "天同", "科": "天机", "忌": "巨门"],
        "戊": ["禄": "贪狼", "权": "太阴", "科": "右弼", "忌": "天机"],
        "己": ["禄": "武曲", "权": "贪狼", "科": "天梁", "忌": "文曲"],
        "庚": ["禄": "太阳", "权": "武曲", "科": "太阴", "忌": "天同"],
        "辛": ["禄": "巨门", "权": "太阳", "科": "文曲", "忌": "文昌"],
        "壬": ["禄": "天梁", "权": "紫微", "科": "左辅", "忌": "武曲"],
        "癸": ["禄": "破军", "权": "巨门", "科": "太阴", "忌": "贪狼"]
    ]

    // MARK: - 农历数据 (1900-2100)
    /// 农历数据表，每个数字代表一年的农历信息
    /// 格式：低4位是闰月月份(0表示无闰月)，接下来12位是每月大小月(1大0小)，最高4位是闰月天数
    private static let lunarInfo: [Int] = [
        0x04bd8, 0x04ae0, 0x0a570, 0x054d5, 0x0d260, 0x0d950, 0x16554, 0x056a0, 0x09ad0, 0x055d2,
        0x04ae0, 0x0a5b6, 0x0a4d0, 0x0d250, 0x1d255, 0x0b540, 0x0d6a0, 0x0ada2, 0x095b0, 0x14977,
        0x04970, 0x0a4b0, 0x0b4b5, 0x06a50, 0x06d40, 0x1ab54, 0x02b60, 0x09570, 0x052f2, 0x04970,
        0x06566, 0x0d4a0, 0x0ea50, 0x06e95, 0x05ad0, 0x02b60, 0x186e3, 0x092e0, 0x1c8d7, 0x0c950,
        0x0d4a0, 0x1d8a6, 0x0b550, 0x056a0, 0x1a5b4, 0x025d0, 0x092d0, 0x0d2b2, 0x0a950, 0x0b557,
        0x06ca0, 0x0b550, 0x15355, 0x04da0, 0x0a5d0, 0x14573, 0x052d0, 0x0a9a8, 0x0e950, 0x06aa0,
        0x0aea6, 0x0ab50, 0x04b60, 0x0aae4, 0x0a570, 0x05260, 0x0f263, 0x0d950, 0x05b57, 0x056a0,
        0x096d0, 0x04dd5, 0x04ad0, 0x0a4d0, 0x0d4d4, 0x0d250, 0x0d558, 0x0b540, 0x0b5a0, 0x195a6,
        0x095b0, 0x049b0, 0x0a974, 0x0a4b0, 0x0b27a, 0x06a50, 0x06d40, 0x0af46, 0x0ab60, 0x09570,
        0x04af5, 0x04970, 0x064b0, 0x074a3, 0x0ea50, 0x06b58, 0x055c0, 0x0ab60, 0x096d5, 0x092e0,
        0x0c960, 0x0d954, 0x0d4a0, 0x0da50, 0x07552, 0x056a0, 0x0abb7, 0x025d0, 0x092d0, 0x0cab5,
        0x0a950, 0x0b4a0, 0x0baa4, 0x0ad50, 0x055d9, 0x04ba0, 0x0a5b0, 0x15176, 0x052b0, 0x0a930,
        0x07954, 0x06aa0, 0x0ad50, 0x05b52, 0x04b60, 0x0a6e6, 0x0a4e0, 0x0d260, 0x0ea65, 0x0d530,
        0x05aa0, 0x076a3, 0x096d0, 0x04afb, 0x04ad0, 0x0a4d0, 0x1d0b6, 0x0d250, 0x0d520, 0x0dd45,
        0x0b5a0, 0x056d0, 0x055b2, 0x049b0, 0x0a577, 0x0a4b0, 0x0aa50, 0x1b255, 0x06d20, 0x0ada0,
        0x14b63, 0x09370, 0x049f8, 0x04970, 0x064b0, 0x168a6, 0x0ea50, 0x06b20, 0x1a6c4, 0x0aae0,
        0x0a2e0, 0x0d2e3, 0x0c960, 0x0d557, 0x0d4a0, 0x0da50, 0x05d55, 0x056a0, 0x0a6d0, 0x055d4,
        0x052d0, 0x0a9b8, 0x0a950, 0x0b4a0, 0x0b6a6, 0x0ad50, 0x055a0, 0x0aba4, 0x0a5b0, 0x052b0,
        0x0b273, 0x06930, 0x07337, 0x06aa0, 0x0ad50, 0x14b55, 0x04b60, 0x0a570, 0x054e4, 0x0d160,
        0x0e968, 0x0d520, 0x0daa0, 0x16aa6, 0x056d0, 0x04ae0, 0x0a9d4, 0x0a2d0, 0x0d150, 0x0f252,
        0x0d520
    ]

    // MARK: - 公开方法

    /// 获取今日完整农历信息
    static func getTodayInfo() -> DayInfo {
        return getDayInfo(for: Date())
    }

    /// 获取指定日期的农历信息
    static func getDayInfo(for date: Date) -> DayInfo {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day], from: date)

        let year = components.year ?? 2024
        let month = components.month ?? 1
        let day = components.day ?? 1

        // 计算农历
        let lunar = solarToLunar(year: year, month: month, day: day)

        // 计算干支
        let ganZhi = calculateGanZhi(year: year, month: month, day: day)

        // 计算生肖 (基于农历年)
        let zodiacIndex = (lunar.year - 4) % 12
        let zodiac = zodiacAnimals[zodiacIndex]
        let zodiacEmoji = zodiacEmojis[zodiacIndex]

        // 获取今日四化 (基于日干)
        let dayMutagens = getMutagens(for: ganZhi.dayStem)

        return DayInfo(
            lunarYear: lunar.year,
            lunarMonth: lunar.month,
            lunarDay: lunar.day,
            isLeapMonth: lunar.isLeapMonth,
            lunarMonthName: lunarMonthNames[lunar.month - 1] + "月",
            lunarDayName: lunarDayNames[lunar.day - 1],
            yearStem: ganZhi.yearStem,
            yearBranch: ganZhi.yearBranch,
            monthStem: ganZhi.monthStem,
            monthBranch: ganZhi.monthBranch,
            dayStem: ganZhi.dayStem,
            dayBranch: ganZhi.dayBranch,
            zodiac: zodiac,
            zodiacEmoji: zodiacEmoji,
            mutagens: dayMutagens
        )
    }

    /// 获取四化信息
    static func getMutagens(for stem: String) -> Mutagens {
        guard let map = mutagensMap[stem] else {
            return Mutagens(lu: "未知", quan: "未知", ke: "未知", ji: "未知")
        }
        return Mutagens(
            lu: map["禄"] ?? "未知",
            quan: map["权"] ?? "未知",
            ke: map["科"] ?? "未知",
            ji: map["忌"] ?? "未知"
        )
    }

    // MARK: - 农历计算

    /// 阳历转农历
    private static func solarToLunar(year: Int, month: Int, day: Int) -> (year: Int, month: Int, day: Int, isLeapMonth: Bool) {
        // 基准日期: 1900年1月31日 = 农历1900年正月初一
        let baseDate = DateComponents(year: 1900, month: 1, day: 31)
        let targetDate = DateComponents(year: year, month: month, day: day)

        let calendar = Calendar(identifier: .gregorian)
        guard let base = calendar.date(from: baseDate),
              let target = calendar.date(from: targetDate) else {
            return (year, month, day, false)
        }

        var offset = calendar.dateComponents([.day], from: base, to: target).day ?? 0

        // 计算农历年月日
        var lunarYear = 1900
        var lunarMonth = 1
        var lunarDay = 1
        var isLeapMonth = false

        // 计算年
        var daysInYear = getLunarYearDays(lunarYear)
        while offset >= daysInYear {
            offset -= daysInYear
            lunarYear += 1
            if lunarYear > 2100 { break }
            daysInYear = getLunarYearDays(lunarYear)
        }

        // 计算月 - 修复闰月处理逻辑
        let leapMonth = getLeapMonth(lunarYear)

        var month = 1
        while month <= 12 {
            // 先处理正常月份
            let daysInMonth = getLunarMonthDays(lunarYear, month: month)

            if offset < daysInMonth {
                lunarMonth = month
                lunarDay = offset + 1
                isLeapMonth = false
                break
            }
            offset -= daysInMonth

            // 如果当前月份有闰月，接着处理闰月
            if month == leapMonth {
                let leapDays = getLeapMonthDays(lunarYear)
                if offset < leapDays {
                    lunarMonth = month
                    lunarDay = offset + 1
                    isLeapMonth = true
                    break
                }
                offset -= leapDays
            }

            month += 1
        }

        return (lunarYear, lunarMonth, lunarDay, isLeapMonth)
    }

    /// 获取农历年总天数
    private static func getLunarYearDays(_ year: Int) -> Int {
        var sum = 348 // 12个月 * 29天
        let index = year - 1900
        guard index >= 0 && index < lunarInfo.count else { return 365 }

        let info = lunarInfo[index]

        // 累加大月天数
        // 修正：bit 15-4 存储12个月的大小月信息，使用 (15 - i) 而不是 (16 - i)
        for i in 0..<12 {
            if (info >> (15 - i)) & 1 == 1 {
                sum += 1
            }
        }

        // 加上闰月天数
        sum += getLeapMonthDays(year)

        return sum
    }

    /// 获取闰月月份 (0表示无闰月)
    private static func getLeapMonth(_ year: Int) -> Int {
        let index = year - 1900
        guard index >= 0 && index < lunarInfo.count else { return 0 }
        return lunarInfo[index] & 0xf
    }

    /// 获取闰月天数
    private static func getLeapMonthDays(_ year: Int) -> Int {
        let leapMonth = getLeapMonth(year)
        if leapMonth == 0 { return 0 }

        let index = year - 1900
        guard index >= 0 && index < lunarInfo.count else { return 0 }

        return (lunarInfo[index] >> 16) & 1 == 1 ? 30 : 29
    }

    /// 获取农历某月天数
    private static func getLunarMonthDays(_ year: Int, month: Int) -> Int {
        let index = year - 1900
        guard index >= 0 && index < lunarInfo.count else { return 30 }

        return (lunarInfo[index] >> (16 - month)) & 1 == 1 ? 30 : 29
    }

    // MARK: - 干支计算

    /// 计算年月日干支
    private static func calculateGanZhi(year: Int, month: Int, day: Int) -> (yearStem: String, yearBranch: String, monthStem: String, monthBranch: String, dayStem: String, dayBranch: String) {
        // 年干支 (以立春为界，简化处理用农历年)
        let yearOffset = year - 4 // 公元4年为甲子年
        let yearStemIndex = yearOffset % 10
        let yearBranchIndex = yearOffset % 12
        let yearStem = heavenlyStems[(yearStemIndex + 10) % 10]
        let yearBranch = earthlyBranches[(yearBranchIndex + 12) % 12]

        // 月干支 (简化计算)
        // 月干 = (年干序号 * 2 + 月份) % 10
        let monthStemIndex = (((yearOffset % 10) + 10) % 10 * 2 + month) % 10
        let monthBranchIndex = (month + 1) % 12
        let monthStem = heavenlyStems[monthStemIndex]
        let monthBranch = earthlyBranches[monthBranchIndex]

        // 日干支 (使用儒略日计算)
        let julianDay = calculateJulianDay(year: year, month: month, day: day)
        let dayOffset = (julianDay + 9) % 60
        let dayStemIndex = dayOffset % 10
        let dayBranchIndex = dayOffset % 12
        let dayStem = heavenlyStems[dayStemIndex]
        let dayBranch = earthlyBranches[dayBranchIndex]

        return (yearStem, yearBranch, monthStem, monthBranch, dayStem, dayBranch)
    }

    /// 计算儒略日
    private static func calculateJulianDay(year: Int, month: Int, day: Int) -> Int {
        var y = year
        var m = month

        if m <= 2 {
            y -= 1
            m += 12
        }

        let a = y / 100
        let b = 2 - a + a / 4

        let jd = Int(365.25 * Double(y + 4716)) + Int(30.6001 * Double(m + 1)) + day + b - 1524

        return jd
    }
}

// MARK: - 数据模型

/// 日期信息
struct DayInfo {
    let lunarYear: Int
    let lunarMonth: Int
    let lunarDay: Int
    let isLeapMonth: Bool
    let lunarMonthName: String  // 如 "腊月"
    let lunarDayName: String    // 如 "初三"

    let yearStem: String        // 年干 如 "甲"
    let yearBranch: String      // 年支 如 "辰"
    let monthStem: String       // 月干
    let monthBranch: String     // 月支
    let dayStem: String         // 日干
    let dayBranch: String       // 日支

    let zodiac: String          // 生肖 如 "龙"
    let zodiacEmoji: String     // 生肖emoji 如 "🐉"

    let mutagens: Mutagens      // 今日四化

    /// 完整农历日期字符串
    var lunarDateString: String {
        let prefix = isLeapMonth ? "闰" : ""
        return "\(prefix)\(lunarMonthName)\(lunarDayName)"
    }

    /// 年干支字符串
    var yearGanZhi: String {
        return "\(yearStem)\(yearBranch)年"
    }

    /// 月干支字符串
    var monthGanZhi: String {
        return "\(monthStem)\(monthBranch)月"
    }

    /// 日干支字符串
    var dayGanZhi: String {
        return "\(dayStem)\(dayBranch)日"
    }

    /// 完整干支字符串
    var fullGanZhi: String {
        return "\(yearGanZhi) \(monthGanZhi) \(dayGanZhi)"
    }
}

/// 四化信息
struct Mutagens {
    let lu: String    // 化禄星
    let quan: String  // 化权星
    let ke: String    // 化科星
    let ji: String    // 化忌星

    /// 格式化显示
    var formatted: String {
        return "\(lu)化禄 \(quan)化权\n\(ke)化科 \(ji)化忌"
    }

    /// 简短格式
    var short: String {
        return "禄:\(lu) 权:\(quan) 科:\(ke) 忌:\(ji)"
    }
}
