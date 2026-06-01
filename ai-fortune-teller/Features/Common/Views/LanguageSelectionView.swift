import SwiftUI

/// 首次启动时的语言选择界面
/// 使用中性命名，避免政治敏感
struct LanguageSelectionView: View {
    @ObservedObject var localizationManager: LocalizationManager
    let onLanguageSelected: () -> Void

    @State private var selectedLanguage: AppLanguage = .simplifiedChinese
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 20
    @State private var buttonsOpacity: Double = 0
    @State private var buttonsOffset: CGFloat = 30
    @State private var continueButtonOpacity: Double = 0

    var body: some View {
        ZStack {
            StarFieldBackground()

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 80)

                // Logo
                logoSection
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                Spacer()
                    .frame(height: 32)

                // Title
                titleSection
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)

                Spacer()
                    .frame(height: 48)

                // Language Options
                languageOptionsSection
                    .offset(y: buttonsOffset)
                    .opacity(buttonsOpacity)

                Spacer()

                // Continue Button
                continueButton
                    .opacity(continueButtonOpacity)
                    .padding(.bottom, 60)
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            selectedLanguage = localizationManager.currentLanguage
            startAnimations()
        }
    }

    // MARK: - Logo Section
    private var logoSection: some View {
        ZStack {
            // Outer circle
            Circle()
                .stroke(Color.flowingGold.opacity(0.3), lineWidth: 1)
                .frame(width: 100, height: 100)

            // Inner circle
            Circle()
                .stroke(Color.flowingGold.opacity(0.2), lineWidth: 1)
                .frame(width: 80, height: 80)

            // Center text
            Text("紫微")
                .font(.appSerif(size: 32, weight: .semibold))
                .foregroundColor(.flowingGold)

            // Orbiting dots
            ForEach(0..<4, id: \.self) { i in
                LanguageOrbitingDot(index: i)
            }
        }
    }

    // MARK: - Title Section
    // 语言选择界面始终使用简体中文
    private var titleSection: some View {
        VStack(spacing: 12) {
            Text("选择语言")
                .font(.appSerif(size: 28, weight: .semibold))
                .foregroundColor(.foregroundText)
                .tracking(4)

            Text("请选择您偏好的语言")
                .font(.appSerif(size: 15, weight: .regular))
                .foregroundColor(.mutedText)
        }
    }

    // MARK: - Language Options Section
    private var languageOptionsSection: some View {
        VStack(spacing: 12) {
            ForEach(AppLanguage.allCases, id: \.self) { language in
                LanguageOptionButton(
                    language: language,
                    isSelected: selectedLanguage == language
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedLanguage = language
                        // 只更新选中状态，不立即应用语言
                        // 语言将在用户点击"继续"按钮后才生效
                    }
                }
            }
        }
    }

    // MARK: - Continue Button
    private var continueButton: some View {
        Button(action: {
            localizationManager.setLanguage(selectedLanguage)
            onLanguageSelected()
        }) {
            HStack(spacing: 8) {
                Text(continueButtonText)
                    .font(.appSerif(size: 17, weight: .semibold))
                Image(systemName: "arrow.right")
                    .font(.appSerif(size: 16, weight: .semibold))
            }
            .foregroundColor(.deepSpaceStart)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [Color.flowingGold, Color.flowingGold.opacity(0.9)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color.flowingGold.opacity(0.3), radius: 12, x: 0, y: 6)
        }
    }

    // 根据选中的语言显示对应的确认按钮文本
    private var continueButtonText: String {
        switch selectedLanguage {
        case .simplifiedChinese:
            return "确定"
        case .traditionalChinese:
            return "確定"
        case .english:
            return "Confirm"
        }
    }

    // MARK: - Animations
    private func startAnimations() {
        // Logo animation
        withAnimation(.easeOut(duration: 0.7)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }

        // Title animation
        withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
            titleOpacity = 1.0
            titleOffset = 0
        }

        // Buttons animation
        withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
            buttonsOpacity = 1.0
            buttonsOffset = 0
        }

        // Continue button animation
        withAnimation(.easeOut(duration: 0.5).delay(0.6)) {
            continueButtonOpacity = 1.0
        }
    }
}

// MARK: - Language Option Button
struct LanguageOptionButton: View {
    let language: AppLanguage
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(language.nativeDisplayName)
                        .font(.appSerif(size: 17, weight: .medium))
                        .foregroundColor(isSelected ? .flowingGold : .foregroundText)

                    Text(languageDescription)
                        .font(.appSerif(size: 13, weight: .regular))
                        .foregroundColor(.mutedText)
                }

                Spacer()

                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.flowingGold : Color.mutedText.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(Color.flowingGold)
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.flowingGold.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var languageDescription: String {
        switch language {
        case .simplifiedChinese: return "Simplified Chinese"
        case .traditionalChinese: return "Traditional Chinese"
        case .english: return "English"
        }
    }
}

// MARK: - Orbiting Dot for Language Selection
struct LanguageOrbitingDot: View {
    let index: Int
    @State private var animationProgress: CGFloat = 0

    // Calculate initial angle based on index
    private var initialAngle: CGFloat {
        CGFloat(index) * .pi / 2
    }

    var body: some View {
        Circle()
            .fill(Color.flowingGold)
            .frame(width: 6, height: 6)
            .offset(x: cos(animationProgress + initialAngle) * 45,
                    y: sin(animationProgress + initialAngle) * 45)
            .onAppear {
                // Use DispatchQueue to delay the start instead of .delay() on animation
                // This avoids timing conflicts with repeatForever animations
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) {
                    withAnimation(
                        Animation.linear(duration: 10)
                            .repeatForever(autoreverses: false)
                    ) {
                        animationProgress = .pi * 2
                    }
                }
            }
    }
}

// MARK: - Preview
struct LanguageSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        LanguageSelectionView(
            localizationManager: LocalizationManager.shared,
            onLanguageSelected: {}
        )
    }
}
