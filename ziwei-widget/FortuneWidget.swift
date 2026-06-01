import WidgetKit
import SwiftUI

// MARK: - Widget Entry
struct FortuneWidgetEntry: TimelineEntry {
    let date: Date
    let dayInfo: DayInfo
}

// MARK: - Timeline Provider
struct FortuneTimelineProvider: TimelineProvider {

    func placeholder(in context: Context) -> FortuneWidgetEntry {
        FortuneWidgetEntry(
            date: Date(),
            dayInfo: ChineseCalendarHelper.getTodayInfo()
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (FortuneWidgetEntry) -> Void) {
        let entry = FortuneWidgetEntry(
            date: Date(),
            dayInfo: ChineseCalendarHelper.getTodayInfo()
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FortuneWidgetEntry>) -> Void) {
        let currentDate = Date()
        let dayInfo = ChineseCalendarHelper.getTodayInfo()

        let entry = FortuneWidgetEntry(date: currentDate, dayInfo: dayInfo)

        // 计算下一个午夜时间，届时刷新Widget
        let calendar = Calendar.current
        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: currentDate)!)

        let timeline = Timeline(entries: [entry], policy: .after(tomorrow))
        completion(timeline)
    }
}

// MARK: - Widget Views

/// Small Widget View
struct FortuneWidgetSmallView: View {
    let entry: FortuneWidgetEntry

    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.08, blue: 0.12),
                    Color(red: 0.12, green: 0.10, blue: 0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 6) {
                // 农历日期
                HStack(spacing: 4) {
                    Text("📅")
                        .font(.system(size: 14))
                    Text(entry.dayInfo.lunarDateString)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                }

                // 干支
                Text(entry.dayInfo.fullGanZhi)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(red: 0.85, green: 0.75, blue: 0.55))

                Spacer()

                // 生肖
                HStack {
                    Text(entry.dayInfo.zodiacEmoji)
                        .font(.system(size: 20))
                    Text("\(entry.dayInfo.zodiac)年")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

/// Medium Widget View
struct FortuneWidgetMediumView: View {
    let entry: FortuneWidgetEntry

    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.08, blue: 0.12),
                    Color(red: 0.12, green: 0.10, blue: 0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // 装饰性星点
            GeometryReader { geo in
                ForEach(0..<8, id: \.self) { i in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.1...0.3)))
                        .frame(width: CGFloat.random(in: 1...3))
                        .position(
                            x: CGFloat.random(in: 0...geo.size.width),
                            y: CGFloat.random(in: 0...geo.size.height)
                        )
                }
            }

            HStack(spacing: 16) {
                // 左侧：农历信息
                VStack(alignment: .leading, spacing: 8) {
                    // 农历日期
                    HStack(spacing: 6) {
                        Text("📅")
                            .font(.system(size: 16))
                        Text(entry.dayInfo.lunarDateString)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }

                    // 干支
                    Text(entry.dayInfo.fullGanZhi)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(red: 0.85, green: 0.75, blue: 0.55))

                    Spacer()

                    // 生肖
                    HStack(spacing: 4) {
                        Text(entry.dayInfo.zodiacEmoji)
                            .font(.system(size: 24))
                        Text("\(entry.dayInfo.zodiac)年")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // 分隔线
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 1)
                    .padding(.vertical, 8)

                // 右侧：今日四化
                VStack(alignment: .leading, spacing: 6) {
                    Text("今日四化")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            MutagenTag(type: "禄", star: entry.dayInfo.mutagens.lu, color: .green)
                            MutagenTag(type: "权", star: entry.dayInfo.mutagens.quan, color: .orange)
                        }
                        HStack(spacing: 8) {
                            MutagenTag(type: "科", star: entry.dayInfo.mutagens.ke, color: .blue)
                            MutagenTag(type: "忌", star: entry.dayInfo.mutagens.ji, color: .red)
                        }
                    }

                    Spacer()

                    // 日干提示
                    Text("\(entry.dayInfo.dayStem)日")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.white.opacity(0.4))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(14)
        }
    }
}

/// Large Widget View
struct FortuneWidgetLargeView: View {
    let entry: FortuneWidgetEntry

    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.08, blue: 0.12),
                    Color(red: 0.10, green: 0.08, blue: 0.15),
                    Color(red: 0.12, green: 0.10, blue: 0.18)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // 装饰性星点
            GeometryReader { geo in
                ForEach(0..<15, id: \.self) { i in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.1...0.4)))
                        .frame(width: CGFloat.random(in: 1...4))
                        .position(
                            x: CGFloat.random(in: 0...geo.size.width),
                            y: CGFloat.random(in: 0...geo.size.height)
                        )
                }
            }

            VStack(spacing: 16) {
                // 头部：农历日期
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text("📅")
                                .font(.system(size: 20))
                            Text(entry.dayInfo.lunarDateString)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Text(entry.dayInfo.fullGanZhi)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(red: 0.85, green: 0.75, blue: 0.55))
                    }

                    Spacer()

                    // 生肖
                    VStack(spacing: 2) {
                        Text(entry.dayInfo.zodiacEmoji)
                            .font(.system(size: 36))
                        Text("\(entry.dayInfo.zodiac)年")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }

                // 分隔线
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, Color(red: 0.85, green: 0.75, blue: 0.55).opacity(0.3), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)

                // 今日四化标题
                HStack {
                    Text("✨ 今日星象结构")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    Text("Daily Astrological Structure")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.white.opacity(0.4))
                }

                // 四化卡片
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        MutagenCard(type: "化禄", star: entry.dayInfo.mutagens.lu, color: .green, description: "财禄亨通")
                        MutagenCard(type: "化权", star: entry.dayInfo.mutagens.quan, color: .orange, description: "权柄在握")
                    }
                    HStack(spacing: 10) {
                        MutagenCard(type: "化科", star: entry.dayInfo.mutagens.ke, color: .blue, description: "文昌贵显")
                        MutagenCard(type: "化忌", star: entry.dayInfo.mutagens.ji, color: .red, description: "谨慎为宜")
                    }
                }

                Spacer()

                // 底部提示
                HStack {
                    Text("基于 \(entry.dayInfo.dayStem)日 天干四化")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.white.opacity(0.4))

                    Spacer()

                    Text("紫微斗数")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(red: 0.85, green: 0.75, blue: 0.55).opacity(0.6))
                }
            }
            .padding(16)
        }
    }
}

// MARK: - Helper Views

/// 四化标签 (用于Medium Widget)
struct MutagenTag: View {
    let type: String
    let star: String
    let color: Color

    var body: some View {
        HStack(spacing: 2) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text("\(star)")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(color.opacity(0.15))
        .cornerRadius(4)
    }
}

/// 四化卡片 (用于Large Widget)
struct MutagenCard: View {
    let type: String
    let star: String
    let color: Color
    let description: String

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(star)\(type)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                Text(description)
                    .font(.system(size: 9, weight: .regular))
                    .foregroundColor(.white.opacity(0.5))
            }

            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Main Widget View
struct FortuneWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: FortuneWidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:
            FortuneWidgetSmallView(entry: entry)
        case .systemMedium:
            FortuneWidgetMediumView(entry: entry)
        case .systemLarge:
            FortuneWidgetLargeView(entry: entry)
        default:
            FortuneWidgetMediumView(entry: entry)
        }
    }
}

// MARK: - Widget Configuration
struct FortuneWidget: Widget {
    let kind: String = "FortuneWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FortuneTimelineProvider()) { entry in
            if #available(iOS 17.0, *) {
                FortuneWidgetEntryView(entry: entry)
                    .containerBackground(.clear, for: .widget)
            } else {
                FortuneWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("农历星象")
        .description("显示今日农历日期与星象结构")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Widget Bundle
@main
struct FortuneWidgetBundle: WidgetBundle {
    var body: some Widget {
        FortuneWidget()
    }
}

// MARK: - Preview
#if DEBUG
struct FortuneWidget_Previews: PreviewProvider {
    static var previews: some View {
        let entry = FortuneWidgetEntry(
            date: Date(),
            dayInfo: ChineseCalendarHelper.getTodayInfo()
        )

        Group {
            FortuneWidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Small")

            FortuneWidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Medium")

            FortuneWidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .previewDisplayName("Large")
        }
    }
}
#endif
