import SwiftUI

// MARK: - Chart Insights View (shown during analysis loading)
/// Displays dynamic, hardcoded chart insights while AI analysis is generating.
/// Content is factual and non-conclusive — designed to engage users during wait time.
struct ChartInsightsView: View {
    let insights: [ChartInsightItem]
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var expandedId: String? = nil
    @State private var appearAnimations: Set<String> = []

    private var strings: LocalizedStrings {
        localizationManager.strings
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Section header
            HStack(spacing: 8) {
                Image(systemName: "text.book.closed")
                    .font(.appSerif(size: 14))
                    .foregroundColor(.flowingGold)

                Text(strings.chartInsightsTitle)
                    .font(.appSerif(size: 15, weight: .semibold))
                    .foregroundColor(.foregroundText)

                Spacer()

                Text(strings.chartInsightsSubtitle)
                    .font(.appSerif(size: 12, weight: .regular))
                    .foregroundColor(.mutedText)
            }
            .padding(.bottom, 2)

            // Insight cards
            ForEach(insights) { item in
                insightCard(item: item)
                    .opacity(appearAnimations.contains(item.id) ? 1 : 0)
                    .offset(y: appearAnimations.contains(item.id) ? 0 : 12)
                    .onAppear {
                        let delay = Double(insights.firstIndex(where: { $0.id == item.id }) ?? 0) * 0.15
                        withAnimation(.easeOut(duration: 0.4).delay(delay)) {
                            appearAnimations.insert(item.id)
                        }
                    }
            }
        }
    }

    // MARK: - Single Insight Card
    private func insightCard(item: ChartInsightItem) -> some View {
        let isExpanded = expandedId == item.id

        return Button(action: {
            HapticManager.lightImpact()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                expandedId = isExpanded ? nil : item.id
            }
        }) {
            VStack(alignment: .leading, spacing: 0) {
                // Header row
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.flowingGold.opacity(0.1))
                            .frame(width: 36, height: 36)

                        Image(systemName: item.icon)
                            .font(.appSerif(size: 15))
                            .foregroundColor(.flowingGold)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.label.localized)
                            .font(.appSerif(size: 14, weight: .semibold))
                            .foregroundColor(.foregroundText)

                        Text(item.title.localized)
                            .font(.appSerif(size: 12, weight: .regular))
                            .foregroundColor(.mutedText)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.appSerif(size: 12))
                        .foregroundColor(.mutedText.opacity(0.6))
                }

                // Expanded body
                if isExpanded {
                    Text(item.body.localized)
                        .font(.appSerif(size: 13, weight: .regular))
                        .foregroundColor(.foregroundText.opacity(0.85))
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 12)
                        .padding(.leading, 48)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(14)
            .background(Color.cardBackground)
            .cornerRadius(Theme.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                    .stroke(
                        isExpanded ? Color.flowingGold.opacity(0.25) : Color.white.opacity(0.08),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
