import SwiftUI

struct SynastryResultView: View {
    let synastryInfo: SynastryInfo
    @State private var analysis: String?
    @State private var isAnalysisComplete: Bool
    @State private var analysisError: String?

    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var localizationManager = LocalizationManager.shared

    @State private var headerOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var loadingDots = ""
    @State private var pulseScale: CGFloat = 1.0

    private var strings: LocalizedStrings {
        localizationManager.strings
    }

    /// Init with completed analysis (e.g. from history)
    init(synastryInfo: SynastryInfo, analysis: String) {
        self.synastryInfo = synastryInfo
        _analysis = State(initialValue: analysis)
        _isAnalysisComplete = State(initialValue: true)
    }

    /// Init with charts ready but analysis still loading
    init(synastryInfo: SynastryInfo) {
        self.synastryInfo = synastryInfo
        _analysis = State(initialValue: nil)
        _isAnalysisComplete = State(initialValue: false)
    }

    var body: some View {
        NavigationView {
            ZStack {
                StarFieldBackground()

                ScrollView {
                    VStack(spacing: 20) {
                        synastryTypeHeader

                        if let chartA = synastryInfo.chartA, let chartB = synastryInfo.chartB {
                            dualChartSummary(chartA: chartA, chartB: chartB)
                        }

                        if let analysisText = analysis {
                            analysisSection(text: analysisText)

                            PostAnalysisHintsView(
                                onGoToHistory: {
                                    NotificationCenter.default.post(name: .postAnalysisGoToHistory, object: nil)
                                    dismiss()
                                },
                                onTryAnother: {
                                    NotificationCenter.default.post(name: .postAnalysisTryAnother, object: nil)
                                    dismiss()
                                }
                            )
                        } else if let error = analysisError {
                            analysisErrorSection(error: error)
                        } else {
                            analysisLoadingSection
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.appSerif(size: 16, weight: .semibold))
                            Text(strings.back)
                                .font(.appSerif(size: 16, weight: .medium))
                        }
                        .foregroundColor(.flowingGold)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let analysisText = analysis {
                        ShareLink(item: analysisText) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.appSerif(size: 16))
                                .foregroundColor(.flowingGold)
                        }
                    } else {
                        // Loading indicator in toolbar
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .flowingGold))
                            .scaleEffect(0.8)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                headerOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                contentOpacity = 1
            }
            if !isAnalysisComplete {
                // Add in-progress entry to history immediately
                ReadingHistoryService.shared.addInProgressSynastry(synastryInfo: synastryInfo)
                startLoadingAnimation()
                startAnalysis()
            }
        }
    }

    // MARK: - Background Analysis

    private func startAnalysis() {
        Task {
            do {
                let analyzerService = FortuneAnalyzerService()

                let result = try await withThrowingTaskGroup(of: String.self) { group in
                    group.addTask {
                        try await analyzerService.analyzeSynastry(synastryInfo: synastryInfo)
                    }
                    group.addTask {
                        try await Task.sleep(nanoseconds: 120_000_000_000)
                        throw FortuneAnalyzerError.invalidResponse
                    }
                    let result = try await group.next()!
                    group.cancelAll()
                    return result
                }

                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.analysis = result
                        self.isAnalysisComplete = true
                    }
                    // Update the in-progress entry with completed analysis
                    ReadingHistoryService.shared.completeSynastryReading(
                        id: synastryInfo.id,
                        analysis: result
                    )
                }
            } catch {
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.analysisError = error.localizedDescription
                        self.isAnalysisComplete = true
                    }
                    // Update the in-progress entry to failed
                    ReadingHistoryService.shared.updateTaskStatus(
                        taskId: synastryInfo.id,
                        status: .failed,
                        errorMessage: error.localizedDescription
                    )
                }
            }
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
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.1
        }
    }

    // MARK: - Synastry Type Header

    private var synastryTypeHeader: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.flowingGold.opacity(0.1))
                    .frame(width: 48, height: 48)
                Image(systemName: synastryInfo.synastryType.icon)
                    .font(.appSerif(size: 24))
                    .foregroundColor(.flowingGold)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(strings.synastryTitle(for: synastryInfo.synastryType))
                    .font(.appSerif(size: 20, weight: .semibold))
                    .foregroundColor(.foregroundText)
                Text(isAnalysisComplete ? strings.synastryResultSubtitle : strings.analysisGeneratingHint)
                    .font(.appSerif(size: 14, weight: .regular))
                    .foregroundColor(.mutedText)
            }

            Spacer()
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(Theme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .stroke(Color.flowingGold.opacity(0.3), lineWidth: 1)
        )
        .opacity(headerOpacity)
        .padding(.top, 16)
    }

    // MARK: - Dual Chart Summary

    private func dualChartSummary(chartA: ZiWeiChart, chartB: ZiWeiChart) -> some View {
        HStack(spacing: 12) {
            chartSummaryCard(
                label: personALabel,
                info: synastryInfo.personA,
                chart: chartA
            )
            chartSummaryCard(
                label: personBLabel,
                info: synastryInfo.personB,
                chart: chartB
            )
        }
        .opacity(headerOpacity)
    }

    private var personALabel: String {
        if let role = synastryInfo.relationshipRole {
            return strings.rolePersonALabel(for: role)
        }
        if synastryInfo.synastryType == .pet {
            return strings.synastryPetOwner
        }
        return strings.synastryPersonA
    }

    private var personBLabel: String {
        if let role = synastryInfo.relationshipRole {
            return strings.rolePersonBLabel(for: role)
        }
        if synastryInfo.synastryType == .pet {
            return strings.synastryPetAnimal
        }
        return strings.synastryPersonB
    }

    private func chartSummaryCard(label: String, info: BirthInfo, chart: ZiWeiChart) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Prominent role badge
            Text(label)
                .font(.appSerif(size: 13, weight: .bold))
                .foregroundColor(.cardBackgroundSolid)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.flowingGold)
                .cornerRadius(6)

            Text(info.displayDateString)
                .font(.appSerif(size: 14, weight: .medium))
                .foregroundColor(.foregroundText)

            Text(info.localizedBirthTime)
                .font(.appSerif(size: 12, weight: .regular))
                .foregroundColor(.mutedText)

            Text("\(chart.fiveElementBureau)")
                .font(.appSerif(size: 12, weight: .regular))
                .foregroundColor(.mutedText)

            Text("\(strings.synastryMingPalace): \(chart.mingPalace.rawValue)")
                .font(.appSerif(size: 12, weight: .regular))
                .foregroundColor(.mutedText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.cardBackground)
        .cornerRadius(Theme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    // MARK: - Analysis Section (completed)

    private func analysisSection(text: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            StyledMarkdownView(text: text)
        }
        .padding(20)
        .background(Color.cardBackground)
        .cornerRadius(Theme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .opacity(contentOpacity)
    }

    // MARK: - Analysis Loading Section

    private var analysisLoadingSection: some View {
        VStack(spacing: 16) {
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.flowingGold.opacity(0.08))
                        .frame(width: 80, height: 80)
                        .scaleEffect(pulseScale)

                    Image(systemName: "sparkles")
                        .font(.appSerif(size: 32))
                        .foregroundColor(.flowingGold)
                }

                VStack(spacing: 8) {
                    Text(strings.analysisGenerating + loadingDots)
                        .font(.appSerif(size: 16, weight: .medium))
                        .foregroundColor(.foregroundText)

                    Text(strings.analysisGeneratingHint)
                        .font(.appSerif(size: 14, weight: .regular))
                        .foregroundColor(.mutedText)
                        .multilineTextAlignment(.center)
                }

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .flowingGold))
                    .scaleEffect(1.0)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
            .padding(.horizontal, 20)
            .background(Color.cardBackground)
            .cornerRadius(Theme.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )

            // History reminder
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
        .opacity(contentOpacity)
    }

    // MARK: - Analysis Error Section

    private func analysisErrorSection(error: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.appSerif(size: 32))
                .foregroundColor(.flowingGold)

            Text(error)
                .font(.appSerif(size: 14, weight: .regular))
                .foregroundColor(.mutedText)
                .multilineTextAlignment(.center)

            Button(action: {
                analysisError = nil
                isAnalysisComplete = false
                startLoadingAnimation()
                startAnalysis()
            }) {
                Text(strings.retry)
                    .font(.appSerif(size: 16, weight: .semibold))
                    .foregroundColor(.cardBackgroundSolid)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.flowingGold)
                    .cornerRadius(Theme.cardCornerRadius)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 20)
        .background(Color.cardBackground)
        .cornerRadius(Theme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .opacity(contentOpacity)
    }
}
