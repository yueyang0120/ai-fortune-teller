import SwiftUI

// MARK: - Reading Result View (Main View)
struct ReadingResultView: View {
    let reading: FortuneReading
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var activeTab: ResultTab = .analysis
    @State private var showingShareSheet = false

    enum ResultTab {
        case analysis
        case chart
    }

    private var strings: LocalizedStrings {
        localizationManager.strings
    }

    var body: some View {
        ZStack {
            StarFieldBackground()

            VStack(spacing: 0) {
                // Header
                headerView

                // Birth Info Card
                birthInfoCard
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                // Tab Switcher
                tabSwitcher
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                // Content
                if activeTab == .analysis {
                    analysisContent
                } else {
                    chartContent
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [createShareText()])
        }
    }

    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .font(.appSerif(size: 20))
                    .foregroundColor(.mutedText)
            }
            .accessibilityLabel(strings.back)

            Spacer()

            Text(strings.categoryTitle(for: reading.birthInfo.analysisTopic))
                .font(.appSerif(size: 18, weight: .medium))
                .foregroundColor(.foregroundText)

            Spacer()

            Button(action: {
                showingShareSheet = true
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.appSerif(size: 20))
                    .foregroundColor(.mutedText)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    // MARK: - Birth Info Card
    private var birthInfoCard: some View {
        VStack(spacing: 8) {
            HStack {
                HStack(spacing: 0) {
                    Text(reading.birthInfo.gender == .male ? strings.maleShort : strings.femaleShort)
                        .foregroundColor(.flowingGold)
                    Text(" · ")
                        .foregroundColor(.mutedText)
                    Text(reading.birthInfo.displayDateString)
                        .foregroundColor(.mutedText)
                }
                .font(.appSerif(size: 14, weight: .regular))

                Spacer()

                Text(reading.birthInfo.localizedBirthTime)
                    .font(.appSerif(size: 14, weight: .medium))
                    .foregroundColor(.flowingGold)
            }

            if !reading.birthInfo.location.isEmpty {
                HStack {
                    Text("\(strings.birthPlaceLabel): \(reading.birthInfo.location)")
                        .font(.appSerif(size: 12, weight: .regular))
                        .foregroundColor(.mutedText)

                    if reading.birthInfo.useRealSolarTime {
                        Text(" · \(strings.trueSolarTime)")
                            .font(.appSerif(size: 12, weight: .regular))
                            .foregroundColor(.mutedText)
                    }

                    Spacer()
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(Theme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    // MARK: - Tab Switcher
    private var tabSwitcher: some View {
        HStack(spacing: 0) {
            tabButton(title: strings.fortuneAnalysis, icon: "book", tab: .analysis)
            tabButton(title: strings.chart, icon: "square.grid.3x3", tab: .chart)
        }
        .padding(6)
        .background(Color.cardBackground)
        .cornerRadius(Theme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    private func tabButton(title: String, icon: String, tab: ResultTab) -> some View {
        Button(action: {
            if activeTab != tab {
                HapticManager.lightImpact()
            }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                activeTab = tab
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.appSerif(size: 14))
                Text(title)
                    .font(.appSerif(size: 14, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(activeTab == tab ? Color.flowingGold : Color.clear)
            .foregroundColor(activeTab == tab ? .deepSpaceStart : .mutedText)
            .cornerRadius(Theme.smallCornerRadius)
        }
    }

    // MARK: - Analysis Content
    private var analysisContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                analysisCard
                    .padding(.horizontal, 20)

                PostAnalysisHintsView(
                    onGoToHistory: {
                        NotificationCenter.default.post(name: .postAnalysisGoToHistory, object: nil)
                        presentationMode.wrappedValue.dismiss()
                    },
                    onTryAnother: {
                        NotificationCenter.default.post(name: .postAnalysisTryAnother, object: nil)
                        presentationMode.wrappedValue.dismiss()
                    },
                    onShare: {
                        showingShareSheet = true
                    }
                )
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
        }
    }

    private var analysisCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            StyledMarkdownView(text: reading.analysis)
        }
        .padding(20)
        .background(Color.cardBackgroundSolid.opacity(0.95))
        .cornerRadius(Theme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    // MARK: - Chart Content
    private var chartContent: some View {
        ScrollView {
            ChartDisplayView(chart: reading.chart)
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
        }
    }

    // MARK: - Share Text
    private func createShareText() -> String {
        return """
        \(strings.appTitle) - \(reading.birthInfo.displayDateString)

        \(reading.birthInfo.fullDisplayString)

        \(strings.fiveElements)：\(reading.chart.fiveElementBureau)
        \(strings.lifeMaster)：\(reading.chart.lifeMaster)
        \(strings.bodyMaster)：\(reading.chart.bodyMaster)

        ---

        \(reading.analysis)

        ---

        \(strings.generatedTime)：\(reading.displayDateString)
        \(strings.aiDisclaimer)
        """
    }
}

// MARK: - Styled Markdown View
struct StyledMarkdownView: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                renderLine(line, index: index)
            }
        }
    }

    private var lines: [String] {
        // Split by newlines but preserve structure
        text.components(separatedBy: "\n").filter { line in
            !line.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }

    @ViewBuilder
    private func renderLine(_ line: String, index: Int) -> some View {
        let trimmed = line.trimmingCharacters(in: .whitespaces)

        if trimmed.hasPrefix("【") && trimmed.contains("】") {
            // 【Title】 style - Major title in brackets
            Text(trimmed)
                .font(.appSerif(size: 20, weight: .bold))
                .foregroundColor(.flowingGold)
                .padding(.top, index > 0 ? 12 : 0)
                .padding(.bottom, 4)
        } else if isChineseNumberedHeading(trimmed) {
            // Chinese numbered heading like "一、性格特质深度分析"
            HStack(alignment: .top, spacing: 8) {
                Rectangle()
                    .fill(Color.flowingGold)
                    .frame(width: 3, height: 22)
                    .cornerRadius(1.5)

                Text(parseInlineStyles(trimmed))
                    .font(.appSerif(size: 17, weight: .semibold))
                    .foregroundColor(.foregroundText)
                    .lineSpacing(4)
            }
            .padding(.top, index > 0 ? 16 : 0)
        } else if trimmed.hasPrefix("# ") {
            // H1 Heading
            Text(parseInlineStyles(String(trimmed.dropFirst(2))))
                .font(.appSerif(size: 22, weight: .bold))
                .foregroundColor(.flowingGold)
                .padding(.top, index > 0 ? 16 : 0)
        } else if trimmed.hasPrefix("## ") {
            // H2 Heading
            HStack(alignment: .top, spacing: 8) {
                Rectangle()
                    .fill(Color.flowingGold)
                    .frame(width: 3, height: 20)
                    .cornerRadius(1.5)

                Text(parseInlineStyles(String(trimmed.dropFirst(3))))
                    .font(.appSerif(size: 18, weight: .semibold))
                    .foregroundColor(.foregroundText)
            }
            .padding(.top, index > 0 ? 12 : 0)
        } else if trimmed.hasPrefix("### ") {
            // H3 Heading
            Text(parseInlineStyles(String(trimmed.dropFirst(4))))
                .font(.appSerif(size: 16, weight: .semibold))
                .foregroundColor(.flowingGold)
                .padding(.top, index > 0 ? 8 : 0)
        } else if trimmed.hasPrefix("#### ") {
            // H4 Heading
            Text(parseInlineStyles(String(trimmed.dropFirst(5))))
                .font(.appSerif(size: 15, weight: .medium))
                .foregroundColor(.foregroundText.opacity(0.9))
                .padding(.top, index > 0 ? 6 : 0)
        } else if trimmed.hasPrefix("> ") {
            // Blockquote
            HStack(alignment: .top, spacing: 0) {
                Rectangle()
                    .fill(Color.flowingGold.opacity(0.5))
                    .frame(width: 3)

                Text(parseInlineStyles(String(trimmed.dropFirst(2))))
                    .font(.appSerif(size: 14, weight: .regular))
                    .italic()
                    .foregroundColor(.mutedText)
                    .padding(.leading, 12)
                    .padding(.vertical, 8)
            }
            .background(Color.flowingGold.opacity(0.05))
            .cornerRadius(4)
        } else if trimmed.hasPrefix("---") || trimmed.hasPrefix("***") {
            // Divider
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.clear, Color.flowingGold.opacity(0.3), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
                .padding(.vertical, 8)
        } else if trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ") {
            // Unordered list item
            renderBulletItem(trimmed)
        } else if isNumberedListItem(trimmed) {
            // Numbered list item like "1. xxx"
            renderNumberedItem(trimmed)
        } else {
            // Regular paragraph
            Text(parseInlineStyles(trimmed))
                .font(.appSerif(size: 15, weight: .regular))
                .foregroundColor(.foregroundText.opacity(0.9))
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func isChineseNumberedHeading(_ text: String) -> Bool {
        let chineseNumbers = ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]
        for num in chineseNumbers {
            if text.hasPrefix("\(num)、") || text.hasPrefix("\(num).") || text.hasPrefix("\(num)，") {
                return true
            }
        }
        return false
    }

    private func isNumberedListItem(_ text: String) -> Bool {
        guard let first = text.first, first.isNumber else { return false }
        return text.contains(". ") || text.contains(".")
    }

    @ViewBuilder
    private func renderBulletItem(_ text: String) -> some View {
        let content = text.hasPrefix("- ") ? String(text.dropFirst(2)) :
                      text.hasPrefix("* ") ? String(text.dropFirst(2)) : text

        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(Color.flowingGold)
                .frame(width: 5, height: 5)
                .padding(.top, 7)

            Text(parseInlineStyles(content.trimmingCharacters(in: .whitespaces)))
                .font(.appSerif(size: 15, weight: .regular))
                .foregroundColor(.foregroundText.opacity(0.9))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private func renderNumberedItem(_ text: String) -> some View {
        // Extract number and content
        let parts = text.split(separator: ".", maxSplits: 1)
        let number = String(parts.first ?? "")
        let content = parts.count > 1 ? String(parts[1]).trimmingCharacters(in: .whitespaces) : ""

        HStack(alignment: .top, spacing: 8) {
            Text("\(number).")
                .font(.appSerif(size: 15, weight: .semibold))
                .foregroundColor(.flowingGold)
                .frame(minWidth: 20, alignment: .leading)

            Text(parseInlineStyles(content))
                .font(.appSerif(size: 15, weight: .regular))
                .foregroundColor(.foregroundText.opacity(0.9))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func parseInlineStyles(_ text: String) -> AttributedString {
        var currentText = text
        var result = AttributedString()

        // Process the text character by character to handle **bold**
        while !currentText.isEmpty {
            if let boldStart = currentText.range(of: "**") {
                // Add text before the bold marker
                let beforeBold = String(currentText[..<boldStart.lowerBound])
                if !beforeBold.isEmpty {
                    var beforeAttr = AttributedString(beforeBold)
                    beforeAttr.font = Font.appSerif(size: 15, weight: .regular)
                    beforeAttr.foregroundColor = Color.foregroundText.opacity(0.9)
                    result.append(beforeAttr)
                }

                // Find the closing **
                let afterFirstMarker = String(currentText[boldStart.upperBound...])
                if let boldEnd = afterFirstMarker.range(of: "**") {
                    let boldContent = String(afterFirstMarker[..<boldEnd.lowerBound])
                    var boldAttr = AttributedString(boldContent)
                    boldAttr.font = Font.appSerif(size: 15, weight: .bold)
                    boldAttr.foregroundColor = Color.flowingGold
                    result.append(boldAttr)

                    currentText = String(afterFirstMarker[boldEnd.upperBound...])
                } else {
                    // No closing **, treat as regular text
                    var remaining = AttributedString(currentText)
                    remaining.font = Font.appSerif(size: 15, weight: .regular)
                    remaining.foregroundColor = Color.foregroundText.opacity(0.9)
                    result.append(remaining)
                    break
                }
            } else {
                // No more bold markers, add remaining text
                var remaining = AttributedString(currentText)
                remaining.font = Font.appSerif(size: 15, weight: .regular)
                remaining.foregroundColor = Color.foregroundText.opacity(0.9)
                result.append(remaining)
                break
            }
        }

        return result
    }
}

// MARK: - Reading Result View With Loading (for in-progress analysis)
struct ReadingResultViewWithLoading: View {
    let taskId: UUID
    let birthInfo: BirthInfo
    let chart: ZiWeiChart
    @State private var analysis: String? = nil
    @State private var isAnalysisComplete = false
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var activeTab: ReadingResultView.ResultTab = .chart // 默认先显示命盘
    @State private var showingShareSheet = false
    @State private var loadingDots = ""
    @State private var pulseScale: CGFloat = 1.0
    @State private var showCompletionBanner = false
    @State private var chartInsights: [ChartInsightItem] = []

    private var strings: LocalizedStrings {
        localizationManager.strings
    }

    var body: some View {
        ZStack {
            StarFieldBackground()

            VStack(spacing: 0) {
                // Header with loading indicator
                headerView

                // Birth Info Card
                birthInfoCard
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                // Tab Switcher
                tabSwitcher
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                // Content
                if activeTab == .analysis {
                    analysisContent
                } else {
                    chartContent
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let analysisText = analysis {
                ShareSheet(items: [createShareText(analysisText)])
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .fortuneTaskCompleted)) { notification in
            guard let notificationTaskId = notification.userInfo?["taskId"] as? UUID,
                  notificationTaskId == taskId,
                  let reading = notification.userInfo?["reading"] as? FortuneReading else {
                return
            }

            withAnimation(.easeInOut(duration: 0.5)) {
                self.analysis = reading.analysis
                self.isAnalysisComplete = true
            }

            // If user is on chart tab, show banner to guide them
            if activeTab == .chart {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showCompletionBanner = true
                }
            }
        }
        .onAppear {
            chartInsights = ChartInsightsEngine(chart: chart).generateInsights()
            startLoadingAnimation()
        }
    }

    private func startLoadingAnimation() {
        // Dots animation
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if isAnalysisComplete {
                timer.invalidate()
                return
            }
            loadingDots = loadingDots.count >= 3 ? "" : loadingDots + "."
        }

        // Pulse animation
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            pulseScale = 1.15
        }
    }

    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .font(.appSerif(size: 20))
                    .foregroundColor(.mutedText)
            }

            Spacer()

            Text(strings.categoryTitle(for: birthInfo.analysisTopic))
                .font(.appSerif(size: 18, weight: .medium))
                .foregroundColor(.foregroundText)

            Spacer()

            // Loading indicator in header when analysis is not complete
            if !isAnalysisComplete {
                HStack(spacing: 6) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .flowingGold))
                        .scaleEffect(0.8)
                }
            } else {
                Button(action: {
                    showingShareSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.appSerif(size: 20))
                        .foregroundColor(.mutedText)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    // MARK: - Birth Info Card
    private var birthInfoCard: some View {
        VStack(spacing: 8) {
            HStack {
                HStack(spacing: 0) {
                    Text(birthInfo.gender == .male ? strings.maleShort : strings.femaleShort)
                        .foregroundColor(.flowingGold)
                    Text(" · ")
                        .foregroundColor(.mutedText)
                    Text(birthInfo.displayDateString)
                        .foregroundColor(.mutedText)
                }
                .font(.appSerif(size: 14, weight: .regular))

                Spacer()

                Text(birthInfo.localizedBirthTime)
                    .font(.appSerif(size: 14, weight: .medium))
                    .foregroundColor(.flowingGold)
            }

            if !birthInfo.location.isEmpty {
                HStack {
                    Text("\(strings.birthPlaceLabel): \(birthInfo.location)")
                        .font(.appSerif(size: 12, weight: .regular))
                        .foregroundColor(.mutedText)

                    if birthInfo.useRealSolarTime {
                        Text(" · \(strings.trueSolarTime)")
                            .font(.appSerif(size: 12, weight: .regular))
                            .foregroundColor(.mutedText)
                    }

                    Spacer()
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(Theme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    // MARK: - Tab Switcher
    private var tabSwitcher: some View {
        HStack(spacing: 0) {
            tabButton(title: strings.fortuneAnalysis, icon: "book", tab: .analysis, showBadge: !isAnalysisComplete)
            tabButton(title: strings.chart, icon: "square.grid.3x3", tab: .chart, showBadge: false)
        }
        .padding(6)
        .background(Color.cardBackground)
        .cornerRadius(Theme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    private func tabButton(title: String, icon: String, tab: ReadingResultView.ResultTab, showBadge: Bool) -> some View {
        Button(action: {
            if activeTab != tab {
                HapticManager.lightImpact()
            }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                activeTab = tab
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.appSerif(size: 14))
                Text(title)
                    .font(.appSerif(size: 14, weight: .medium))

                // Show loading badge
                if showBadge {
                    Circle()
                        .fill(Color.flowingGold)
                        .frame(width: 8, height: 8)
                        .scaleEffect(pulseScale)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(activeTab == tab ? Color.flowingGold : Color.clear)
            .foregroundColor(activeTab == tab ? .deepSpaceStart : .mutedText)
            .cornerRadius(Theme.smallCornerRadius)
        }
    }

    // MARK: - Analysis Content
    private var analysisContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                if let analysisText = analysis {
                    // Analysis is complete
                    analysisCard(text: analysisText)
                        .padding(.horizontal, 20)

                    PostAnalysisHintsView(
                        onGoToHistory: {
                            NotificationCenter.default.post(name: .postAnalysisGoToHistory, object: nil)
                            presentationMode.wrappedValue.dismiss()
                        },
                        onTryAnother: {
                            NotificationCenter.default.post(name: .postAnalysisTryAnother, object: nil)
                            presentationMode.wrappedValue.dismiss()
                        },
                        onShare: {
                            showingShareSheet = true
                        }
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                } else {
                    // Analysis is loading
                    analysisLoadingCard
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                }
            }
        }
    }

    private func analysisCard(text: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            StyledMarkdownView(text: text)
        }
        .padding(20)
        .background(Color.cardBackgroundSolid.opacity(0.95))
        .cornerRadius(Theme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    private var analysisLoadingCard: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.flowingGold.opacity(0.1))
                    .frame(width: 80, height: 80)
                    .scaleEffect(pulseScale)

                Image(systemName: "sparkles")
                    .font(.appSerif(size: 36))
                    .foregroundColor(.flowingGold)
            }

            VStack(spacing: 12) {
                Text(strings.analysisGenerating + loadingDots)
                    .font(.appSerif(size: 18, weight: .semibold))
                    .foregroundColor(.foregroundText)

                Text(strings.analysisGeneratingHint)
                    .font(.appSerif(size: 14, weight: .regular))
                    .foregroundColor(.mutedText)
                    .multilineTextAlignment(.center)

                Text(strings.viewChartWhileLoading)
                    .font(.appSerif(size: 13, weight: .regular))
                    .foregroundColor(.flowingGold.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }

            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .flowingGold))
                .scaleEffect(1.2)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
        .background(Color.cardBackgroundSolid.opacity(0.95))
        .cornerRadius(Theme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    // MARK: - Chart Content
    private var chartContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Completion banner when analysis finishes while on chart tab
                if showCompletionBanner && isAnalysisComplete {
                    completionBanner
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                // Chart Insights (always visible in chart tab)
                if !chartInsights.isEmpty {
                    ChartInsightsView(insights: chartInsights)
                        .padding(16)
                        .background(Color.cardBackgroundSolid.opacity(0.95))
                        .cornerRadius(Theme.cardCornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                }

                // History reminder (only during loading)
                if !isAnalysisComplete {
                    HStack(spacing: 10) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.appSerif(size: 14))
                            .foregroundColor(.flowingGold.opacity(0.7))

                        Text(strings.insightHistoryReminder)
                            .font(.appSerif(size: 13, weight: .regular))
                            .foregroundColor(.mutedText.opacity(0.8))
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.flowingGold.opacity(0.05))
                    .cornerRadius(Theme.smallCornerRadius)
                }

                ChartDisplayView(chart: chart)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Completion Banner
    private var completionBanner: some View {
        Button(action: {
            HapticManager.lightImpact()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                activeTab = .analysis
                showCompletionBanner = false
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.appSerif(size: 18))
                    .foregroundColor(.flowingGold)

                VStack(alignment: .leading, spacing: 2) {
                    Text(strings.insightAnalysisReady)
                        .font(.appSerif(size: 14, weight: .semibold))
                        .foregroundColor(.foregroundText)

                    Text(strings.insightViewAnalysis)
                        .font(.appSerif(size: 12, weight: .regular))
                        .foregroundColor(.flowingGold)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.appSerif(size: 13))
                    .foregroundColor(.flowingGold.opacity(0.7))
            }
            .padding(14)
            .background(Color.flowingGold.opacity(0.1))
            .cornerRadius(Theme.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                    .stroke(Color.flowingGold.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Share Text
    private func createShareText(_ analysisText: String) -> String {
        return """
        \(strings.appTitle) - \(birthInfo.displayDateString)

        \(birthInfo.fullDisplayString)

        \(strings.fiveElements)：\(chart.fiveElementBureau)
        \(strings.lifeMaster)：\(chart.lifeMaster)
        \(strings.bodyMaster)：\(chart.bodyMaster)

        ---

        \(analysisText)

        ---

        \(strings.generatedTime)：\(LocalizationManager.shared.strings.formatTimestamp(Date()))
        \(strings.aiDisclaimer)
        """
    }
}

// MARK: - Fortune Analysis View (Legacy - kept for compatibility)
struct FortuneAnalysisView: View {
    let analysis: String
    @State private var expandedSections: Set<String> = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                StyledMarkdownView(text: analysis)
                    .padding()
            }
        }
        .background(Color.clear)
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview
struct ReadingResultView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleChart = ZiWeiChart(
            palaces: [],
            birthYear: "甲子",
            fiveElementBureau: "水二局",
            bodyMaster: "天相",
            lifeMaster: "贪狼",
            mingPalace: .ming,
            bodyPalace: .ming,
            fourTransforms: FourTransforms(luStar: "紫微", quanStar: "太阳", keStar: nil, jiStar: nil),
            majorLimits: []
        )

        let sampleBirthInfo = BirthInfo(
            solarDate: Date(),
            lunarDate: nil,
            birthTime: "午时",
            birthHour: 12,
            birthMinute: 0,
            location: "北京市",
            longitude: 116.4,
            latitude: 39.9,
            gender: .male,
            calendarType: .solar,
            useRealSolarTime: false,
            analysisTopic: .overall
        )

        let sampleAnalysis = """
        【紫微斗数命盘全息深度解析】

        一、性格特质深度分析：聪明反被聪明误？

        1. 核心性格：机灵与焦虑的矛盾体
        * **一针见血**：你是一个**"脑子永远停不下来"**的人。
        * **命宫[壬午]天机化禄**：天机星主智慧、变动，化禄代表乐观和机缘。你反应极快，足智多谋，给人的第一印象通常是开朗、好说话、有亲和力的。你擅长策划，脑子里总有新点子。
        * **矛盾点（官禄宫太阴化忌）**：这是你命盘最大的痛点。虽然命宫化禄让你看起来光鲜，但官禄宫（事业/内心深层）的**太阴化忌**，意味着你内心深处极度缺乏安全感，容易焦虑，有完美主义倾向。

        二、事业周期分析

        根据您的紫微命盘分析，您具有以下核心特质：

        - **领导才能**：天生具备组织协调能力
        - **思维敏捷**：善于分析问题，逻辑清晰
        - **意志坚定**：面对困难不轻言放弃

        ### 性格优势

        您的命宫主星组合显示出强大的执行力和决断力。

        > 命由己造，运随心转。把握当下，方能成就未来。

        ---

        **温馨提示**：以上分析仅供参考，人生的精彩在于自己的努力与选择。
        """

        let sampleReading = FortuneReading(
            id: UUID(),
            birthInfo: sampleBirthInfo,
            chart: sampleChart,
            analysis: sampleAnalysis,
            timestamp: Date()
        )

        ReadingResultView(reading: sampleReading)
    }
}
