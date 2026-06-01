import SwiftUI
import UserNotifications

struct ContentView: View {
    // Removed currentPage - no longer using bottom nav bar
    @State private var showingCategorySelection = false
    @State private var showingProfileSelection = false
    @State private var showingBirthInfoForm = false
    @State private var showingHistory = false
    @State private var showingSettings = false
    @State private var showingProfileManagement = false // 新增：档案管理页面
    @State private var selectedCategory: AnalysisTopic = .overall
    @State private var selectedProfile: BirthProfile?
    @State private var currentReading: FortuneReading?
    @State private var isLoading = false
    @State private var loadingStep = ""
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var currentTaskId: UUID?
    @State private var isFirstTimeUser = false // 新增：标记是否为新用户
    @State private var pendingShowBirthForm = false // 用于 ProfileSelection -> BirthForm 转换
    @State private var pendingShowProfileSelection = false // 用于 Category -> ProfileSelection 转换
    @State private var pendingShowBirthFormFromCategory = false // 用于 Category -> BirthForm 转换（新用户）
    @State private var pendingBirthInfoSubmit: BirthInfo? = nil // 用于选择档案后的提交

    // Synastry states
    @State private var showingSynastryFlow = false
    @State private var synastryResult: SynastryResultData?
    @State private var isSynastryLoading = false
    @State private var pendingSynastrySubmit: (type: SynastryType, personA: BirthInfo, personB: BirthInfo, role: RelationshipRole?)? = nil

    // 新增：用于显示正在加载的命盘视图
    @State private var loadingChartData: LoadingChartData?


    @StateObject private var historyService = ReadingHistoryService.shared
    @StateObject private var fortuneTaskManager: FortuneTaskManager
    @StateObject private var localizationManager = LocalizationManager.shared
    @ObservedObject private var profileService = BirthProfileService.shared

    @Environment(\.scenePhase) private var scenePhase

    private var strings: LocalizedStrings {
        localizationManager.strings
    }

    init() {
        let history = ReadingHistoryService.shared
        _historyService = StateObject(wrappedValue: history)
        let taskManager = FortuneTaskManager(historyService: history)
        _fortuneTaskManager = StateObject(wrappedValue: taskManager)
    }

    var body: some View {
        ZStack {
            StarFieldBackground()

            // Show language selection for first-time users
            if !localizationManager.hasSelectedLanguage {
                LanguageSelectionView(
                    localizationManager: localizationManager,
                    onLanguageSelected: {
                        // Language is already saved in the view
                    }
                )
            } else {
                // Home page is always the base - clean, focused experience
                homePageContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            // Loading Overlay
            if isLoading {
                LoadingView(step: loadingStep, strings: strings)
            }
        }
        .sheet(isPresented: $showingCategorySelection, onDismiss: {
            // 分类选择完成后，根据是否有档案决定下一步
            if pendingShowProfileSelection {
                pendingShowProfileSelection = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    showingProfileSelection = true
                }
            } else if pendingShowBirthFormFromCategory {
                pendingShowBirthFormFromCategory = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    showingBirthInfoForm = true
                }
            } else if showingSynastryFlow {
                // Synastry was selected, will open synastry flow
            }
        }) {
            CategorySelectionView(
                onSelectCategory: { topic in
                    selectedCategory = topic

                    // 标记下一步操作，等 sheet dismiss 后再执行
                    if profileService.hasProfiles {
                        pendingShowProfileSelection = true
                    } else {
                        isFirstTimeUser = true
                        pendingShowBirthFormFromCategory = true
                    }

                    showingCategorySelection = false
                },
                onSelectSynastry: {
                    showingCategorySelection = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        showingSynastryFlow = true
                    }
                }
            )
        }
        .sheet(isPresented: $showingProfileSelection, onDismiss: {
            // Sheet 关闭后执行待处理操作
            if pendingShowBirthForm {
                pendingShowBirthForm = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    showingBirthInfoForm = true
                }
            } else if let birthInfo = pendingBirthInfoSubmit {
                pendingBirthInfoSubmit = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    handleBirthInfoSubmit(birthInfo)
                }
            }
        }) {
            ProfileSelectionView(
                selectedTopic: selectedCategory,
                onSelectProfile: { profile in
                    // 标记待提交的 BirthInfo，等 sheet dismiss 后再执行
                    pendingBirthInfoSubmit = profile.toBirthInfo(topic: selectedCategory)
                },
                onCreateNew: {
                    // 标记需要显示表单，等 sheet 关闭后再打开
                    selectedProfile = nil
                    isFirstTimeUser = false
                    pendingShowBirthForm = true
                }
            )
        }
        .sheet(isPresented: $showingBirthInfoForm) {
            BirthInfoForm(
                selectedTopic: selectedCategory,
                existingProfile: selectedProfile,
                isFirstTimeUser: isFirstTimeUser,
                onSubmit: { birthInfo in
                    isFirstTimeUser = false // 重置标记
                    handleBirthInfoSubmit(birthInfo)
                }
            )
        }
        .sheet(isPresented: $showingProfileManagement) {
            ProfileManagementView()
        }
        .sheet(isPresented: $showingHistory) {
            HistorySheetView(historyService: historyService, taskManager: fortuneTaskManager)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsSheetView(historyService: historyService)
        }
        .sheet(item: $currentReading) { reading in
            ReadingResultView(reading: reading)
        }
        .sheet(item: $loadingChartData) { data in
            ReadingResultViewWithLoading(
                taskId: data.id,
                birthInfo: data.birthInfo,
                chart: data.chart
            )
        }
        .sheet(isPresented: $showingSynastryFlow, onDismiss: {
            if let pending = pendingSynastrySubmit {
                pendingSynastrySubmit = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    handleSynastrySubmit(synastryType: pending.type, personA: pending.personA, personB: pending.personB, role: pending.role)
                }
            }
        }) {
            SynastryFlowView { type, personA, personB, role in
                pendingSynastrySubmit = (type: type, personA: personA, personB: personB, role: role)
                showingSynastryFlow = false
            }
        }
        .sheet(item: $synastryResult) { result in
            if let analysis = result.analysis {
                SynastryResultView(
                    synastryInfo: result.synastryInfo,
                    analysis: analysis
                )
            } else {
                SynastryResultView(
                    synastryInfo: result.synastryInfo
                )
            }
        }
        .alert(strings.error, isPresented: $showError) {
            Button(strings.confirm, role: .cancel) { }
        } message: {
            Text(errorMessage ?? strings.unknownError)
        }
        .onReceive(NotificationCenter.default.publisher(for: .fortuneChartReady)) { notification in
            guard let taskId = notification.userInfo?["taskId"] as? UUID,
                  taskId == currentTaskId,
                  let chart = notification.userInfo?["chart"] as? ZiWeiChart,
                  let birthInfo = notification.userInfo?["birthInfo"] as? BirthInfo else {
                return
            }

            DispatchQueue.main.async {
                self.isLoading = false
                self.loadingStep = ""
                self.loadingChartData = LoadingChartData(
                    id: taskId,
                    birthInfo: birthInfo,
                    chart: chart
                )
            }
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .background:
                BackgroundTaskManager.shared.handleAppWillEnterBackground()
            case .active:
                BackgroundTaskManager.shared.handleAppDidBecomeActive()
            case .inactive:
                break
            @unknown default:
                break
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .fortuneTaskCompleted)) { notification in
            guard let taskId = notification.userInfo?["taskId"] as? UUID,
                  taskId == currentTaskId,
                  let reading = notification.userInfo?["reading"] as? FortuneReading else {
                return
            }
            DispatchQueue.main.async {
                self.currentReading = reading
                self.isLoading = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .notificationTapped)) { notification in
            guard let _ = notification.userInfo?["taskId"] as? UUID,
                  let type = notification.userInfo?["type"] as? String else {
                return
            }
            switch type {
            case "task_completed", "task_failed":
                showingHistory = true
            default:
                break
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .postAnalysisGoToHistory)) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                showingHistory = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .postAnalysisTryAnother)) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                showingCategorySelection = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .postAnalysisStartReading)) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                showingCategorySelection = true
            }
        }
    }

    // MARK: - Home Page Content (3-Card Carousel Design)
    private var homePageContent: some View {
        HomeCarouselView(
            onStartReading: {
                showingCategorySelection = true
            },
            onGoToHistory: {
                showingHistory = true
            },
            onGoToSettings: {
                showingSettings = true
            }
        )
    }

    // MARK: - Birth Info Submit Handler
    private func handleBirthInfoSubmit(_ birthInfo: BirthInfo) {
        isLoading = true
        showingBirthInfoForm = false

        let taskId = fortuneTaskManager.startNewFortuneTask(birthInfo: birthInfo)
        loadingStep = strings.generatingChart
        self.currentTaskId = taskId

        // 命盘生成后会收到 fortuneChartReady 通知，届时自动跳转到命盘页面
        // 不再使用固定延时跳转到历史页面
    }

    // MARK: - Synastry Submit Handler
    private func handleSynastrySubmit(synastryType: SynastryType, personA: BirthInfo, personB: BirthInfo, role: RelationshipRole?) {
        isLoading = true
        loadingStep = strings.generatingChart

        Task {
            do {
                let chartService = ZiWeiChartService()

                // Generate both charts
                let chartA = try await chartService.generateChart(from: personA)
                let chartB = try await chartService.generateChart(from: personB)

                let synastryInfo = SynastryInfo(
                    personA: personA,
                    personB: personB,
                    synastryType: synastryType,
                    relationshipRole: role,
                    chartA: chartA,
                    chartB: chartB
                )

                // Charts ready — dismiss loading and show result view immediately
                // AI analysis will run inside SynastryResultView
                await MainActor.run {
                    isLoading = false
                    loadingStep = ""
                    synastryResult = SynastryResultData(
                        synastryInfo: synastryInfo,
                        analysis: nil
                    )
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    loadingStep = ""
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

// MARK: - History Sheet View (Wrapper with dismiss button)
struct HistorySheetView: View {
    @ObservedObject var historyService: ReadingHistoryService
    @ObservedObject var taskManager: FortuneTaskManager
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @Environment(\.dismiss) private var dismiss

    private var strings: LocalizedStrings {
        localizationManager.strings
    }

    var body: some View {
        NavigationView {
            ZStack {
                StarFieldBackground()
                ReadingHistoryView(historyService: historyService, taskManager: taskManager)
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
            }
        }
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Settings Sheet View (Wrapper with dismiss button)
struct SettingsSheetView: View {
    @ObservedObject var historyService: ReadingHistoryService
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingProfileManagement = false

    private var strings: LocalizedStrings {
        localizationManager.strings
    }

    var body: some View {
        NavigationView {
            ZStack {
                StarFieldBackground()
                SettingsView(historyService: historyService, onShowProfileManagement: {
                    showingProfileManagement = true
                })
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
            }
        }
        .sheet(isPresented: $showingProfileManagement) {
            ProfileManagementView()
        }
        .presentationDragIndicator(.visible)
    }
}


// MARK: - Shimmer Effect
struct ShimmerEffect: View {
    @State private var shimmerOffset: CGFloat = -1

    var body: some View {
        GeometryReader { geometry in
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color.white.opacity(0.15),
                    Color.clear
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: geometry.size.width * 0.4)
            .offset(x: shimmerOffset * geometry.size.width)
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 2)
                        .repeatForever(autoreverses: false)
                        .delay(1)
                ) {
                    shimmerOffset = 1.5
                }
            }
        }
        .clipped()
    }
}

// MARK: - Loading View
struct LoadingView: View {
    let step: String
    let strings: LocalizedStrings
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.3

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(Color.flowingGold.opacity(glowOpacity * 0.3))
                        .frame(width: 140, height: 140)
                        .blur(radius: 20)

                    Circle()
                        .fill(Color.cardBackgroundSolid)
                        .frame(width: 120, height: 120)

                    Circle()
                        .stroke(Color.flowingGold.opacity(0.3), lineWidth: 2)
                        .frame(width: 120, height: 120)

                    Image(systemName: "sparkles")
                        .font(.appSerif(size: 50))
                        .foregroundColor(.flowingGold)
                        .rotationEffect(.degrees(rotation))
                        .scaleEffect(scale)
                }

                VStack(spacing: 12) {
                    Text(step.isEmpty ? strings.preparing : step)
                        .font(.appSerif(size: 16, weight: .medium))
                        .foregroundColor(.foregroundText)
                        .multilineTextAlignment(.center)

                    VStack(spacing: 8) {
                        Text(strings.analysisWaitMessage)
                            .font(.appSerif(size: 14, weight: .regular))
                            .foregroundColor(.mutedText)

                        Text(strings.notificationHint)
                            .font(.appSerif(size: 13, weight: .regular))
                            .foregroundColor(.mutedText.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }

                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .flowingGold))
                        .scaleEffect(1.2)
                        .padding(.top, 8)
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                    .fill(Color.cardBackgroundSolid.opacity(0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                            .stroke(Color.flowingGold.opacity(0.2), lineWidth: 1)
                    )
            )
            .padding(40)
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                scale = 1.1
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowOpacity = 0.6
            }
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @ObservedObject var historyService: ReadingHistoryService
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @ObservedObject private var profileService = BirthProfileService.shared
    @AppStorage("selected_ai_provider") private var selectedProviderRaw = AIProvider.gemini.rawValue
    @State private var showClearConfirmation = false
    @State private var notificationsEnabled = false
    @State private var showNotificationAlert = false
    @State private var showLanguageSelector = false

    // Callback for showing profile management
    var onShowProfileManagement: (() -> Void)?

    // Animation states
    @State private var headerOffset: CGFloat = -20
    @State private var headerOpacity: Double = 0
    @State private var cardOpacity: Double = 0
    @State private var cardOffset: CGFloat = 20

    private var strings: LocalizedStrings {
        localizationManager.strings
    }

    var body: some View {
        ZStack {
            StarFieldBackground()

            ScrollView {
                VStack(spacing: 24) {
                    // Header with animation
                    HStack {
                        Text(strings.settingsTitle)
                            .font(.appSerif(size: 26, weight: .semibold))
                            .foregroundColor(.foregroundText)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .offset(y: headerOffset)
                    .opacity(headerOpacity)

                    // User Card
                    userCard
                        .opacity(cardOpacity)
                        .offset(y: cardOffset)

                    // Profile Management Section
                    profileManagementSection

                    // Settings Groups
                    VStack(alignment: .leading, spacing: 12) {
                        Text(strings.personalSettings)
                            .font(.appSerif(size: 14, weight: .medium))
                            .foregroundColor(.mutedText)
                            .padding(.horizontal, 24)

                        VStack(spacing: 0) {
                            notificationSettingRow()

                            // Divider
                            Rectangle()
                                .fill(Color.white.opacity(0.05))
                                .frame(height: 1)
                                .padding(.leading, 52)

                            languageSettingRow()
                        }
                        .background(Color.cardBackground)
                        .cornerRadius(Theme.cardCornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                    }

                    // AI Settings Group
                    aiSettingsGroup()

                    settingsGroup(title: strings.privacyAndSecurity, items: [
                        SettingItem(icon: "shield", label: strings.privacySettings, type: .link)
                    ], delay: 0.2)

                    settingsGroup(title: strings.about, items: [
                        SettingItem(icon: "questionmark.circle", label: strings.helpAndFeedback, type: .link),
                        SettingItem(icon: "info.circle", label: strings.aboutApp, type: .value("v1.0.0"))
                    ], delay: 0.3)

                    // Clear Data Button
                    clearDataButton

                    // Footer
                    VStack(spacing: 4) {
                        Text("\(strings.appTitle) v1.0.0")
                            .font(.appSerif(size: 12, weight: .regular))
                            .foregroundColor(.mutedText.opacity(0.5))
                        Text(strings.appFooter)
                            .font(.appSerif(size: 12, weight: .regular))
                            .foregroundColor(.mutedText.opacity(0.4))
                    }
                    .padding(.vertical, 32)
                }
                .padding(.bottom, 100)
            }
        }
        .alert(strings.confirmClear, isPresented: $showClearConfirmation) {
            Button(strings.cancel, role: .cancel) { }
            Button(strings.clear, role: .destructive) {
                historyService.deleteAllReadings()
            }
        } message: {
            Text(strings.clearAllDataMessage)
        }
        .alert(strings.notificationPermission, isPresented: $showNotificationAlert) {
            Button(strings.cancel, role: .cancel) {
                notificationsEnabled = false
            }
            Button(strings.goToSettings, role: .none) {
                openAppSettings()
            }
        } message: {
            Text(strings.notificationPermissionMessage)
        }
        .sheet(isPresented: $showLanguageSelector) {
            LanguageSelectorSheet(localizationManager: localizationManager)
        }
        .onAppear {
            checkNotificationStatus()
            withAnimation(.easeOut(duration: 0.5)) {
                headerOffset = 0
                headerOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                cardOpacity = 1
                cardOffset = 0
            }
        }
    }

    // MARK: - Notification Setting Row
    private func notificationSettingRow() -> some View {
        HStack(spacing: 12) {
            Image(systemName: "bell")
                .font(.appSerif(size: 20))
                .foregroundColor(.flowingGold)
                .frame(width: 24)

            Text(strings.notificationSettings)
                .font(.appSerif(size: 16, weight: .medium))
                .foregroundColor(.foregroundText)

            Spacer()

            Toggle("", isOn: $notificationsEnabled)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .flowingGold))
                .onChange(of: notificationsEnabled) { newValue in
                    handleNotificationToggle(newValue)
                }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }

    // MARK: - Language Setting Row
    private func languageSettingRow() -> some View {
        Button(action: { showLanguageSelector = true }) {
            HStack(spacing: 12) {
                Image(systemName: "globe")
                    .font(.appSerif(size: 20))
                    .foregroundColor(.flowingGold)
                    .frame(width: 24)

                Text(strings.languageSettings)
                    .font(.appSerif(size: 16, weight: .medium))
                    .foregroundColor(.foregroundText)

                Spacer()

                HStack(spacing: 8) {
                    Text(localizationManager.currentLanguage.nativeDisplayName)
                        .font(.appSerif(size: 14))
                        .foregroundColor(.mutedText)
                    Image(systemName: "chevron.right")
                        .font(.appSerif(size: 14))
                        .foregroundColor(.mutedText)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }

    // MARK: - Notification Helpers
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }

    private func handleNotificationToggle(_ enabled: Bool) {
        if enabled {
            // 请求通知权限
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                DispatchQueue.main.async {
                    if granted {
                        notificationsEnabled = true
                        #if DEBUG
                        print("通知权限已授予")
                        #endif
                    } else {
                        notificationsEnabled = false
                        showNotificationAlert = true
                        #if DEBUG
                        print("通知权限被拒绝")
                        #endif
                    }
                }
            }
        } else {
            // 用户关闭通知，引导去系统设置
            showNotificationAlert = true
        }
    }

    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    private var userCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.flowingGold.opacity(0.1))
                    .frame(width: 64, height: 64)

                Circle()
                    .stroke(Color.flowingGold.opacity(0.3), lineWidth: 1)
                    .frame(width: 64, height: 64)

                Text("命")
                    .font(.appSerif(size: 24, weight: .semibold))
                    .foregroundColor(.flowingGold)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(strings.guestUser)
                    .font(.appSerif(size: 18, weight: .semibold))
                    .foregroundColor(.foregroundText)

                Text(strings.readingCountText(historyService.readings.count))
                    .font(.appSerif(size: 14, weight: .regular))
                    .foregroundColor(.mutedText)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.appSerif(size: 16))
                .foregroundColor(.mutedText)
        }
        .padding(20)
        .background(Color.cardBackground)
        .cornerRadius(Theme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    // MARK: - Profile Management Section
    private var profileManagementSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(strings.manageProfiles)
                .font(.appSerif(size: 14, weight: .medium))
                .foregroundColor(.mutedText)
                .padding(.horizontal, 24)

            Button(action: {
                onShowProfileManagement?()
            }) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.flowingGold.opacity(0.1))
                            .frame(width: 44, height: 44)

                        Image(systemName: "person.2")
                            .font(.appSerif(size: 18))
                            .foregroundColor(.flowingGold)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(strings.manageProfiles)
                            .font(.appSerif(size: 16, weight: .medium))
                            .foregroundColor(.foregroundText)

                        Text(profileService.hasProfiles
                             ? "\(profileService.profiles.count)\(strings.profileCount)"
                             : strings.noProfilesYet)
                            .font(.appSerif(size: 13, weight: .regular))
                            .foregroundColor(.mutedText)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.appSerif(size: 14))
                        .foregroundColor(.mutedText)
                }
                .padding(16)
                .background(Color.cardBackground)
                .cornerRadius(Theme.cardCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            }
            .padding(.horizontal, 20)
        }
    }

    private func settingsGroup(title: String, items: [SettingItem], delay: Double) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.appSerif(size: 14, weight: .medium))
                .foregroundColor(.mutedText)
                .padding(.horizontal, 24)

            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.label) { index, item in
                    settingRow(item: item, showDivider: index < items.count - 1)
                }
            }
            .background(Color.cardBackground)
            .cornerRadius(Theme.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .padding(.horizontal, 20)
        }
    }

    private func aiSettingsGroup() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(strings.aiModelSettings)
                .font(.appSerif(size: 14, weight: .medium))
                .foregroundColor(.mutedText)
                .padding(.horizontal, 24)

            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Image(systemName: "cpu")
                        .font(.appSerif(size: 20))
                        .foregroundColor(.flowingGold)
                        .frame(width: 24)

                    Text(strings.selectModel)
                        .font(.appSerif(size: 16, weight: .medium))
                        .foregroundColor(.foregroundText)

                    Spacer()

                    Menu {
                        ForEach(AIProvider.allCases) { provider in
                            Button(action: {
                                selectedProviderRaw = provider.rawValue
                            }) {
                                HStack {
                                    Text(provider.displayName)
                                        .font(.appSerif(size: 16, weight: .medium))
                                    if selectedProviderRaw == provider.rawValue {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(AIProvider(rawValue: selectedProviderRaw)?.displayName ?? "")
                                .font(.appSerif(size: 16, weight: .medium))
                                .foregroundColor(.flowingGold)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.appSerif(size: 12))
                                .foregroundColor(.flowingGold)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)

                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.05))
                    .frame(height: 1)
                    .padding(.leading, 52)

                // API Key Config Hint
                HStack(spacing: 12) {
                    Image(systemName: "key")
                        .font(.appSerif(size: 20))
                        .foregroundColor(.flowingGold)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(strings.apiKeyConfig)
                            .font(.appSerif(size: 16, weight: .medium))
                            .foregroundColor(.foregroundText)

                        Text(apiKeyStatusText)
                            .font(.appSerif(size: 12, weight: .regular))
                            .foregroundColor(.mutedText)
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .background(Color.cardBackground)
            .cornerRadius(Theme.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .padding(.horizontal, 20)
        }
    }

    private var apiKeyStatusText: String {
        let configuredText = strings.configured
        let notConfiguredText = strings.notConfigured

        switch AIProvider(rawValue: selectedProviderRaw) {
        case .deepSeek:
            return BackendConfig.deepSeekAPIKey.isEmpty ? notConfiguredText : configuredText
        case .gemini:
            return BackendConfig.geminiAPIKey.isEmpty || BackendConfig.geminiAPIKey == "YOUR_GEMINI_API_KEY_HERE" ? notConfiguredText : configuredText
        case .openAI:
            return BackendConfig.openAIAPIKey.isEmpty || BackendConfig.openAIAPIKey == "YOUR_OPENAI_API_KEY_HERE" ? notConfiguredText : configuredText
        case .none:
            return strings.unknownError
        }
    }

    private func settingRow(item: SettingItem, showDivider: Bool) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: item.icon)
                    .font(.appSerif(size: 20))
                    .foregroundColor(.flowingGold)
                    .frame(width: 24)

                Text(item.label)
                    .font(.appSerif(size: 16, weight: .medium))
                    .foregroundColor(.foregroundText)

                Spacer()

                switch item.type {
                case .link:
                    Image(systemName: "chevron.right")
                        .font(.appSerif(size: 14))
                        .foregroundColor(.mutedText)
                case .toggle(let isOn):
                    Toggle("", isOn: .constant(isOn))
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: .flowingGold))
                case .value(let text):
                    HStack(spacing: 8) {
                        Text(text)
                            .font(.appSerif(size: 14))
                            .foregroundColor(.mutedText)
                        Image(systemName: "chevron.right")
                            .font(.appSerif(size: 14))
                            .foregroundColor(.mutedText)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)

            if showDivider {
                Rectangle()
                    .fill(Color.white.opacity(0.05))
                    .frame(height: 1)
                    .padding(.leading, 52)
            }
        }
    }

    private var clearDataButton: some View {
        Button(action: { showClearConfirmation = true }) {
            HStack(spacing: 8) {
                Image(systemName: "trash")
                    .font(.appSerif(size: 16))
                Text(strings.clearAllData)
                    .font(.appSerif(size: 16, weight: .medium))
            }
            .foregroundColor(.destructiveRed)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Color.clear)
            .cornerRadius(Theme.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                    .stroke(Color.destructiveRed.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

// MARK: - Language Selector Sheet
struct LanguageSelectorSheet: View {
    @ObservedObject var localizationManager: LocalizationManager
    @Environment(\.dismiss) private var dismiss

    private var strings: LocalizedStrings {
        localizationManager.strings
    }

    var body: some View {
        NavigationView {
            ZStack {
                StarFieldBackground()

                VStack(spacing: 16) {
                    ForEach(AppLanguage.allCases, id: \.self) { language in
                        LanguageOptionButton(
                            language: language,
                            isSelected: localizationManager.currentLanguage == language
                        ) {
                            localizationManager.setLanguage(language)
                            dismiss()
                        }
                    }

                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle(strings.selectLanguage)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(strings.done) {
                        dismiss()
                    }
                    .font(.appSerif(size: 16, weight: .medium))
                    .foregroundColor(.flowingGold)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

struct SettingItem {
    let icon: String
    let label: String
    let type: SettingType

    enum SettingType {
        case link
        case toggle(Bool)
        case value(String)
    }
}

// MARK: - Synastry Result Data (for sheet binding)
struct SynastryResultData: Identifiable {
    let id = UUID()
    let synastryInfo: SynastryInfo
    let analysis: String?
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
