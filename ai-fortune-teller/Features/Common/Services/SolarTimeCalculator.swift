import Foundation

class SolarTimeCalculator {

    /// 计算真太阳时 (包含经度修正和均时差EOT)
    /// - Parameters:
    ///   - date: 阳历日期
    ///   - hour: 钟表小时 (0-23)
    ///   - minute: 钟表分钟 (0-59)
    ///   - longitude: 经度
    /// - Returns: (修正后的小时, 修正后的分钟)
    static func calculateTrueSolarTime(date: Date, hour: Int, minute: Int, longitude: Double) -> (Int, Int) {
        // 1. 经度修正 (Local Mean Time)
        // 北京时间是东经120度，每差1度差4分钟
        let longitudeDiff = longitude - 120.0
        let longitudeCorrection = longitudeDiff * 4.0 // 分钟

        // 2. 均时差修正 (Equation of Time)
        // 使用近似公式
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1

        // B = 360 * (N - 81) / 365
        let b = 2.0 * Double.pi * Double(dayOfYear - 81) / 365.0

        // E = 9.87 * sin(2B) - 7.53 * cos(B) - 1.5 * sin(B)
        let eot = 9.87 * sin(2 * b) - 7.53 * cos(b) - 1.5 * sin(b)

        // 总修正量 (分钟)
        let totalCorrection = longitudeCorrection + eot

        // 计算原始分钟数
        let totalMinutes = hour * 60 + minute
        let adjustedTotalMinutes = Int(Double(totalMinutes) + totalCorrection)

        // 处理跨天
        var finalHour = (adjustedTotalMinutes / 60) % 24
        if finalHour < 0 { finalHour += 24 }

        var finalMinute = adjustedTotalMinutes % 60
        if finalMinute < 0 { finalMinute += 60 }

        return (finalHour, finalMinute)
    }

    /// 获取真太阳时修正的详细说明文本
    static func getCorrectionExplanation(date: Date, hour: Int, minute: Int, longitude: Double, locationName: String) -> String {
        let (finalHour, finalMinute) = calculateTrueSolarTime(date: date, hour: hour, minute: minute, longitude: longitude)

        let chineseHour = BirthInfo.getLocalizedChineseHour(from: finalHour)

        // 计算时差
        let originalMinutes = hour * 60 + minute

        // 反推总修正量
        // 注意：这里为了展示方便，重新计算一遍修正量，而不是用 adjusted - original，因为涉及到跨天问题
        let longitudeDiff = longitude - 120.0
        let longitudeCorrection = longitudeDiff * 4.0

        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let b = 2.0 * Double.pi * Double(dayOfYear - 81) / 365.0
        let eot = 9.87 * sin(2 * b) - 7.53 * cos(b) - 1.5 * sin(b)

        let totalCorrection = longitudeCorrection + eot
        let sign = totalCorrection >= 0 ? "+" : ""

        return LocalizationManager.shared.strings.solarTimeExplanation(
            inputTime: String(format: "%02d:%02d", hour, minute),
            locationName: locationName,
            correction: "\(sign)\(Int(totalCorrection))",
            finalTime: String(format: "%02d:%02d", finalHour, finalMinute),
            chineseHour: chineseHour
        )
    }
}
