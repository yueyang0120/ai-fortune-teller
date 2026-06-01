import SwiftUI

struct CategorySelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var localizationManager = LocalizationManager.shared
    let onSelectCategory: (AnalysisTopic) -> Void
    var onSelectSynastry: (() -> Void)? = nil

    // Personal analysis topics (五行 right after 综合)
    private let categoryTopics: [(topic: AnalysisTopic, icon: String)] = [
        (.overall, "star.fill"),
        (.fiveElements, "circle.grid.cross.fill"),
        (.love, "heart.fill"),
        (.career, "briefcase.fill"),
        (.wealth, "yensign.circle.fill"),
        (.health, "heart.text.square.fill"),
        (.yearFortune, "calendar")
    ]

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
                // Header
                headerView

                // Categories List
                ScrollView {
                    VStack(spacing: 12) {
                        // Section header: Personal analysis
                        HStack(spacing: 12) {
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 1)
                            Text(strings.personalSection)
                                .font(.appSerif(size: 13, weight: .medium))
                                .foregroundColor(.mutedText)
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 1)
                        }
                        .padding(.bottom, 4)

                        // Personal analysis topics
                        ForEach(Array(categoryTopics.enumerated()), id: \.element.topic) { index, category in
                            CategoryCard(
                                title: strings.categoryTitle(for: category.topic),
                                description: strings.categoryDescription(for: category.topic),
                                icon: category.icon,
                                delay: Double(index) * 0.1,
                                showBadge: category.topic == .fiveElements ? strings.newBadge : nil
                            ) {
                                onSelectCategory(category.topic)
                            }
                        }

                        // Section: Synastry (two-person analysis)
                        if onSelectSynastry != nil {
                            HStack(spacing: 12) {
                                Rectangle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 1)
                                Text(strings.synastrySection)
                                    .font(.appSerif(size: 13, weight: .medium))
                                    .foregroundColor(.mutedText)
                                Rectangle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 1)
                            }
                            .padding(.vertical, 8)

                            CategoryCard(
                                title: strings.synastryCardTitle,
                                description: strings.synastryCardSubtitle,
                                icon: "person.2.circle",
                                delay: Double(categoryTopics.count) * 0.1,
                                showBadge: strings.newBadge
                            ) {
                                onSelectSynastry?()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                headerOffset = 0
                headerOpacity = 1
            }
        }
    }

    private var headerView: some View {
        HStack(spacing: 16) {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .font(.appSerif(size: 20))
                    .foregroundColor(.mutedText)
                    .frame(width: 40, height: 40)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(strings.selectCategory)
                    .font(.appSerif(size: 22, weight: .semibold))
                    .foregroundColor(.foregroundText)

                Text(strings.selectCategoryHint)
                    .font(.appSerif(size: 14, weight: .regular))
                    .foregroundColor(.mutedText)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .offset(y: headerOffset)
        .opacity(headerOpacity)
    }
}

// MARK: - Category Card (matching reference exactly)
struct CategoryCard: View {
    let title: String
    let description: String
    let icon: String
    let delay: Double
    var showBadge: String? = nil
    let action: () -> Void

    @State private var isVisible = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon container
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.flowingGold.opacity(0.1))
                        .frame(width: 48, height: 48)

                    Image(systemName: icon)
                        .font(.appSerif(size: 24))
                        .foregroundColor(.flowingGold)
                }

                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.appSerif(size: 17, weight: .semibold))
                            .foregroundColor(.foregroundText)

                        if let badge = showBadge {
                            Text(badge)
                                .font(.appSerif(size: 11, weight: .semibold))
                                .foregroundColor(.cardBackgroundSolid)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.flowingGold)
                                .cornerRadius(4)
                        }
                    }

                    Text(description)
                        .font(.appSerif(size: 14, weight: .regular))
                        .foregroundColor(.mutedText)
                }

                Spacer()

                // Arrow
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        .frame(width: 32, height: 32)

                    Image(systemName: "chevron.right")
                        .font(.appSerif(size: 14))
                        .foregroundColor(.mutedText)
                }
            }
            .padding(20)
            .background(Color.cardBackground)
            .cornerRadius(Theme.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(CategoryCardButtonStyle())
        .opacity(isVisible ? 1 : 0)
        .offset(x: isVisible ? 0 : -20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(delay)) {
                isVisible = true
            }
        }
    }
}

/// Custom ButtonStyle that provides press feedback without blocking ScrollView gestures
struct CategoryCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Preview
struct CategorySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        CategorySelectionView(
            onSelectCategory: { topic in
                print("Selected: \(topic)")
            },
            onSelectSynastry: {
                print("Synastry selected")
            }
        )
    }
}
