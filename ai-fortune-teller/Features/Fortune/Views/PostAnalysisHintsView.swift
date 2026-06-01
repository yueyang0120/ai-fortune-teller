import SwiftUI

// MARK: - Post-Analysis Hints View
/// Shows action cards after analysis is complete to guide user to next steps
struct PostAnalysisHintsView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared

    var onGoToHistory: (() -> Void)?
    var onTryAnother: (() -> Void)?
    var onShare: (() -> Void)?

    private var strings: LocalizedStrings {
        localizationManager.strings
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            HStack(spacing: 8) {
                Rectangle()
                    .fill(Color.flowingGold.opacity(0.5))
                    .frame(width: 3, height: 16)
                    .cornerRadius(1.5)

                Text(strings.postAnalysisTitle)
                    .font(.appSerif(size: 14, weight: .medium))
                    .foregroundColor(.mutedText)
            }
            .padding(.bottom, 4)

            // Action cards
            if let onGoToHistory = onGoToHistory {
                hintCard(
                    icon: "clock.arrow.circlepath",
                    title: strings.postAnalysisHistory,
                    subtitle: strings.postAnalysisHistoryHint,
                    action: onGoToHistory
                )
            }

            if let onTryAnother = onTryAnother {
                hintCard(
                    icon: "sparkles",
                    title: strings.postAnalysisTryAnother,
                    subtitle: strings.postAnalysisTryAnotherHint,
                    action: onTryAnother
                )
            }

            if let onShare = onShare {
                hintCard(
                    icon: "square.and.arrow.up",
                    title: strings.postAnalysisShare,
                    subtitle: strings.postAnalysisShareHint,
                    action: onShare
                )
            }
        }
    }

    private func hintCard(icon: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            HapticManager.softImpact()
            action()
        }) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.flowingGold.opacity(0.1))
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.appSerif(size: 16))
                        .foregroundColor(.flowingGold)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.appSerif(size: 15, weight: .medium))
                        .foregroundColor(.foregroundText)

                    Text(subtitle)
                        .font(.appSerif(size: 12, weight: .regular))
                        .foregroundColor(.mutedText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.appSerif(size: 13))
                    .foregroundColor(.mutedText.opacity(0.6))
            }
            .padding(14)
            .background(Color.cardBackground)
            .cornerRadius(Theme.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
