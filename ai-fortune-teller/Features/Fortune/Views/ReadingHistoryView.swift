import SwiftUI

// 用于在 sheet 中传递命盘数据的包装结构
struct LoadingChartData: Identifiable {
    let id: UUID
    let birthInfo: BirthInfo
    let chart: ZiWeiChart
}

struct ReadingHistoryView: View {
    @ObservedObject var historyService: ReadingHistoryService
    @ObservedObject var taskManager: FortuneTaskManager
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var selectedReading: FortuneReading?
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var retryingTaskId: UUID?
    @State private var showRetrySuccess = false
    @State private var retrySuccessMessage = ""
    @State private var taskToRetry: ReadingHistory?
    @State private var showRetryConfirmation = false
    @State private var isEditMode = false

    // 新增：用于显示正在加载的命盘视图
    @State private var loadingChartData: LoadingChartData?

    // Synastry history
    @State private var selectedSynastryResult: SynastryResultData?

    // Animation states
    @State private var headerOffset: CGFloat = -20
    @State private var headerOpacity: Double = 0

    private var strings: LocalizedStrings {
        localizationManager.strings
    }

    var body: some View {
        ZStack {
            StarFieldBackground()

            VStack(spacing: 0) {
                // Header - matching reference exactly
                headerView

                // Content
                if historyService.readings.isEmpty {
                    emptyStateView
                } else {
                    historyListView
                }
            }
        }
        .sheet(item: $selectedReading) { reading in
            ReadingResultView(reading: reading)
        }
        .sheet(item: $loadingChartData) { data in
            ReadingResultViewWithLoading(
                taskId: data.id,
                birthInfo: data.birthInfo,
                chart: data.chart
            )
        }
        .sheet(item: $selectedSynastryResult) { result in
            if let analysis = result.analysis {
                SynastryResultView(
                    synastryInfo: result.synastryInfo,
                    analysis: analysis
                )
            }
        }
        .alert(strings.error, isPresented: $showError) {
            Button(strings.confirm, role: .cancel) { }
        } message: {
            Text(errorMessage ?? strings.cannotLoadReading)
        }
        .alert(strings.retrySuccess, isPresented: $showRetrySuccess) {
            Button(strings.confirm, role: .cancel) { }
        } message: {
            Text(retrySuccessMessage)
        }
        .alert(strings.confirmRetry, isPresented: $showRetryConfirmation) {
            Button(strings.cancel, role: .cancel) {
                taskToRetry = nil
            }
            Button(strings.retry, role: .none) {
                if let task = taskToRetry {
                    retryTask(task)
                }
                taskToRetry = nil
            }
        } message: {
            if let task = taskToRetry {
                Text(strings.confirmRetryMessage(date: task.birthInfo.displayDateString))
            } else {
                Text(strings.confirmRetry)
            }
        }
        .onAppear {
            historyService.fetchReadings()
            withAnimation(.easeOut(duration: 0.5)) {
                headerOffset = 0
                headerOpacity = 1
            }
        }
    }

    // MARK: - Header View (matching reference)
    private var headerView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(strings.historyTitle)
                    .font(.appSerif(size: 24, weight: .semibold))
                    .foregroundColor(.foregroundText)

                Text(strings.historyCount(historyService.readings.count))
                    .font(.appSerif(size: 14, weight: .regular))
                    .foregroundColor(.mutedText)
            }

            Spacer()

            // 管理按钮
            if !historyService.readings.isEmpty {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isEditMode.toggle()
                    }
                }) {
                    Text(isEditMode ? strings.done : strings.manage)
                        .font(.appSerif(size: 15, weight: .medium))
                        .foregroundColor(.flowingGold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.flowingGold.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 16)
        .offset(y: headerOffset)
        .opacity(headerOpacity)
    }

    // MARK: - Empty State View (matching reference exactly)
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            // Icon container
            ZStack {
                Circle()
                    .fill(Color.cardBackgroundSolid.opacity(0.8))
                    .frame(width: 80, height: 80)

                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    .frame(width: 80, height: 80)

                Image(systemName: "clock")
                    .font(.appSerif(size: 32))
                    .foregroundColor(.mutedText.opacity(0.5))
            }

            Text(strings.noHistory)
                .font(.appSerif(size: 17, weight: .medium))
                .foregroundColor(.mutedText)

            Text(strings.startFirstReading)
                .font(.appSerif(size: 14, weight: .regular))
                .foregroundColor(.mutedText.opacity(0.6))

            Button(action: {
                NotificationCenter.default.post(name: .postAnalysisStartReading, object: nil)
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.appSerif(size: 15))
                    Text(strings.startReading)
                        .font(.appSerif(size: 15, weight: .medium))
                }
                .foregroundColor(.deepSpaceStart)
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
                .background(Color.flowingGold)
                .cornerRadius(Theme.smallCornerRadius)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 100)
    }

    // MARK: - History List View
    private var historyListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(historyService.readings.enumerated()), id: \.element.id) { index, history in
                    HistoryRecordCard(
                        history: history,
                        isRetrying: retryingTaskId == history.id,
                        isEditMode: isEditMode,
                        delay: Double(index) * 0.05,
                        strings: strings,
                        onTap: { handleHistoryTap(history) },
                        onRetry: {
                            taskToRetry = history
                            showRetryConfirmation = true
                        },
                        onDelete: {
                            historyService.deleteReading(history)
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 120)
        }
        .refreshable {
            historyService.fetchReadings()
        }
    }

    // MARK: - Handle History Tap
    private func handleHistoryTap(_ history: ReadingHistory) {
        switch history.status {
        case .completed:
            loadAndShowReading(history)
        case .synastry:
            if let synInfo = history.getSynastryInfo(),
               let analysis = history.synastryAnalysis {
                selectedSynastryResult = SynastryResultData(
                    synastryInfo: synInfo,
                    analysis: analysis
                )
            }
        case .analyzing:
            // 如果正在分析中且命盘数据已就绪，显示命盘（解读正在生成中）
            if let chart = history.getChartOnly() {
                loadingChartData = LoadingChartData(
                    id: history.id,
                    birthInfo: history.birthInfo,
                    chart: chart
                )
            }
            // 如果命盘还没生成，不做任何操作（卡片上已显示分析中状态）
        case .failed:
            // 失败的记录不再弹出错误窗口，错误信息已显示在卡片上
            // 用户可以点击卡片上的重试按钮进行重试
            break
        }
    }

    // MARK: - Helper Methods
    private func loadAndShowReading(_ history: ReadingHistory) {
        do {
            let reading = try history.getFullReading()
            selectedReading = reading
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func retryTask(_ history: ReadingHistory) {
        guard !history.isInvalidData else {
            errorMessage = strings.invalidData
            showError = true
            return
        }

        retryingTaskId = history.id
        let newTaskId = taskManager.retryTask(birthInfo: history.birthInfo, originalTaskId: history.id)
        print("🔄 Retrying task: \(history.id) -> new task: \(newTaskId)")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            retryingTaskId = nil
            retrySuccessMessage = strings.retrySuccessMessage
            showRetrySuccess = true
            historyService.fetchReadings()
        }
    }
}

// MARK: - History Record Card (matching reference exactly)
struct HistoryRecordCard: View {
    let history: ReadingHistory
    let isRetrying: Bool
    let isEditMode: Bool
    let delay: Double
    let strings: LocalizedStrings
    let onTap: () -> Void
    let onRetry: () -> Void
    let onDelete: () -> Void

    @State private var isVisible = false
    @State private var showDeleteConfirm = false

    var body: some View {
        HStack(spacing: 12) {
            // 编辑模式下显示删除按钮
            if isEditMode {
                Button(action: {
                    showDeleteConfirm = true
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.appSerif(size: 24))
                        .foregroundColor(.destructiveRed)
                }
                .transition(.scale.combined(with: .opacity))
            }

            // 主内容卡片
            cardContent
        }
        .opacity(isVisible ? 1 : 0)
        .offset(x: isVisible ? 0 : -20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(delay)) {
                isVisible = true
            }
        }
        .alert(strings.confirmDelete, isPresented: $showDeleteConfirm) {
            Button(strings.cancel, role: .cancel) { }
            Button(strings.delete, role: .destructive) {
                onDelete()
            }
        } message: {
            Text(strings.deleteReadingMessage)
        }
    }

    private var cardContent: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Top row: Category + Date + Status
                HStack {
                    // Category label - matching reference: text-primary text-sm font-medium
                    Text(topicDisplayTitle)
                        .font(.appSerif(size: 15, weight: .semibold))
                        .foregroundColor(.flowingGold)

                    Spacer()

                    // Date - matching reference: text-xs text-muted-foreground
                    Text("\(strings.readingTime): \(history.displayDateString)")
                        .font(.appSerif(size: 12, weight: .regular))
                        .foregroundColor(.mutedText)
                }

                // Status badge
                HStack {
                    Spacer()
                    statusBadge
                }

                // Birth info section
                if history.isSynastry, let synInfo = history.getSynastryInfo() {
                    synastryInfoSection(synInfo: synInfo)
                } else {
                    personalInfoSection
                }

                // Error message and retry button for failed tasks
                if history.status == .failed {
                    if let errorMsg = history.errorMessage {
                        Text(errorMsg)
                            .font(.appSerif(size: 12))
                            .foregroundColor(.orange.opacity(0.8))
                            .lineLimit(2)
                    }

                    if !history.isInvalidData {
                        HStack {
                            Spacer()
                            Button(action: onRetry) {
                                HStack(spacing: 4) {
                                    if isRetrying {
                                        ProgressView()
                                            .scaleEffect(0.6)
                                            .progressViewStyle(CircularProgressViewStyle(tint: .flowingGold))
                                    } else {
                                        Image(systemName: "arrow.clockwise")
                                            .font(.appSerif(size: 12))
                                        Text(strings.retry)
                                            .font(.appSerif(size: 12))
                                    }
                                }
                                .foregroundColor(.flowingGold)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.flowingGold.opacity(0.1))
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(isRetrying)
                        }
                    }
                }
            }
            .padding(16)
            .background(Color.cardBackgroundSolid.opacity(0.9))
            .cornerRadius(Theme.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                    .stroke(
                        history.status == .failed ? Color.orange.opacity(0.3) : Color.white.opacity(0.1),
                        lineWidth: 1
                    )
            )
            .opacity(history.status == .analyzing ? 0.7 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(delay)) {
                isVisible = true
            }
        }
    }

    // MARK: - Personal Info Section
    private var personalInfoSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text(history.birthInfo.gender == .male ? strings.maleShort : strings.femaleShort)
                    .font(.appSerif(size: 14, weight: .regular))
                    .foregroundColor(.mutedText)
                Spacer()
                Text(history.birthInfo.displayDateString)
                    .font(.appSerif(size: 14, weight: .medium))
                    .foregroundColor(.foregroundText)
            }
            HStack {
                Text(strings.shichen)
                    .font(.appSerif(size: 14, weight: .regular))
                    .foregroundColor(.mutedText)
                Spacer()
                Text(history.birthInfo.localizedBirthTime)
                    .font(.appSerif(size: 14, weight: .medium))
                    .foregroundColor(.flowingGold)
            }
            if !history.birthInfo.location.isEmpty {
                HStack {
                    Text(strings.location)
                        .font(.appSerif(size: 14, weight: .regular))
                        .foregroundColor(.mutedText)
                    Spacer()
                    Text(history.birthInfo.location)
                        .font(.appSerif(size: 14, weight: .regular))
                        .foregroundColor(.foregroundText)
                }
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.03))
        .cornerRadius(12)
    }

    // MARK: - Synastry Info Section
    private func synastryInfoSection(synInfo: SynastryInfo) -> some View {
        HStack(spacing: 10) {
            // Person A
            VStack(alignment: .leading, spacing: 4) {
                Text(strings.synastryPersonA)
                    .font(.appSerif(size: 12, weight: .semibold))
                    .foregroundColor(.flowingGold)
                Text(synInfo.personA.displayDateString)
                    .font(.appSerif(size: 13, weight: .medium))
                    .foregroundColor(.foregroundText)
                Text(synInfo.personA.localizedBirthTime)
                    .font(.appSerif(size: 12, weight: .regular))
                    .foregroundColor(.mutedText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Divider
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 1, height: 40)

            // Person B
            VStack(alignment: .leading, spacing: 4) {
                Text(strings.synastryPersonB)
                    .font(.appSerif(size: 12, weight: .semibold))
                    .foregroundColor(.flowingGold)
                Text(synInfo.personB.displayDateString)
                    .font(.appSerif(size: 13, weight: .medium))
                    .foregroundColor(.foregroundText)
                Text(synInfo.personB.localizedBirthTime)
                    .font(.appSerif(size: 12, weight: .regular))
                    .foregroundColor(.mutedText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(Color.white.opacity(0.03))
        .cornerRadius(12)
    }

    // Topic display title
    private var topicDisplayTitle: String {
        if history.isSynastry, let synInfo = history.getSynastryInfo() {
            return strings.synastryTitle(for: synInfo.synastryType)
        }
        return strings.categoryTitle(for: history.birthInfo.analysisTopic)
    }

    // MARK: - Status Badge
    @ViewBuilder
    private var statusBadge: some View {
        HStack(spacing: 4) {
            switch history.status {
            case .analyzing:
                ProgressView()
                    .scaleEffect(0.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .flowingGold))
                Text(strings.analyzing)
            case .completed, .synastry:
                Image(systemName: "checkmark.circle.fill")
                Text(strings.completed)
            case .failed:
                Image(systemName: "exclamationmark.circle.fill")
                Text(strings.failed)
            }
        }
        .font(.appSerif(size: 12))
        .foregroundColor(statusColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(statusColor.opacity(0.1))
        .cornerRadius(6)
    }

    private var statusColor: Color {
        switch history.status {
        case .analyzing: return .flowingGold
        case .completed, .synastry: return Color(hex: "22C55E") // green-500
        case .failed: return Color(hex: "EF4444") // red-500 / destructive
        }
    }
}

// MARK: - Preview
struct ReadingHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        let historyService = ReadingHistoryService()
        let taskManager = FortuneTaskManager(historyService: historyService)
        ReadingHistoryView(historyService: historyService, taskManager: taskManager)
    }
}
