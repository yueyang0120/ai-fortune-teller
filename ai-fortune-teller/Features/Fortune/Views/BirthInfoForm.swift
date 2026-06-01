import SwiftUI

struct BirthInfoForm: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @ObservedObject private var profileService = BirthProfileService.shared

    @State private var selectedHour = 12
    @State private var selectedMinute = 0
    @State private var selectedGender: Gender = .male
    @State private var calendarType: CalendarType = .solar
    @State private var location = ""
    @State private var longitude: Double = 0.0
    @State private var latitude: Double = 0.0
    @State private var useRealSolarTime = true // Default to true for more accurate time calculation
    @State private var showingLocationPicker = false

    // Profile saving - 简化后的逻辑
    @State private var saveAsProfile = true
    @State private var profileName = ""
    @State private var showingSaveProfileSheet = false

    // Time Selection Mode (User requested: Exact Time default on left)
    enum TimeInputMode {
        case exact
        case shichen
    }
    @State private var timeInputMode: TimeInputMode = .exact

    // Solar Date Inputs (wheel picker)
    @State private var solarYear = Calendar.current.component(.year, from: Date())
    @State private var solarMonth = Calendar.current.component(.month, from: Date())
    @State private var solarDay = Calendar.current.component(.day, from: Date())

    // Lunar Date Inputs
    @State private var lunarYear = Calendar.current.component(.year, from: Date())
    @State private var lunarMonth = 1
    @State private var lunarDay = 1
    @State private var isLeapMonth = false

    // Selected topic from category selection
    let selectedTopic: AnalysisTopic
    let onSubmit: (BirthInfo) -> Void

    // Optional: pre-fill from existing profile (for editing)
    let existingProfile: BirthProfile?

    // 新增：是否为新用户（首次创建档案）
    let isFirstTimeUser: Bool

    private var strings: LocalizedStrings {
        localizationManager.strings
    }

    // 计算是否应该显示保存选项
    // - 新用户/老用户添加新档案：都显示选项，让用户选择是否保存
    // - 编辑现有档案：不显示，已经是档案了
    private var shouldShowSaveOption: Bool {
        existingProfile == nil
    }

    init(selectedTopic: AnalysisTopic = .overall, existingProfile: BirthProfile? = nil, isFirstTimeUser: Bool = false, onSubmit: @escaping (BirthInfo) -> Void) {
        self.selectedTopic = selectedTopic
        self.existingProfile = existingProfile
        self.isFirstTimeUser = isFirstTimeUser
        self.onSubmit = onSubmit
    }

    var body: some View {
        ZStack {
            StarFieldBackground()

            VStack(spacing: 0) {
                // Header with opaque background
                HStack(spacing: 16) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.appSerif(size: 20))
                            .foregroundColor(.mutedText)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        // 新用户显示欢迎文案，老用户显示分类标题
                        if isFirstTimeUser {
                            Text(strings.createFirstProfile)
                                .font(.appSerif(size: 22, weight: .semibold))
                                .foregroundColor(.foregroundText)
                            Text(strings.createFirstProfileHint)
                                .font(.appSerif(size: 14, weight: .regular))
                                .foregroundColor(.mutedText)
                        } else {
                            Text(strings.categoryTitle(for: selectedTopic))
                                .font(.appSerif(size: 22, weight: .semibold))
                                .foregroundColor(.foregroundText)
                            Text(strings.fillBirthInfo)
                                .font(.appSerif(size: 14, weight: .regular))
                                .foregroundColor(.mutedText)
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .background(Color.cardBackgroundSolid.opacity(0.95))

                ScrollView {
                    VStack(spacing: 24) {
                        // Gender Selection
                        GlassCard {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 12) {
                                    Image(systemName: "person")
                                        .foregroundColor(.flowingGold)
                                    Text(strings.gender)
                                        .font(.appSerif(size: 17, weight: .medium))
                                        .foregroundColor(.foregroundText)
                                    Spacer()
                                    stepBadge(1)
                                }

                                HStack(spacing: 12) {
                                    genderButton(title: strings.male, value: .male)
                                    genderButton(title: strings.female, value: .female)
                                }
                            }
                        }

                        // Date Selection
                        GlassCard {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 12) {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.flowingGold)
                                    Text(strings.birthDate)
                                        .font(.appSerif(size: 17, weight: .medium))
                                        .foregroundColor(.foregroundText)
                                    Spacer()
                                    stepBadge(2)
                                }

                                // Calendar Type Picker
                                HStack(spacing: 12) {
                                    calendarTypeButton(title: strings.solarCalendar, type: .solar)
                                    calendarTypeButton(title: strings.lunarCalendar, type: .lunar)
                                }

                                if calendarType == .solar {
                                    // Solar Date Wheel Picker - consistent with lunar picker
                                    HStack(spacing: 0) {
                                        Picker(strings.year, selection: $solarYear) {
                                            ForEach(1900...currentYear, id: \.self) { year in
                                                Text("\(String(format: "%d", year))\(strings.year)")
                                                    .font(.appSerif(size: 18))
                                                    .tag(year)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(maxWidth: .infinity)
                                        .clipped()

                                        Picker(strings.month, selection: $solarMonth) {
                                            ForEach(1...12, id: \.self) { month in
                                                Text("\(month)\(strings.month)")
                                                    .font(.appSerif(size: 18))
                                                    .tag(month)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(maxWidth: .infinity)
                                        .clipped()

                                        Picker(strings.day, selection: $solarDay) {
                                            ForEach(1...daysInSolarMonth, id: \.self) { day in
                                                Text("\(day)\(strings.day)")
                                                    .font(.appSerif(size: 18))
                                                    .tag(day)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(maxWidth: .infinity)
                                        .clipped()
                                    }
                                    .frame(height: 150)
                                    .colorScheme(.dark)
                                    .onChange(of: solarYear) { _ in
                                        validateSolarDay()
                                    }
                                    .onChange(of: solarMonth) { _ in
                                        validateSolarDay()
                                    }
                                } else {
                                    // Lunar Picker
                                    HStack(spacing: 0) {
                                        Picker(strings.year, selection: $lunarYear) {
                                            ForEach(1900...2100, id: \.self) { year in
                                                Text("\(String(format: "%d", year))\(strings.year)")
                                                    .font(.appSerif(size: 18))
                                                    .tag(year)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(maxWidth: .infinity)
                                        .clipped()

                                        Picker(strings.month, selection: $lunarMonth) {
                                            ForEach(1...12, id: \.self) { month in
                                                Text("\(month)\(strings.month)")
                                                    .font(.appSerif(size: 18))
                                                    .tag(month)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(maxWidth: .infinity)
                                        .clipped()

                                        Picker(strings.day, selection: $lunarDay) {
                                            ForEach(1...30, id: \.self) { day in
                                                Text("\(day)\(strings.day)")
                                                    .font(.appSerif(size: 18))
                                                    .tag(day)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(maxWidth: .infinity)
                                        .clipped()
                                    }
                                    .frame(height: 150)
                                    .colorScheme(.dark)

                                    Toggle(strings.leapMonth, isOn: $isLeapMonth)
                                        .toggleStyle(SwitchToggleStyle(tint: .flowingGold))
                                        .foregroundColor(.foregroundText)
                                }
                            }
                        }

                        // Time Selection
                        GlassCard {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 12) {
                                    Image(systemName: "clock")
                                        .foregroundColor(.flowingGold)
                                    Text(strings.birthTime)
                                        .font(.appSerif(size: 17, weight: .medium))
                                        .foregroundColor(.foregroundText)
                                    Spacer()
                                    stepBadge(3)
                                }

                                // Custom Tab for Time Mode
                                HStack(spacing: 0) {
                                    timeModeButton(title: strings.exactTime, mode: .exact)
                                    timeModeButton(title: strings.shichenTime, mode: .shichen)
                                }
                                .background(Color.black.opacity(0.2))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )

                                if timeInputMode == .exact {
                                    HStack {
                                        Picker(strings.hour, selection: $selectedHour) {
                                            ForEach(0..<24, id: \.self) { hour in
                                                Text("\(hour)\(strings.hour)")
                                                    .font(.appSerif(size: 18))
                                                    .tag(hour)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(maxWidth: .infinity)
                                        .clipped()

                                        Picker(strings.minute, selection: $selectedMinute) {
                                            ForEach(0..<60, id: \.self) { minute in
                                                Text("\(minute)\(strings.minute)")
                                                    .font(.appSerif(size: 18))
                                                    .tag(minute)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(maxWidth: .infinity)
                                        .clipped()
                                    }
                                    .frame(height: 120)
                                    .colorScheme(.dark)
                                } else {
                                    Picker(strings.shichen, selection: $selectedHour) {
                                        ForEach(0..<24, id: \.self) { hour in
                                            let chineseHour = BirthInfo.getLocalizedChineseHour(from: hour)
                                            Text("\(chineseHour) (\(String(format: "%02d", hour)):00)")
                                                .font(.appSerif(size: 18))
                                                .tag(hour)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .frame(height: 120)
                                    .colorScheme(.dark)
                                }

                                Text(strings.timeHint)
                                    .font(.appSerif(size: 12))
                                    .foregroundColor(.mutedText)
                            }
                        }

                        // Location Selection
                        GlassCard {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 12) {
                                    Image(systemName: "mappin.and.ellipse")
                                        .foregroundColor(.flowingGold)
                                    Text(strings.birthPlace)
                                        .font(.appSerif(size: 17, weight: .medium))
                                        .foregroundColor(.foregroundText)
                                    Spacer()
                                    stepBadge(4)
                                }

                                Button(action: { showingLocationPicker = true }) {
                                    HStack {
                                        Text(location.isEmpty ? strings.selectLocation : location)
                                            .font(.appSerif(size: 16, weight: .medium))
                                            .foregroundColor(location.isEmpty ? .mutedText : .foregroundText)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.mutedText)
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                                }

                                Text(strings.locationHint)
                                    .font(.appSerif(size: 12))
                                    .foregroundColor(.mutedText)
                            }
                        }

                        // True Solar Time
                        GlassCard {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(strings.enableTrueSolarTime)
                                            .font(.appSerif(size: 17, weight: .medium))
                                            .foregroundColor(.foregroundText)
                                        Text(strings.trueSolarTimeHint)
                                            .font(.appSerif(size: 12, weight: .regular))
                                            .foregroundColor(.mutedText)
                                    }
                                    Spacer()
                                    stepBadge(5)
                                    Toggle("", isOn: $useRealSolarTime)
                                        .labelsHidden()
                                        .toggleStyle(SwitchToggleStyle(tint: .flowingGold))
                                }

                                if useRealSolarTime && !location.isEmpty {
                                    Divider().background(Color.white.opacity(0.1))
                                    Text(correctionExplanation)
                                        .font(.appSerif(size: 13))
                                        .foregroundColor(.flowingGold)
                                        .padding(.top, 4)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }

                        // 保存档案选项（新用户和老用户都显示，允许选择 Guest Mode）
                        if shouldShowSaveOption {
                            GlassCard {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(strings.saveAsProfile)
                                                .font(.appSerif(size: 17, weight: .medium))
                                                .foregroundColor(.foregroundText)
                                            Text(saveAsProfile ? strings.saveAsProfileHint : strings.oneTimeReadingHint)
                                                .font(.appSerif(size: 12, weight: .regular))
                                                .foregroundColor(.mutedText)
                                        }
                                        Spacer()
                                        stepBadge(6)
                                        Toggle("", isOn: $saveAsProfile)
                                            .labelsHidden()
                                            .toggleStyle(SwitchToggleStyle(tint: .flowingGold))
                                    }

                                    if saveAsProfile {
                                        Divider().background(Color.white.opacity(0.1))

                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(strings.profileName)
                                                .font(.appSerif(size: 14, weight: .medium))
                                                .foregroundColor(.mutedText)

                                            TextField(strings.profileNamePlaceholder, text: $profileName)
                                                .font(.appSerif(size: 16))
                                                .foregroundColor(.foregroundText)
                                                .padding()
                                                .background(Color.white.opacity(0.05))
                                                .cornerRadius(12)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                                )
                                        }
                                    }
                                }
                            }
                        }

                        // Submit Button
                        VStack(spacing: 8) {
                            Button(action: submitForm) {
                                HStack(spacing: 8) {
                                    Image(systemName: "sparkles")
                                    Text(strings.startReading)
                                }
                            }
                            .buttonStyle(GoldButtonStyle())
                            .disabled(location.isEmpty)
                            .opacity(location.isEmpty ? 0.5 : 1.0)

                            if location.isEmpty {
                                Text(strings.locationRequired)
                                    .font(.appSerif(size: 12))
                                    .foregroundColor(.red.opacity(0.8))
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingLocationPicker) {
            LocationPickerView(
                selectedLocation: $location,
                longitude: $longitude,
                latitude: $latitude
            )
        }
        .onAppear {
            prefillFromProfile()
        }
    }

    // MARK: - Profile Pre-fill

    private func prefillFromProfile() {
        guard let profile = existingProfile else { return }

        // Pre-fill from existing profile
        selectedGender = profile.gender
        calendarType = profile.calendarType

        // Solar date
        solarYear = profile.solarYear
        solarMonth = profile.solarMonth
        solarDay = profile.solarDay

        // Lunar date (if available)
        if let lunar = profile.lunarDate {
            lunarYear = lunar.year
            lunarMonth = lunar.month
            lunarDay = lunar.day
            isLeapMonth = lunar.isLeapMonth
        }

        // Time
        selectedHour = profile.birthHour
        selectedMinute = profile.birthMinute

        // Location
        location = profile.location
        longitude = profile.longitude
        latitude = profile.latitude

        // Settings
        useRealSolarTime = profile.useRealSolarTime

        // Profile name
        profileName = profile.name

        #if DEBUG
        print("Pre-filled form from profile: \(profile.name)")
        #endif
    }

    // Helper Views

    private func stepBadge(_ step: Int) -> some View {
        Text("\(step)")
            .font(.appSerif(size: 11, weight: .bold))
            .foregroundColor(.deepSpaceStart)
            .frame(width: 22, height: 22)
            .background(Color.flowingGold.opacity(0.8))
            .clipShape(Circle())
    }

    private func genderButton(title: String, value: Gender) -> some View {
        Button(action: { selectedGender = value }) {
            Text(title)
                .font(.appSerif(size: 15, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(selectedGender == value ? Color.flowingGold.opacity(0.1) : Color.white.opacity(0.05))
                .foregroundColor(selectedGender == value ? .flowingGold : .mutedText)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(selectedGender == value ? Color.flowingGold : Color.white.opacity(0.1), lineWidth: 1)
                )
                .cornerRadius(12)
        }
    }

    private func calendarTypeButton(title: String, type: CalendarType) -> some View {
        Button(action: { calendarType = type }) {
            Text(title)
                .font(.appSerif(size: 15, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(calendarType == type ? Color.flowingGold.opacity(0.1) : Color.white.opacity(0.05))
                .foregroundColor(calendarType == type ? .flowingGold : .mutedText)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(calendarType == type ? Color.flowingGold : Color.white.opacity(0.1), lineWidth: 1)
                )
                .cornerRadius(12)
        }
    }

    private func timeModeButton(title: String, mode: TimeInputMode) -> some View {
        Button(action: { timeInputMode = mode }) {
            Text(title)
                .font(.appSerif(size: 15, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(timeInputMode == mode ? Color.flowingGold : Color.clear)
                .foregroundColor(timeInputMode == mode ? .deepSpaceStart : .mutedText)
                .cornerRadius(12)
        }
    }

    // MARK: - Solar Date Helpers

    private var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }

    private var daysInSolarMonth: Int {
        var components = DateComponents()
        components.year = solarYear
        components.month = solarMonth

        let calendar = Calendar.current
        guard let date = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: date) else {
            return 31
        }
        return range.count
    }

    private func validateSolarDay() {
        let maxDays = daysInSolarMonth
        if solarDay > maxDays {
            solarDay = maxDays
        }
    }

    private var correctionExplanation: String {
        guard useRealSolarTime, !location.isEmpty else { return "" }

        var calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = solarYear
        dateComponents.month = solarMonth
        dateComponents.day = solarDay

        guard let date = calendar.date(from: dateComponents) else { return "" }

        if calendarType == .lunar {
             return strings.trueSolarTimeWillBeCalculated
        }

        return SolarTimeCalculator.getCorrectionExplanation(
            date: date,
            hour: selectedHour,
            minute: selectedMinute,
            longitude: longitude,
            locationName: location
        )
    }

    // Logic (Preserved)

    private func submitForm() {
        let lunarDateInfo: LunarDate?
        let finalSolarDate: Date

        var calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = solarYear
        dateComponents.month = solarMonth
        dateComponents.day = solarDay
        dateComponents.hour = selectedHour
        dateComponents.minute = selectedMinute
        dateComponents.second = 0

        guard let combinedDate = calendar.date(from: dateComponents) else {
            return
        }

        if calendarType == .lunar {
            lunarDateInfo = LunarDate(
                year: lunarYear,
                month: lunarMonth,
                day: lunarDay,
                isLeapMonth: isLeapMonth
            )

            // Use ZiWeiChartService to convert Lunar to Solar
            // Note: Instantiating service here to access JS context for conversion
            let chartService = ZiWeiChartService()
            if let convertedDate = chartService.convertLunarToSolar(
                lunarYear: lunarYear,
                lunarMonth: lunarMonth,
                lunarDay: lunarDay,
                isLeapMonth: isLeapMonth
            ) {
                // Combine converted date with selected time
                let tempCalendar = Calendar.current
                var convertedComponents = tempCalendar.dateComponents([.year, .month, .day], from: convertedDate)
                convertedComponents.hour = selectedHour
                convertedComponents.minute = selectedMinute
                convertedComponents.second = 0

                if let newDate = tempCalendar.date(from: convertedComponents) {
                    finalSolarDate = newDate
                } else {
                    finalSolarDate = convertedDate
                }
                print("✅ Lunar Date Converted: \(lunarYear)-\(lunarMonth)-\(lunarDay) -> \(finalSolarDate)")
            } else {
                print("⚠️ Lunar Conversion Failed: Using raw date as fallback")
                finalSolarDate = combinedDate
            }
        } else {
            lunarDateInfo = nil
            finalSolarDate = combinedDate
        }

        let birthInfo = BirthInfo(
            solarDate: finalSolarDate,
            lunarDate: lunarDateInfo,
            birthTime: BirthInfo.getChineseHour(from: selectedHour),
            birthHour: selectedHour,
            birthMinute: selectedMinute,
            location: location,
            longitude: longitude,
            latitude: latitude,
            gender: selectedGender,
            calendarType: calendarType,
            useRealSolarTime: useRealSolarTime,
            analysisTopic: selectedTopic
        )

        // 保存档案逻辑：
        // - 新用户/老用户：根据用户选择（saveAsProfile 开关）
        // - 编辑现有档案：不创建新档案（由 ProfileEditView 处理）
        if existingProfile == nil && saveAsProfile {
            let name = profileName.trimmingCharacters(in: .whitespaces)
            let finalName = name.isEmpty ? strings.defaultProfileName : name
            _ = profileService.createProfile(from: birthInfo, name: finalName)
            print("✅ Saved new profile: \(finalName)")
        } else if existingProfile == nil && !saveAsProfile {
            print("👤 Guest mode: profile not saved")
        }

        onSubmit(birthInfo)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Location Components

struct LocationPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var localizationManager = LocalizationManager.shared

    @Binding var selectedLocation: String
    @Binding var longitude: Double
    @Binding var latitude: Double

    @State private var searchText = ""
    @State private var showingManualInput = false
    @State private var manualLongitude: String = ""
    @State private var manualLatitude: String = ""
    @State private var manualLocationName: String = ""

    enum LocationInputMode {
        case commonCities
        case provinceCity
        case manual
    }

    @State private var inputMode: LocationInputMode = .provinceCity

    private var strings: LocalizedStrings {
        localizationManager.strings
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text(strings.selectInputMethod).font(.appSerif(size: 13))) {
                    Picker(strings.selectInputMethod, selection: $inputMode) {
                        Text(strings.provinceCitySelection).font(.appSerif(size: 14)).tag(LocationInputMode.provinceCity)
                        Text(strings.commonCities).font(.appSerif(size: 14)).tag(LocationInputMode.commonCities)
                        Text(strings.manualInput).font(.appSerif(size: 14)).tag(LocationInputMode.manual)
                    }
                    .pickerStyle(.segmented)
                }

                if inputMode == .provinceCity {
                    provinceCitySection
                } else if inputMode == .commonCities {
                    commonCitiesSection
                } else {
                    manualInputSection
                }
            }
            .navigationTitle(strings.selectLocation)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(strings.done) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.appSerif(size: 16, weight: .medium))
                }
            }
        }
    }

    private var commonCitiesSection: some View {
        Group {
            Section {
                TextField(strings.searchCity, text: $searchText)
                    .font(.appSerif(size: 16))
                    .textFieldStyle(.roundedBorder)
            }

            if !searchText.isEmpty {
                // Search results from all cities
                Section(header: Text(strings.searchResults).font(.appSerif(size: 13))) {
                    let allCityResults = searchAllCities(searchText)
                    if allCityResults.isEmpty {
                        Text(strings.noCityFound)
                            .font(.appSerif(size: 15))
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(allCityResults.prefix(20), id: \.fullName) { city in
                            Button(action: {
                                selectSearchedCity(city)
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(city.name)
                                            .font(.appSerif(size: 16, weight: .medium))
                                            .foregroundColor(.primary)
                                        Text(city.province)
                                            .font(.appSerif(size: 12, weight: .regular))
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    if city.fullName == selectedLocation {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                // Common cities when not searching
                Section(header: Text(strings.commonCities).font(.appSerif(size: 13))) {
                    ForEach(commonCities, id: \.name) { city in
                        Button(action: {
                            selectCommonCity(city)
                        }) {
                            HStack {
                                Text(city.name)
                                    .font(.appSerif(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                                Spacer()
                                if city.name == selectedLocation {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var provinceCitySection: some View {
        Group {
            Section {
                TextField(strings.searchCity, text: $searchText)
                    .font(.appSerif(size: 16))
                    .textFieldStyle(.roundedBorder)
            }

            if !searchText.isEmpty {
                // Search results from all cities
                Section(header: Text(strings.searchResults).font(.appSerif(size: 13))) {
                    let allCityResults = searchAllCities(searchText)
                    if allCityResults.isEmpty {
                        Text(strings.noCityFound)
                            .font(.appSerif(size: 15))
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(allCityResults.prefix(20), id: \.fullName) { city in
                            Button(action: {
                                selectSearchedCity(city)
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(city.name)
                                            .font(.appSerif(size: 16, weight: .medium))
                                            .foregroundColor(.primary)
                                        Text(city.province)
                                            .font(.appSerif(size: 12, weight: .regular))
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    if city.fullName == selectedLocation {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                Section(header: Text(strings.selectProvince).font(.appSerif(size: 13))) {
                    if !selectedLocation.isEmpty {
                        HStack {
                            Text(strings.currentLocation)
                                .font(.appSerif(size: 15))
                            Spacer()
                            Text(selectedLocation)
                                .font(.appSerif(size: 15))
                                .foregroundColor(.secondary)
                        }
                    }

                    ForEach(ChinaCityData.getRegions(language: localizationManager.currentLanguage), id: \.self) { region in
                        let dataKey = ChinaCityData.getDataKey(for: region, language: localizationManager.currentLanguage)
                        if dataKey == "中国大陆" {
                            NavigationLink(destination: MainlandProvinceListView(
                                selectedLocation: $selectedLocation,
                                longitude: $longitude,
                                latitude: $latitude,
                                dismiss: {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            )) {
                                Text(region)
                                    .font(.appSerif(size: 16, weight: .medium))
                            }
                        } else {
                            NavigationLink(destination: CityListView(
                                province: dataKey,
                                selectedLocation: $selectedLocation,
                                longitude: $longitude,
                                latitude: $latitude,
                                dismiss: {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            )) {
                                Text(region)
                                    .font(.appSerif(size: 16, weight: .medium))
                            }
                        }
                    }
                }
            }
        }
    }

    private var manualInputSection: some View {
        Group {
            Section(header: Text(strings.manualCoordinates).font(.appSerif(size: 13))) {
                TextField(strings.locationName, text: $manualLocationName)
                    .font(.appSerif(size: 16))
                    .textFieldStyle(.roundedBorder)

                HStack {
                    Text(strings.longitude)
                        .font(.appSerif(size: 15))
                    TextField("116.4074", text: $manualLongitude)
                        .font(.appSerif(size: 16))
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                }

                HStack {
                    Text(strings.latitude)
                        .font(.appSerif(size: 15))
                    TextField("39.9042", text: $manualLatitude)
                        .font(.appSerif(size: 16))
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                }

                Button(action: {
                    applyManualInput()
                }) {
                    HStack {
                        Spacer()
                        Text(strings.applyCoordinates)
                            .font(.appSerif(size: 16, weight: .semibold))
                        Spacer()
                    }
                }
                .disabled(manualLongitude.isEmpty || manualLatitude.isEmpty)
            }

            Section(header: Text(strings.about).font(.appSerif(size: 13))) {
                Text(strings.coordinatesHint)
                    .font(.appSerif(size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }

    let commonCities: [(name: String, lon: Double, lat: Double)] = [
        // 大陸主要城市
        ("北京市", 116.4074, 39.9042),
        ("上海市", 121.4737, 31.2304),
        ("广州市", 113.2644, 23.1291),
        ("深圳市", 114.0579, 22.5431),
        ("杭州市", 120.1551, 30.2741),
        ("成都市", 104.0665, 30.5723),
        ("重庆市", 106.5516, 29.5630),
        ("西安市", 108.9398, 34.3416),
        ("武汉市", 114.3055, 30.5931),
        ("南京市", 118.7969, 32.0603),
        ("天津市", 117.2008, 39.0842),
        ("苏州市", 120.5853, 31.2989),
        ("郑州市", 113.6254, 34.7466),
        ("长沙市", 112.9388, 28.2282),
        ("沈阳市", 123.4328, 41.8045),
        ("青岛市", 120.3826, 36.0671),
        ("大连市", 121.6147, 38.9140),
        ("济南市", 117.1205, 36.6519),
        ("哈尔滨市", 126.6433, 45.7566),
        ("昆明市", 102.8329, 24.8801),
        ("福州市", 119.2965, 26.0745),
        ("厦门市", 118.0894, 24.4798),
        ("南宁市", 108.3669, 22.8172),
        ("贵阳市", 106.7135, 26.5783),
        ("太原市", 112.5489, 37.8706),
        ("南昌市", 115.8581, 28.6832),
        ("长春市", 125.3235, 43.8171),
        ("石家庄市", 114.5149, 38.0428),
        ("呼和浩特市", 111.6708, 40.8183),
        ("兰州市", 103.8343, 36.0611),
        ("银川市", 106.2586, 38.4680),
        ("西宁市", 101.7782, 36.6171),
        ("乌鲁木齐市", 87.6168, 43.8256),
        ("拉萨市", 91.1145, 29.6446),
        // 臺灣主要城市
        ("臺北市", 121.5654, 25.0330),
        ("新北市", 121.4628, 25.0170),
        ("桃園市", 121.3009, 24.9937),
        ("臺中市", 120.6736, 24.1477),
        ("臺南市", 120.2269, 22.9998),
        ("高雄市", 120.3014, 22.6273),
        ("新竹市", 120.9647, 24.8066),
        ("基隆市", 121.7419, 25.1276),
        // 香港
        ("香港中西區", 114.1543, 22.2860),
        ("香港九龍", 114.1694, 22.3119),
        ("香港新界", 114.1952, 22.3880),
        // 澳門
        ("澳門", 113.5439, 22.1987),
        // 新加坡
        ("新加坡 Central Area", 103.8198, 1.3521),
        // 马来西亚
        ("马来西亚 Kuala Lumpur", 101.6869, 3.1390),
        ("马来西亚 George Town", 100.3292, 5.4164),
        ("马来西亚 Johor Bahru", 103.7578, 1.4927),
        ("马来西亚 Ipoh", 101.0901, 4.5975),
        ("马来西亚 Malacca City", 102.2501, 2.1896),
        ("马来西亚 Kota Kinabalu", 116.0735, 5.9804),
        ("马来西亚 Kuching", 110.3441, 1.5497)
    ]

    var filteredCommonCities: [(name: String, lon: Double, lat: Double)] {
        if searchText.isEmpty {
            return commonCities
        }
        return commonCities.filter { $0.name.contains(searchText) }
    }

    struct CitySearchResult {
        let name: String
        let province: String
        let longitude: Double
        let latitude: Double
        var fullName: String { "\(province) \(name)" }
    }

    private func searchAllCities(_ query: String) -> [CitySearchResult] {
        guard !query.isEmpty else { return [] }

        var results: [CitySearchResult] = []

        // Search common cities first
        for city in commonCities where city.name.contains(query) {
            results.append(CitySearchResult(name: city.name, province: "", longitude: city.lon, latitude: city.lat))
        }

        // Search all province cities
        for (province, cities) in ChinaCityData.cities {
            for city in cities where city.name.contains(query) {
                // Avoid duplicates with common cities
                if !results.contains(where: { $0.name == city.name && $0.province.isEmpty }) {
                    results.append(CitySearchResult(name: city.name, province: province, longitude: city.longitude, latitude: city.latitude))
                }
            }
        }

        return results
    }

    private func selectSearchedCity(_ city: CitySearchResult) {
        if city.province.isEmpty {
            selectedLocation = city.name
        } else {
            selectedLocation = city.fullName
        }
        longitude = city.longitude
        latitude = city.latitude
    }

    private func selectCommonCity(_ city: (name: String, lon: Double, lat: Double)) {
        selectedLocation = city.name
        longitude = city.lon
        latitude = city.lat
    }

    private func applyManualInput() {
        guard let lon = Double(manualLongitude),
            let lat = Double(manualLatitude),
            lon >= -180 && lon <= 180,
            lat >= -90 && lat <= 90 else {
            return
        }

        longitude = lon
        latitude = lat
        selectedLocation = manualLocationName.isEmpty ? strings.customLocation : manualLocationName
    }
}

struct MainlandProvinceListView: View {
    @Binding var selectedLocation: String
    @Binding var longitude: Double
    @Binding var latitude: Double
    let dismiss: () -> Void
    @ObservedObject private var localizationManager = LocalizationManager.shared

    private var strings: LocalizedStrings {
        localizationManager.strings
    }

    var body: some View {
        List {
            ForEach(ChinaCityData.mainlandProvinces, id: \.self) { province in
                NavigationLink(destination: CityListView(
                    province: province,
                    selectedLocation: $selectedLocation,
                    longitude: $longitude,
                    latitude: $latitude,
                    dismiss: dismiss
                )) {
                    Text(province)
                        .font(.appSerif(size: 16, weight: .medium))
                }
            }
        }
        .navigationTitle(strings.selectProvince)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CityListView: View {
    let province: String
    @Binding var selectedLocation: String
    @Binding var longitude: Double
    @Binding var latitude: Double
    let dismiss: () -> Void
    @ObservedObject private var localizationManager = LocalizationManager.shared

    var cities: [ChinaCityData.City] {
        ChinaCityData.cities[province] ?? []
    }

    private var strings: LocalizedStrings {
        localizationManager.strings
    }

    var body: some View {
        Group {
            if cities.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "mappin.slash")
                        .font(.appSerif(size: 50))
                        .foregroundColor(.secondary)
                    Text(strings.noCityData)
                        .font(.appSerif(size: 17, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    Section(header: Text("\(strings.selectCity) (\(cities.count))").font(.appSerif(size: 13))) {
                        ForEach(cities) { city in
                            Button(action: {
                                selectCity(city)
                            }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(city.name)
                                        .font(.appSerif(size: 16, weight: .medium))
                                        .foregroundColor(.primary)
                                    Text("\(strings.longitude): \(String(format: "%.4f", city.longitude))°, \(strings.latitude): \(String(format: "%.4f", city.latitude))°")
                                        .font(.appSerif(size: 12, weight: .regular))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(province)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func selectCity(_ city: ChinaCityData.City) {
        selectedLocation = "\(city.province) \(city.name)"
        longitude = city.longitude
        latitude = city.latitude
        dismiss()
    }
}

struct BirthInfoForm_Previews: PreviewProvider {
    static var previews: some View {
        BirthInfoForm(onSubmit: { _ in })
    }
}
