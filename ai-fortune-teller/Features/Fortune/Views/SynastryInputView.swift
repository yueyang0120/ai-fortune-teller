import SwiftUI

struct SynastryInputView: View {
    let synastryType: SynastryType
    let onSubmit: (BirthInfo, BirthInfo, RelationshipRole?) -> Void

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.synastryFlowBack) var flowBack
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @ObservedObject private var profileService = BirthProfileService.shared

    @State private var currentStep: Int
    @State private var selectedRole: RelationshipRole?
    @State private var personAInfo: BirthInfo?
    @State private var personBInfo: BirthInfo?
    @State private var showingProfilePickerA = false
    @State private var showingProfilePickerB = false
    @State private var showingBirthFormA = false
    @State private var showingBirthFormB = false
    @State private var pendingShowFormA = false
    @State private var pendingShowFormB = false

    init(synastryType: SynastryType, onSubmit: @escaping (BirthInfo, BirthInfo, RelationshipRole?) -> Void) {
        self.synastryType = synastryType
        self.onSubmit = onSubmit
        // Start at step 0 (role selection) if type requires it, otherwise step 1
        _currentStep = State(initialValue: synastryType.requiresRole ? 0 : 1)
    }

    private var strings: LocalizedStrings {
        localizationManager.strings
    }

    /// Total number of steps (for step indicator)
    private var totalSteps: Int {
        synastryType.requiresRole ? 3 : 2
    }

    /// Person input step numbers
    private var personAStep: Int { synastryType.requiresRole ? 1 : 1 }
    private var personBStep: Int { synastryType.requiresRole ? 2 : 2 }

    /// Person A label: use role-specific label if available
    private var personALabel: String {
        if let role = selectedRole {
            return strings.rolePersonALabel(for: role)
        }
        if synastryType == .pet {
            return strings.synastryPetOwner
        }
        return strings.synastryPersonA
    }

    /// Person B label: use role-specific label if available
    private var personBLabel: String {
        if let role = selectedRole {
            return strings.rolePersonBLabel(for: role)
        }
        if synastryType == .pet {
            return strings.synastryPetAnimal
        }
        return strings.synastryPersonB
    }

    var body: some View {
        ZStack {
            StarFieldBackground()

            VStack(spacing: 0) {
                headerView

                ScrollView {
                    VStack(spacing: 24) {
                        stepIndicator

                        if currentStep == 0 {
                            roleSelectionSection
                        } else if currentStep == personAStep {
                            personInputSection(
                                label: personALabel,
                                personInfo: personAInfo,
                                onSelectProfile: { showingProfilePickerA = true },
                                onCreateNew: {
                                    if profileService.hasProfiles {
                                        showingProfilePickerA = true
                                    } else {
                                        showingBirthFormA = true
                                    }
                                }
                            )
                        } else {
                            personInputSection(
                                label: personBLabel,
                                personInfo: personBInfo,
                                onSelectProfile: { showingProfilePickerB = true },
                                onCreateNew: {
                                    if profileService.hasProfiles {
                                        showingProfilePickerB = true
                                    } else {
                                        showingBirthFormB = true
                                    }
                                }
                            )
                        }

                        actionButtons
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingProfilePickerA, onDismiss: {
            if pendingShowFormA {
                pendingShowFormA = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showingBirthFormA = true
                }
            }
        }) {
            ProfileSelectionView(
                selectedTopic: .overall,
                onSelectProfile: { profile in
                    personAInfo = profile.toBirthInfo(topic: .overall)
                    showingProfilePickerA = false
                    currentStep = personBStep
                },
                onCreateNew: {
                    pendingShowFormA = true
                    showingProfilePickerA = false
                }
            )
        }
        .sheet(isPresented: $showingBirthFormA) {
            BirthInfoForm(
                selectedTopic: .overall,
                existingProfile: nil,
                isFirstTimeUser: !profileService.hasProfiles,
                onSubmit: { birthInfo in
                    personAInfo = birthInfo
                    showingBirthFormA = false
                    currentStep = personBStep
                }
            )
        }
        .sheet(isPresented: $showingProfilePickerB, onDismiss: {
            if pendingShowFormB {
                pendingShowFormB = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showingBirthFormB = true
                }
            }
        }) {
            ProfileSelectionView(
                selectedTopic: .overall,
                onSelectProfile: { profile in
                    personBInfo = profile.toBirthInfo(topic: .overall)
                    showingProfilePickerB = false
                },
                onCreateNew: {
                    pendingShowFormB = true
                    showingProfilePickerB = false
                }
            )
        }
        .sheet(isPresented: $showingBirthFormB) {
            BirthInfoForm(
                selectedTopic: .overall,
                existingProfile: nil,
                isFirstTimeUser: false,
                onSubmit: { birthInfo in
                    personBInfo = birthInfo
                    showingBirthFormB = false
                }
            )
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(spacing: 16) {
            Button(action: {
                let firstStep = synastryType.requiresRole ? 0 : 1
                if currentStep > firstStep {
                    withAnimation { currentStep -= 1 }
                } else if let flowBack = flowBack {
                    // Go back to type selection within the flow
                    flowBack()
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                Image(systemName: "arrow.left")
                    .font(.appSerif(size: 20))
                    .foregroundColor(.mutedText)
                    .frame(width: 40, height: 40)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(strings.synastryTitle(for: synastryType))
                    .font(.appSerif(size: 22, weight: .semibold))
                    .foregroundColor(.foregroundText)

                Text(headerSubtitle)
                    .font(.appSerif(size: 14, weight: .regular))
                    .foregroundColor(.mutedText)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
    }

    private var headerSubtitle: String {
        if currentStep == 0 {
            return strings.synastrySelectRole
        } else if currentStep == personAStep {
            return strings.synastryStepA
        } else {
            return strings.synastryStepB
        }
    }

    // MARK: - Step Indicator

    private var stepIndicator: some View {
        HStack(spacing: 8) {
            if synastryType.requiresRole {
                stepDot(isActive: currentStep >= 0, isCurrent: currentStep == 0)
            }
            stepDot(isActive: currentStep >= personAStep, isCurrent: currentStep == personAStep)
            stepDot(isActive: currentStep >= personBStep, isCurrent: currentStep == personBStep)
        }
        .padding(.bottom, 8)
    }

    private func stepDot(isActive: Bool, isCurrent: Bool) -> some View {
        Circle()
            .fill(isActive ? Color.flowingGold : Color.white.opacity(0.15))
            .frame(width: isCurrent ? 10 : 8, height: isCurrent ? 10 : 8)
            .animation(.easeInOut(duration: 0.2), value: isCurrent)
    }

    // MARK: - Role Selection Section

    private var roleSelectionSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text(strings.synastrySelectRole)
                    .font(.appSerif(size: 18, weight: .semibold))
                    .foregroundColor(.foregroundText)
                Spacer()
            }

            ForEach(synastryType.availableRoles) { role in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedRole = role
                    }
                }) {
                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.flowingGold.opacity(selectedRole == role ? 0.2 : 0.1))
                                .frame(width: 48, height: 48)
                            Image(systemName: role.icon)
                                .font(.appSerif(size: 24))
                                .foregroundColor(.flowingGold)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(strings.roleTitle(for: role))
                                .font(.appSerif(size: 17, weight: .semibold))
                                .foregroundColor(.foregroundText)
                            Text(strings.roleDescription(for: role))
                                .font(.appSerif(size: 14, weight: .regular))
                                .foregroundColor(.mutedText)
                        }

                        Spacer()

                        if selectedRole == role {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.appSerif(size: 22))
                                .foregroundColor(.flowingGold)
                        } else {
                            Circle()
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                .frame(width: 22, height: 22)
                        }
                    }
                    .padding(16)
                    .background(Color.cardBackground)
                    .cornerRadius(Theme.cardCornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                            .stroke(selectedRole == role ? Color.flowingGold.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    // MARK: - Person Input Section

    private func personInputSection(
        label: String,
        personInfo: BirthInfo?,
        onSelectProfile: @escaping () -> Void,
        onCreateNew: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text(label)
                    .font(.appSerif(size: 18, weight: .semibold))
                    .foregroundColor(.foregroundText)
                Spacer()
            }

            if let info = personInfo {
                selectedPersonCard(info: info)
            } else {
                VStack(spacing: 12) {
                    if profileService.hasProfiles {
                        Button(action: onSelectProfile) {
                            HStack(spacing: 12) {
                                Image(systemName: "person.crop.circle")
                                    .font(.appSerif(size: 20))
                                    .foregroundColor(.flowingGold)
                                Text(strings.synastrySelectFromProfiles)
                                    .font(.appSerif(size: 16, weight: .medium))
                                    .foregroundColor(.foregroundText)
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
                    }

                    Button(action: onCreateNew) {
                        HStack(spacing: 12) {
                            Image(systemName: "plus.circle")
                                .font(.appSerif(size: 20))
                                .foregroundColor(.flowingGold)
                            Text(strings.synastryEnterNewInfo)
                                .font(.appSerif(size: 16, weight: .medium))
                                .foregroundColor(.foregroundText)
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
                                .stroke(Color.flowingGold.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Selected Person Card

    private func selectedPersonCard(info: BirthInfo) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.flowingGold.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: "checkmark.circle.fill")
                    .font(.appSerif(size: 20))
                    .foregroundColor(.flowingGold)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(info.displayDateString)
                    .font(.appSerif(size: 16, weight: .medium))
                    .foregroundColor(.foregroundText)
                Text("\(info.displayTimeString) \(info.location)")
                    .font(.appSerif(size: 13, weight: .regular))
                    .foregroundColor(.mutedText)
            }

            Spacer()

            Image(systemName: "checkmark")
                .font(.appSerif(size: 16, weight: .semibold))
                .foregroundColor(.flowingGold)
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(Theme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .stroke(Color.flowingGold.opacity(0.4), lineWidth: 1)
        )
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Role step: proceed to person A
            if currentStep == 0 && selectedRole != nil {
                Button(action: {
                    withAnimation { currentStep = personAStep }
                }) {
                    Text(strings.synastryNextStep)
                        .font(.appSerif(size: 17, weight: .semibold))
                        .foregroundColor(.cardBackgroundSolid)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.flowingGold)
                        .cornerRadius(Theme.cardCornerRadius)
                }
            }

            // Person A step: proceed to person B
            if currentStep == personAStep && personAInfo != nil {
                Button(action: {
                    withAnimation { currentStep = personBStep }
                }) {
                    Text(strings.synastryNextStep)
                        .font(.appSerif(size: 17, weight: .semibold))
                        .foregroundColor(.cardBackgroundSolid)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.flowingGold)
                        .cornerRadius(Theme.cardCornerRadius)
                }
            }

            // Person B step: start analysis
            if currentStep == personBStep && personAInfo != nil && personBInfo != nil {
                Button(action: {
                    if let a = personAInfo, let b = personBInfo {
                        onSubmit(a, b, selectedRole)
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.appSerif(size: 18))
                        Text(strings.synastryStartAnalysis)
                            .font(.appSerif(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.cardBackgroundSolid)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.flowingGold)
                    .cornerRadius(Theme.cardCornerRadius)
                }
            }
        }
        .padding(.top, 8)
    }
}
