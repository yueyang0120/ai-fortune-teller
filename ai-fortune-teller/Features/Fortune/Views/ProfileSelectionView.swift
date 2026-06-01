import SwiftUI

/// View for selecting or managing birth profiles before starting a reading
struct ProfileSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @ObservedObject private var profileService = BirthProfileService.shared

    let selectedTopic: AnalysisTopic
    let onSelectProfile: (BirthProfile) -> Void
    let onCreateNew: () -> Void

    @State private var showingDeleteConfirmation = false
    @State private var profileToDelete: BirthProfile?
    @State private var profileToEdit: BirthProfile?

    private var strings: LocalizedStrings {
        localizationManager.strings
    }

    var body: some View {
        ZStack {
            StarFieldBackground()

            VStack(spacing: 0) {
                // Header
                headerView

                ScrollView {
                    VStack(spacing: 16) {
                        // Hint text
                        if profileService.hasProfiles {
                            Text(strings.selectProfileHint)
                                .font(.appSerif(size: 14, weight: .regular))
                                .foregroundColor(.mutedText)
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                        }

                        // Profile cards
                        ForEach(profileService.profiles) { profile in
                            ProfileCardView(
                                profile: profile,
                                onTap: {
                                    onSelectProfile(profile)
                                    presentationMode.wrappedValue.dismiss()
                                },
                                onEdit: {
                                    profileToEdit = profile
                                },
                                onDelete: {
                                    profileToDelete = profile
                                    showingDeleteConfirmation = true
                                },
                                onSetDefault: {
                                    profileService.setDefaultProfile(id: profile.id)
                                }
                            )
                        }

                        // Add new profile button
                        addNewProfileButton

                        // Empty state
                        if !profileService.hasProfiles {
                            emptyStateView
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .alert(strings.deleteProfileConfirmation, isPresented: $showingDeleteConfirmation) {
            Button(strings.cancel, role: .cancel) {
                profileToDelete = nil
            }
            Button(strings.delete, role: .destructive) {
                if let profile = profileToDelete {
                    profileService.deleteProfile(profile)
                    profileToDelete = nil
                }
            }
        } message: {
            if let profile = profileToDelete {
                Text(strings.deleteProfileMessage(profile.name))
            }
        }
        .sheet(item: $profileToEdit) { profile in
            ProfileEditView(
                profile: profile,
                onSave: { updatedProfile in
                    profileService.updateProfile(updatedProfile)
                    profileToEdit = nil
                },
                onCancel: {
                    profileToEdit = nil
                }
            )
        }
    }

    // MARK: - Header View
    private var headerView: some View {
        HStack(spacing: 16) {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .font(.appSerif(size: 20))
                    .foregroundColor(.mutedText)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(strings.selectProfile)
                    .font(.appSerif(size: 22, weight: .semibold))
                    .foregroundColor(.foregroundText)
                Text(strings.categoryTitle(for: selectedTopic))
                    .font(.appSerif(size: 14, weight: .regular))
                    .foregroundColor(.flowingGold)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(Color.cardBackgroundSolid.opacity(0.95))
    }

    // MARK: - Add New Profile Button (使用中性表达，不强调"保存档案")
    private var addNewProfileButton: some View {
        Button(action: {
            onCreateNew()
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.flowingGold.opacity(0.1))
                        .frame(width: 50, height: 50)

                    Image(systemName: "pencil.line")
                        .font(.appSerif(size: 20, weight: .medium))
                        .foregroundColor(.flowingGold)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(strings.enterNewInfo)
                        .font(.appSerif(size: 17, weight: .semibold))
                        .foregroundColor(.foregroundText)
                    Text(strings.enterNewInfoHint)
                        .font(.appSerif(size: 13, weight: .regular))
                        .foregroundColor(.mutedText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.appSerif(size: 16))
                    .foregroundColor(.mutedText)
            }
            .padding(16)
            .background(Color.cardBackground)
            .cornerRadius(Theme.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                    .stroke(Color.flowingGold.opacity(0.3), lineWidth: 1)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
            )
        }
    }

    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.flowingGold.opacity(0.5))

            Text(strings.noProfilesYet)
                .font(.appSerif(size: 18, weight: .semibold))
                .foregroundColor(.foregroundText)

            Text(strings.noProfilesHint)
                .font(.appSerif(size: 14, weight: .regular))
                .foregroundColor(.mutedText)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }
}

// MARK: - Profile Card View
struct ProfileCardView: View {
    let profile: BirthProfile
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onSetDefault: () -> Void

    @ObservedObject private var localizationManager = LocalizationManager.shared

    private var strings: LocalizedStrings {
        localizationManager.strings
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(profile.isDefault ? Color.flowingGold.opacity(0.15) : Color.white.opacity(0.05))
                        .frame(width: 50, height: 50)

                    Circle()
                        .stroke(profile.isDefault ? Color.flowingGold.opacity(0.4) : Color.white.opacity(0.1), lineWidth: 1)
                        .frame(width: 50, height: 50)

                    Text(String(profile.name.prefix(1)))
                        .font(.appSerif(size: 20, weight: .semibold))
                        .foregroundColor(profile.isDefault ? .flowingGold : .foregroundText)
                }

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(profile.name)
                            .font(.appSerif(size: 17, weight: .semibold))
                            .foregroundColor(.foregroundText)

                        if profile.isDefault {
                            Text(strings.defaultBadge)
                                .font(.appSerif(size: 10, weight: .medium))
                                .foregroundColor(.flowingGold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.flowingGold.opacity(0.15))
                                .cornerRadius(4)
                        }
                    }

                    Text(profile.displaySummary)
                        .font(.appSerif(size: 13, weight: .regular))
                        .foregroundColor(.mutedText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.appSerif(size: 16))
                    .foregroundColor(.mutedText)
            }
            .padding(16)
            .background(Color.cardBackground)
            .cornerRadius(Theme.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                    .stroke(profile.isDefault ? Color.flowingGold.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .contextMenu {
            Button(action: onEdit) {
                Label(strings.editProfile, systemImage: "pencil")
            }

            if !profile.isDefault {
                Button(action: onSetDefault) {
                    Label(strings.setAsDefault, systemImage: "star")
                }
            }

            Divider()

            Button(role: .destructive, action: onDelete) {
                Label(strings.delete, systemImage: "trash")
            }
        }
    }
}

// MARK: - Profile Edit View (Full Edit with BirthInfoForm-style UI)
struct ProfileEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var localizationManager = LocalizationManager.shared

    let profile: BirthProfile
    let onSave: (BirthProfile) -> Void
    let onCancel: () -> Void

    // Editable fields
    @State private var profileName: String
    @State private var selectedGender: Gender
    @State private var calendarType: CalendarType
    @State private var solarYear: Int
    @State private var solarMonth: Int
    @State private var solarDay: Int
    @State private var lunarYear: Int
    @State private var lunarMonth: Int
    @State private var lunarDay: Int
    @State private var isLeapMonth: Bool
    @State private var selectedHour: Int
    @State private var selectedMinute: Int
    @State private var location: String
    @State private var longitude: Double
    @State private var latitude: Double
    @State private var useRealSolarTime: Bool
    @State private var showingLocationPicker = false

    enum TimeInputMode {
        case exact
        case shichen
    }
    @State private var timeInputMode: TimeInputMode = .exact

    private var strings: LocalizedStrings {
        localizationManager.strings
    }

    init(profile: BirthProfile, onSave: @escaping (BirthProfile) -> Void, onCancel: @escaping () -> Void) {
        self.profile = profile
        self.onSave = onSave
        self.onCancel = onCancel

        // Initialize state from profile
        self._profileName = State(initialValue: profile.name)
        self._selectedGender = State(initialValue: profile.gender)
        self._calendarType = State(initialValue: profile.calendarType)
        self._solarYear = State(initialValue: profile.solarYear)
        self._solarMonth = State(initialValue: profile.solarMonth)
        self._solarDay = State(initialValue: profile.solarDay)
        self._selectedHour = State(initialValue: profile.birthHour)
        self._selectedMinute = State(initialValue: profile.birthMinute)
        self._location = State(initialValue: profile.location)
        self._longitude = State(initialValue: profile.longitude)
        self._latitude = State(initialValue: profile.latitude)
        self._useRealSolarTime = State(initialValue: profile.useRealSolarTime)

        // Lunar date
        if let lunar = profile.lunarDate {
            self._lunarYear = State(initialValue: lunar.year)
            self._lunarMonth = State(initialValue: lunar.month)
            self._lunarDay = State(initialValue: lunar.day)
            self._isLeapMonth = State(initialValue: lunar.isLeapMonth)
        } else {
            self._lunarYear = State(initialValue: profile.solarYear)
            self._lunarMonth = State(initialValue: 1)
            self._lunarDay = State(initialValue: 1)
            self._isLeapMonth = State(initialValue: false)
        }
    }

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

    var body: some View {
        ZStack {
            StarFieldBackground()

            VStack(spacing: 0) {
                // Header
                headerView

                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Name
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 12) {
                                    Image(systemName: "person.text.rectangle")
                                        .foregroundColor(.flowingGold)
                                    Text(strings.profileName)
                                        .font(.appSerif(size: 17, weight: .medium))
                                        .foregroundColor(.foregroundText)
                                }

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

                        // Gender Selection
                        GlassCard {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 12) {
                                    Image(systemName: "person")
                                        .foregroundColor(.flowingGold)
                                    Text(strings.gender)
                                        .font(.appSerif(size: 17, weight: .medium))
                                        .foregroundColor(.foregroundText)
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
                                }

                                // Calendar Type Picker
                                HStack(spacing: 12) {
                                    calendarTypeButton(title: strings.solarCalendar, type: .solar)
                                    calendarTypeButton(title: strings.lunarCalendar, type: .lunar)
                                }

                                if calendarType == .solar {
                                    solarDatePicker
                                } else {
                                    lunarDatePicker
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
                                }

                                // Time Mode Picker
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
                                    exactTimePicker
                                } else {
                                    shichenPicker
                                }
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
                            }
                        }

                        // True Solar Time
                        GlassCard {
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
                                Toggle("", isOn: $useRealSolarTime)
                                    .labelsHidden()
                                    .toggleStyle(SwitchToggleStyle(tint: .flowingGold))
                            }
                        }

                        // Save Button
                        Button(action: saveProfile) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle")
                                Text(strings.save)
                            }
                        }
                        .buttonStyle(GoldButtonStyle())
                        .disabled(profileName.trimmingCharacters(in: .whitespaces).isEmpty || location.isEmpty)
                        .opacity((profileName.trimmingCharacters(in: .whitespaces).isEmpty || location.isEmpty) ? 0.5 : 1.0)
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
        }
        .sheet(isPresented: $showingLocationPicker) {
            LocationPickerView(
                selectedLocation: $location,
                longitude: $longitude,
                latitude: $latitude
            )
        }
    }

    // MARK: - Header View
    private var headerView: some View {
        HStack(spacing: 16) {
            Button(action: {
                onCancel()
            }) {
                Image(systemName: "xmark")
                    .font(.appSerif(size: 18))
                    .foregroundColor(.mutedText)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(strings.editProfile)
                    .font(.appSerif(size: 22, weight: .semibold))
                    .foregroundColor(.foregroundText)
                Text(strings.editProfileHint)
                    .font(.appSerif(size: 14, weight: .regular))
                    .foregroundColor(.mutedText)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(Color.cardBackgroundSolid.opacity(0.95))
    }

    // MARK: - Date Pickers
    private var solarDatePicker: some View {
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
        .onChange(of: solarYear) { _ in validateSolarDay() }
        .onChange(of: solarMonth) { _ in validateSolarDay() }
    }

    private var lunarDatePicker: some View {
        VStack {
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

    // MARK: - Time Pickers
    private var exactTimePicker: some View {
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
    }

    private var shichenPicker: some View {
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

    // MARK: - Helper Views
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

    private func validateSolarDay() {
        let maxDays = daysInSolarMonth
        if solarDay > maxDays {
            solarDay = maxDays
        }
    }

    // MARK: - Save Profile
    private func saveProfile() {
        // Build solar date
        var dateComponents = DateComponents()
        dateComponents.year = solarYear
        dateComponents.month = solarMonth
        dateComponents.day = solarDay
        dateComponents.hour = selectedHour
        dateComponents.minute = selectedMinute

        var finalSolarDate: Date
        let lunarDateInfo: LunarDate?

        if calendarType == .lunar {
            lunarDateInfo = LunarDate(
                year: lunarYear,
                month: lunarMonth,
                day: lunarDay,
                isLeapMonth: isLeapMonth
            )

            // Convert lunar to solar
            let chartService = ZiWeiChartService()
            if let convertedDate = chartService.convertLunarToSolar(
                lunarYear: lunarYear,
                lunarMonth: lunarMonth,
                lunarDay: lunarDay,
                isLeapMonth: isLeapMonth
            ) {
                var convertedComponents = Calendar.current.dateComponents([.year, .month, .day], from: convertedDate)
                convertedComponents.hour = selectedHour
                convertedComponents.minute = selectedMinute
                finalSolarDate = Calendar.current.date(from: convertedComponents) ?? convertedDate
            } else {
                finalSolarDate = Calendar.current.date(from: dateComponents) ?? Date()
            }
        } else {
            lunarDateInfo = nil
            finalSolarDate = Calendar.current.date(from: dateComponents) ?? Date()
        }

        // Create updated profile with all fields
        var updatedProfile = profile
        updatedProfile.name = profileName.trimmingCharacters(in: .whitespaces)
        updatedProfile.gender = selectedGender
        updatedProfile.calendarType = calendarType
        updatedProfile.solarDate = finalSolarDate
        updatedProfile.birthHour = selectedHour
        updatedProfile.birthMinute = selectedMinute
        updatedProfile.location = location
        updatedProfile.longitude = longitude
        updatedProfile.latitude = latitude
        updatedProfile.useRealSolarTime = useRealSolarTime
        updatedProfile.lunarDate = lunarDateInfo
        updatedProfile.updatedAt = Date()

        onSave(updatedProfile)
    }
}

// MARK: - Profile Management View (Settings 入口)
struct ProfileManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @ObservedObject private var profileService = BirthProfileService.shared

    @State private var showingDeleteConfirmation = false
    @State private var profileToDelete: BirthProfile?
    @State private var profileToEdit: BirthProfile?
    @State private var showingAddProfile = false

    private var strings: LocalizedStrings {
        localizationManager.strings
    }

    var body: some View {
        ZStack {
            StarFieldBackground()

            VStack(spacing: 0) {
                // Custom header
                headerView

                ScrollView {
                    VStack(spacing: 16) {
                        // Hint text
                        Text(strings.manageProfilesHint)
                            .font(.appSerif(size: 14, weight: .regular))
                            .foregroundColor(.mutedText)
                            .padding(.horizontal, 20)
                            .padding(.top, 8)

                        if profileService.hasProfiles {
                            // Profile cards with full management options
                            ForEach(profileService.profiles) { profile in
                                ProfileManagementCardView(
                                    profile: profile,
                                    onEdit: {
                                        profileToEdit = profile
                                    },
                                    onDelete: {
                                        profileToDelete = profile
                                        showingDeleteConfirmation = true
                                    },
                                    onSetDefault: {
                                        profileService.setDefaultProfile(id: profile.id)
                                    }
                                )
                            }
                        } else {
                            // Empty state
                            emptyStateView
                        }

                        // Add new profile button
                        addNewProfileButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .alert(strings.deleteProfileConfirmation, isPresented: $showingDeleteConfirmation) {
            Button(strings.cancel, role: .cancel) {
                profileToDelete = nil
            }
            Button(strings.delete, role: .destructive) {
                if let profile = profileToDelete {
                    profileService.deleteProfile(profile)
                    profileToDelete = nil
                }
            }
        } message: {
            if let profile = profileToDelete {
                Text(strings.deleteProfileMessage(profile.name))
            }
        }
        .sheet(item: $profileToEdit) { profile in
            ProfileEditView(
                profile: profile,
                onSave: { updatedProfile in
                    profileService.updateProfile(updatedProfile)
                    profileToEdit = nil
                },
                onCancel: {
                    profileToEdit = nil
                }
            )
        }
        .sheet(isPresented: $showingAddProfile) {
            AddProfileOnlyView()
        }
    }

    // MARK: - Header View
    private var headerView: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(strings.manageProfiles)
                    .font(.appSerif(size: 22, weight: .semibold))
                    .foregroundColor(.foregroundText)
            }

            Spacer()

            Button(action: {
                dismiss()
            }) {
                Text(strings.done)
                    .font(.appSerif(size: 16, weight: .medium))
                    .foregroundColor(.flowingGold)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(Color.cardBackgroundSolid.opacity(0.95))
    }

    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.flowingGold.opacity(0.5))

            Text(strings.noProfilesYet)
                .font(.appSerif(size: 18, weight: .semibold))
                .foregroundColor(.foregroundText)

            Text(strings.noProfilesHint)
                .font(.appSerif(size: 14, weight: .regular))
                .foregroundColor(.mutedText)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }

    // MARK: - Add New Profile Button
    private var addNewProfileButton: some View {
        Button(action: {
            showingAddProfile = true
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.flowingGold.opacity(0.1))
                        .frame(width: 50, height: 50)

                    Image(systemName: "plus")
                        .font(.appSerif(size: 22, weight: .medium))
                        .foregroundColor(.flowingGold)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(strings.addNewProfile)
                        .font(.appSerif(size: 17, weight: .semibold))
                        .foregroundColor(.foregroundText)
                    Text(strings.addNewProfileHint)
                        .font(.appSerif(size: 13, weight: .regular))
                        .foregroundColor(.mutedText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.appSerif(size: 16))
                    .foregroundColor(.mutedText)
            }
            .padding(16)
            .background(Color.cardBackground)
            .cornerRadius(Theme.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                    .stroke(Color.flowingGold.opacity(0.3), lineWidth: 1)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
            )
        }
    }
}

// MARK: - Profile Management Card View (用于档案管理页面，显示更多管理选项)
struct ProfileManagementCardView: View {
    let profile: BirthProfile
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onSetDefault: () -> Void

    @ObservedObject private var localizationManager = LocalizationManager.shared

    private var strings: LocalizedStrings {
        localizationManager.strings
    }

    var body: some View {
        VStack(spacing: 0) {
            // Profile Info
            HStack(spacing: 14) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(profile.isDefault ? Color.flowingGold.opacity(0.15) : Color.white.opacity(0.05))
                        .frame(width: 50, height: 50)

                    Circle()
                        .stroke(profile.isDefault ? Color.flowingGold.opacity(0.4) : Color.white.opacity(0.1), lineWidth: 1)
                        .frame(width: 50, height: 50)

                    Text(String(profile.name.prefix(1)))
                        .font(.appSerif(size: 20, weight: .semibold))
                        .foregroundColor(profile.isDefault ? .flowingGold : .foregroundText)
                }

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(profile.name)
                            .font(.appSerif(size: 17, weight: .semibold))
                            .foregroundColor(.foregroundText)

                        if profile.isDefault {
                            Text(strings.defaultBadge)
                                .font(.appSerif(size: 10, weight: .medium))
                                .foregroundColor(.flowingGold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.flowingGold.opacity(0.15))
                                .cornerRadius(4)
                        }
                    }

                    Text(profile.displaySummary)
                        .font(.appSerif(size: 13, weight: .regular))
                        .foregroundColor(.mutedText)
                }

                Spacer()
            }
            .padding(16)

            // Divider
            Rectangle()
                .fill(Color.white.opacity(0.05))
                .frame(height: 1)

            // Action Buttons
            HStack(spacing: 0) {
                // Edit Button
                Button(action: onEdit) {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil")
                            .font(.appSerif(size: 14))
                        Text(strings.editProfile)
                            .font(.appSerif(size: 14, weight: .medium))
                    }
                    .foregroundColor(.flowingGold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }

                // Vertical Divider
                Rectangle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 1)

                // Set Default Button (only if not default)
                if !profile.isDefault {
                    Button(action: onSetDefault) {
                        HStack(spacing: 6) {
                            Image(systemName: "star")
                                .font(.appSerif(size: 14))
                            Text(strings.setAsDefault)
                                .font(.appSerif(size: 14, weight: .medium))
                        }
                        .foregroundColor(.mutedText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }

                    // Vertical Divider
                    Rectangle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 1)
                }

                // Delete Button
                Button(action: onDelete) {
                    HStack(spacing: 6) {
                        Image(systemName: "trash")
                            .font(.appSerif(size: 14))
                        Text(strings.delete)
                            .font(.appSerif(size: 14, weight: .medium))
                    }
                    .foregroundColor(.destructiveRed)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
            }
        }
        .background(Color.cardBackground)
        .cornerRadius(Theme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .stroke(profile.isDefault ? Color.flowingGold.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Add Profile Only View (仅添加档案，不开始测算)
struct AddProfileOnlyView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @ObservedObject private var profileService = BirthProfileService.shared

    @State private var selectedHour = 12
    @State private var selectedMinute = 0
    @State private var selectedGender: Gender = .male
    @State private var calendarType: CalendarType = .solar
    @State private var location = ""
    @State private var longitude: Double = 0.0
    @State private var latitude: Double = 0.0
    @State private var useRealSolarTime = true
    @State private var showingLocationPicker = false
    @State private var profileName = ""

    @State private var solarYear = Calendar.current.component(.year, from: Date())
    @State private var solarMonth = Calendar.current.component(.month, from: Date())
    @State private var solarDay = Calendar.current.component(.day, from: Date())

    @State private var lunarYear = Calendar.current.component(.year, from: Date())
    @State private var lunarMonth = 1
    @State private var lunarDay = 1
    @State private var isLeapMonth = false

    enum TimeInputMode {
        case exact
        case shichen
    }
    @State private var timeInputMode: TimeInputMode = .exact

    private var strings: LocalizedStrings {
        localizationManager.strings
    }

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

    var body: some View {
        NavigationView {
            ZStack {
                StarFieldBackground()

                ScrollView {
                    VStack(spacing: 24) {
                        // 档案名称（放在最前面，突出这是添加档案）
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 12) {
                                    Image(systemName: "person.badge.plus")
                                        .foregroundColor(.flowingGold)
                                    Text(strings.profileName)
                                        .font(.appSerif(size: 17, weight: .medium))
                                        .foregroundColor(.foregroundText)
                                }

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

                        // Gender Selection
                        GlassCard {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 12) {
                                    Image(systemName: "person")
                                        .foregroundColor(.flowingGold)
                                    Text(strings.gender)
                                        .font(.appSerif(size: 17, weight: .medium))
                                        .foregroundColor(.foregroundText)
                                }

                                HStack(spacing: 12) {
                                    genderButton(title: strings.male, value: .male)
                                    genderButton(title: strings.female, value: .female)
                                }
                            }
                        }

                        // Date Selection (simplified)
                        GlassCard {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 12) {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.flowingGold)
                                    Text(strings.birthDate)
                                        .font(.appSerif(size: 17, weight: .medium))
                                        .foregroundColor(.foregroundText)
                                }

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
                            }
                        }

                        // Time Selection (simplified)
                        GlassCard {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 12) {
                                    Image(systemName: "clock")
                                        .foregroundColor(.flowingGold)
                                    Text(strings.birthTime)
                                        .font(.appSerif(size: 17, weight: .medium))
                                        .foregroundColor(.foregroundText)
                                }

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
                            }
                        }

                        // Save Button
                        Button(action: saveProfile) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle")
                                Text(strings.save)
                            }
                        }
                        .buttonStyle(GoldButtonStyle())
                        .disabled(location.isEmpty)
                        .opacity(location.isEmpty ? 0.5 : 1.0)
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
            .navigationTitle(strings.addNewProfile)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(strings.cancel) {
                        dismiss()
                    }
                    .font(.appSerif(size: 16, weight: .medium))
                    .foregroundColor(.flowingGold)
                }
            }
        }
        .sheet(isPresented: $showingLocationPicker) {
            LocationPickerView(
                selectedLocation: $location,
                longitude: $longitude,
                latitude: $latitude
            )
        }
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

    private func saveProfile() {
        // Create BirthInfo
        var dateComponents = DateComponents()
        dateComponents.year = solarYear
        dateComponents.month = solarMonth
        dateComponents.day = solarDay
        dateComponents.hour = selectedHour
        dateComponents.minute = selectedMinute

        guard let solarDate = Calendar.current.date(from: dateComponents) else { return }

        let birthInfo = BirthInfo(
            solarDate: solarDate,
            lunarDate: nil,
            birthTime: BirthInfo.getChineseHour(from: selectedHour),
            birthHour: selectedHour,
            birthMinute: selectedMinute,
            location: location,
            longitude: longitude,
            latitude: latitude,
            gender: selectedGender,
            calendarType: .solar,
            useRealSolarTime: useRealSolarTime,
            analysisTopic: .overall
        )

        // Save profile
        let name = profileName.trimmingCharacters(in: .whitespaces)
        let finalName = name.isEmpty ? strings.defaultProfileName : name
        _ = profileService.createProfile(from: birthInfo, name: finalName)

        dismiss()
    }
}

// MARK: - Preview
struct ProfileSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSelectionView(
            selectedTopic: .overall,
            onSelectProfile: { _ in },
            onCreateNew: { }
        )
    }
}
