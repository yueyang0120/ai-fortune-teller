import SwiftUI

struct ChartDisplayView: View {
    let chart: ZiWeiChart
    @State private var selectedPalace: Palace?
    @State private var showGuideHint: Bool = !UserDefaults.standard.bool(forKey: "hasSeenChartGuide")
    @State private var hintOpacity: Double = 1.0
    @ObservedObject private var localizationManager = LocalizationManager.shared

    // 4x4 Grid positions
    let earthlyBranchPositions: [String: (row: Int, col: Int)] = [
        "寅": (3, 0), "卯": (2, 0), "辰": (1, 0), "巳": (0, 0),
        "午": (0, 1), "未": (0, 2), "申": (0, 3), "酉": (1, 3),
        "戌": (2, 3), "亥": (3, 3), "子": (3, 2), "丑": (3, 1)
    ]

    var body: some View {
        VStack(spacing: 16) {
            // Basic Info Row
            HStack {
                HStack(spacing: 4) {
                    Text(chart.birthYear)
                        .font(.appSerif(size: 14, weight: .medium))
                        .foregroundColor(.flowingGold)
                    Text(localizationManager.strings.yearSuffix)
                        .font(.appSerif(size: 14, weight: .regular))
                        .foregroundColor(.mutedText)
                }
                Spacer()
                HStack(spacing: 8) {
                    InfoChip(label: localizationManager.strings.fiveElements, value: chart.fiveElementBureau)
                    InfoChip(label: localizationManager.strings.lifeMaster, value: chart.lifeMaster)
                    InfoChip(label: localizationManager.strings.bodyMaster, value: chart.bodyMaster)
                }
            }
            .padding(16)
            .background(Color.cardBackgroundSolid.opacity(0.9))
            .cornerRadius(Theme.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )

            // Chart Grid - Direct layout without extra wrapper
            ZStack(alignment: .bottom) {
                GeometryReader { geometry in
                    let gridSize = geometry.size.width
                    let cellSize = (gridSize - 9) / 4 // 9 = 3 gaps of 3px
                    let spacing: CGFloat = 3

                    ZStack {
                        // Background card
                        RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                            .fill(Color.cardBackgroundSolid.opacity(0.9))

                        RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)

                        // Center Text "紫微斗数"
                        if localizationManager.currentLanguage == .english {
                            VStack(spacing: 4) {
                                Text(localizationManager.strings.centerTitle)
                                    .font(.appSerif(size: 20, weight: .bold))
                                    .multilineTextAlignment(.center)
                            }
                            .foregroundColor(.flowingGold.opacity(0.15))
                            .frame(maxWidth: gridSize * 0.6)
                        } else {
                            VStack(spacing: 8) {
                                HStack(spacing: 32) {
                                    Text("紫")
                                    Text("微")
                                }
                                HStack(spacing: 32) {
                                    Text("斗")
                                    Text("数")
                                }
                            }
                            .font(.appSerif(size: 36, weight: .bold))
                            .foregroundColor(.flowingGold.opacity(0.15))
                        }

                        // Palaces
                        ForEach(chart.palaces) { palace in
                            if let position = earthlyBranchPositions[palace.earthlyBranch] {
                                PalaceCell(
                                    palace: palace,
                                    cellSize: cellSize
                                )
                                .frame(width: cellSize, height: cellSize)
                                .position(
                                    x: CGFloat(position.col) * (cellSize + spacing) + cellSize / 2 + 6,
                                    y: CGFloat(position.row) * (cellSize + spacing) + cellSize / 2 + 6
                                )
                                .onTapGesture {
                                    HapticManager.softImpact()
                                    selectedPalace = palace
                                    // 用户点击宫位后，隐藏引导提示
                                    if showGuideHint {
                                        dismissGuideHint()
                                    }
                                }
                            }
                        }
                    }
                    .frame(width: gridSize, height: gridSize)
                }

                // Guide hint overlay
                if showGuideHint {
                    ChartGuideHintView(
                        message: localizationManager.strings.chartTapHint,
                        onDismiss: dismissGuideHint
                    )
                    .opacity(hintOpacity)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .padding(.bottom, 8)
                }
            }
            .aspectRatio(1, contentMode: .fit)

            // Four Transforms
            if chart.fourTransforms.luStar != nil {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Rectangle()
                            .fill(Color.flowingGold)
                            .frame(width: 3, height: 14)
                        Text(localizationManager.strings.birthYearFourTransforms)
                            .font(.appSerif(size: 14, weight: .medium))
                            .foregroundColor(.flowingGold)
                    }

                    HStack(spacing: 8) {
                        if let lu = chart.fourTransforms.luStar {
                            FourTransformChip(type: .lu, star: lu)
                        }
                        if let quan = chart.fourTransforms.quanStar {
                            FourTransformChip(type: .quan, star: quan)
                        }
                        if let ke = chart.fourTransforms.keStar {
                            FourTransformChip(type: .ke, star: ke)
                        }
                        if let ji = chart.fourTransforms.jiStar {
                            FourTransformChip(type: .ji, star: ji)
                        }
                        Spacer()
                    }
                }
                .padding(16)
                .background(Color.cardBackgroundSolid.opacity(0.9))
                .cornerRadius(Theme.cardCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            }

            // Major Limits
            if !chart.majorLimits.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Rectangle()
                            .fill(Color.flowingGold)
                            .frame(width: 3, height: 14)
                        Text(localizationManager.strings.decadalCycle)
                            .font(.appSerif(size: 14, weight: .medium))
                            .foregroundColor(.flowingGold)
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(chart.majorLimits.prefix(8)) { limit in
                            MajorLimitCard(limit: limit)
                        }
                    }
                }
                .padding(16)
                .background(Color.cardBackgroundSolid.opacity(0.9))
                .cornerRadius(Theme.cardCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            }
        }
        .sheet(item: $selectedPalace) { palace in
            PalaceDetailView(palace: palace)
        }
        .onAppear {
            // 启动闪烁动画
            if showGuideHint {
                withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    hintOpacity = 0.6
                }
            }
        }
    }

    private func dismissGuideHint() {
        withAnimation(.easeOut(duration: 0.3)) {
            showGuideHint = false
        }
        UserDefaults.standard.set(true, forKey: "hasSeenChartGuide")
    }
}

// MARK: - Chart Guide Hint View
struct ChartGuideHintView: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "hand.tap.fill")
                .font(.system(size: 14))
                .foregroundColor(.flowingGold)

            Text(message)
                .font(.appSerif(size: 12, weight: .medium))
                .foregroundColor(.foregroundText.opacity(0.9))

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.mutedText)
                    .padding(6)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.deepSpaceMid.opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.flowingGold.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 12)
    }
}

struct PalaceCell: View {
    let palace: Palace
    let cellSize: CGFloat

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background - use solid color for better readability
            RoundedRectangle(cornerRadius: 6)
                .fill(palace.isBodyPalace ? Color.flowingGold.opacity(0.15) : Color.deepSpaceMid)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(
                            palace.isBodyPalace ? Color.flowingGold.opacity(0.5) : Color.white.opacity(0.15),
                            lineWidth: 1
                        )
                )

            VStack(alignment: .leading, spacing: 2) {
                // Header (Name + Branch)
                HStack(spacing: 0) {
                    Text(palace.name.shortLocalizedName)
                        .font(.appSerif(size: 9, weight: .bold))
                        .foregroundColor(palace.isBodyPalace ? .flowingGold : .foregroundText)
                        .lineLimit(1)

                    Spacer(minLength: 0)

                    Text(palace.earthlyBranch)
                        .font(.appSerif(size: 8))
                        .foregroundColor(.mutedText)
                }
                .padding(.horizontal, 3)
                .padding(.top, 3)

                // Stars Content - simplified single column
                VStack(alignment: .leading, spacing: 1) {
                    ForEach(palace.stars.prefix(6), id: \.name) { star in
                        HStack(spacing: 2) {
                            Text(star.name)
                                .font(.appSerif(size: 8))
                                .foregroundColor(isMajor(star) ? .flowingGold : .foregroundText.opacity(0.85))
                                .lineLimit(1)

                            if let transform = star.fourTransform {
                                Text(transform.rawValue)
                                    .font(.appSerif(size: 6, weight: .bold))
                                    .foregroundColor(transformColor(transform))
                            }
                        }
                    }
                }
                .padding(.horizontal, 3)

                Spacer(minLength: 0)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    func isMajor(_ star: Star) -> Bool {
        return star.type == .major
    }

    func transformColor(_ type: FourTransformType) -> Color {
        return Color(hex: type.color)
    }
}

struct PalaceDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let palace: Palace
    @ObservedObject private var localizationManager = LocalizationManager.shared

    var body: some View {
        ZStack {
            StarFieldBackground()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.appSerif(size: 16, weight: .bold))
                            .foregroundColor(.gray)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .padding()
                }

                ScrollView {
                    VStack(spacing: 20) {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text(palace.name.localizedName)
                                        .font(.appSerif(size: 24, weight: .bold))
                                        .foregroundColor(.foregroundText)

                                    if palace.isBodyPalace {
                                        Text(localizationManager.strings.bodyPalaceBadge)
                                            .font(.appSerif(size: 12, weight: .regular))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.flowingGold)
                                            .foregroundColor(.deepSpaceStart)
                                            .cornerRadius(4)
                                    }

                                    Spacer()

                                    Text("[\(palace.earthlyBranch)\(palace.heavenlyStem ?? "")]")
                                        .font(.appSerif(size: 16, weight: .regular))
                                        .foregroundColor(.gray)
                                }

                                Divider().background(Color.gray.opacity(0.3))

                                if !palace.stars.isEmpty {
                                    ForEach(palace.stars, id: \.name) { star in
                                        HStack {
                                            Text(star.name)
                                                .font(.appSerif(size: 16, weight: star.type == .major ? .medium : .regular))
                                                .foregroundColor(star.type == .major ? .flowingGold : .foregroundText)

                                            if let brightness = star.brightness {
                                                Text("[\(brightness)]")
                                                    .font(.appSerif(size: 12, weight: .regular))
                                                    .foregroundColor(.gray)
                                            }

                                            Spacer()

                                            if let transform = star.fourTransform {
                                                Text(transform.rawValue)
                                                    .font(.appSerif(size: 12, weight: .bold))
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(transformColor(transform).opacity(0.2))
                                                    .foregroundColor(transformColor(transform))
                                                    .cornerRadius(4)
                                            }

                                            Text(star.type.rawValue)
                                                .font(.appSerif(size: 12, weight: .regular))
                                                .foregroundColor(.gray.opacity(0.5))
                                        }
                                        .padding(.vertical, 4)
                                    }
                                } else {
                                    Text(localizationManager.strings.noMajorStars)
                                        .font(.appSerif(size: 14, weight: .regular))
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding()
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
    }

    func transformColor(_ type: FourTransformType) -> Color {
        return Color(hex: type.color)
    }
}

struct InfoChip: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.appSerif(size: 9, weight: .regular))
                .foregroundColor(.mutedText)
            Text(value)
                .font(.appSerif(size: 11, weight: .medium))
                .foregroundColor(.flowingGold)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.08))
        .cornerRadius(6)
    }
}

struct FourTransformChip: View {
    let type: FourTransformType
    let star: String

    var body: some View {
        HStack(spacing: 3) {
            Text(type.rawValue)
                .font(.appSerif(size: 11, weight: .bold))
            Text(star)
                .font(.appSerif(size: 11, weight: .regular))
        }
        .foregroundColor(.deepSpaceStart)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(typeColor(type))
        .cornerRadius(4)
    }

    func typeColor(_ type: FourTransformType) -> Color {
        switch type {
        case .lu: return Color(hex: "22C55E") // green
        case .quan: return Color(hex: "EF4444") // red
        case .ke: return Color(hex: "3B82F6") // blue
        case .ji: return Color(hex: "6B7280") // gray
        }
    }
}

struct MajorLimitCard: View {
    let limit: MajorLimit

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(limit.ageRange)
                    .font(.appSerif(size: 13, weight: .semibold))
                    .foregroundColor(.flowingGold)

                Text(limit.palace.localizedName)
                    .font(.appSerif(size: 11, weight: .regular))
                    .foregroundColor(.mutedText)
            }
            Spacer()
        }
        .padding(10)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
}

struct ChartDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        // Dummy Data for Preview
        let sampleStars = [
            Star(name: "紫微", type: .major, brightness: "旺", fourTransform: .lu),
            Star(name: "天机", type: .major, brightness: "庙", fourTransform: nil)
        ]
        let samplePalaces = [Palace(
            name: .ming,
            earthlyBranch: "寅",
            heavenlyStem: "甲",
            stars: sampleStars,
            position: 0,
            isBodyPalace: true,
            majorLimit: "1-10",
            relationships: nil,
            changsheng12: nil,
            boshi12: nil,
            selfMutations: nil,
            flyingStars: nil
        )]
        let chart = ZiWeiChart(
            palaces: samplePalaces,
            birthYear: "甲子",
            fiveElementBureau: "水二局",
            bodyMaster: "火星",
            lifeMaster: "铃星",
            mingPalace: .ming,
            bodyPalace: .ming,
            fourTransforms: FourTransforms(luStar: "紫微", quanStar: "太阳", keStar: nil, jiStar: nil),
            majorLimits: []
        )

        ChartDisplayView(chart: chart)
    }
}
