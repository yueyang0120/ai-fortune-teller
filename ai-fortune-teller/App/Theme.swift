import SwiftUI
import UIKit

// MARK: - Haptic Feedback Manager
/// Provides premium haptic feedback for enhanced user experience
enum HapticManager {
    /// Light impact - for tab switches, subtle selections
    static func lightImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Soft impact - for card taps, premium feel
    static func softImpact() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Medium impact - for important actions
    static func mediumImpact() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Selection feedback - for picker/selection changes
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    /// Success notification - for completed actions
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
}

// MARK: - Color Extensions
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // Deep Space Background Colors (from globals.css)
    // linear-gradient(180deg, #0a0a12 0%, #12121f 50%, #0a0a12 100%)
    static let deepSpaceStart = Color(hex: "0a0a12")
    static let deepSpaceMid = Color(hex: "12121f")
    static let deepSpaceEnd = Color(hex: "0a0a12")

    // Card Background: --card: oklch(0.12 0.015 280) with 40% opacity
    static let cardBackground = Color(hex: "1c1b22").opacity(0.4)
    static let cardBackgroundSolid = Color(hex: "1c1b22")

    // Primary: Flowing Gold - rgba(212, 175, 55) from star-field.tsx
    static let flowingGold = Color(hex: "D4AF37")

    // Border: --border: oklch(0.22 0.02 280)
    static let goldBorder = Color(hex: "323038")

    // Muted Foreground: --muted-foreground: oklch(0.6 0.03 85)
    static let mutedText = Color(hex: "9ca3af")

    // Foreground: --foreground: oklch(0.92 0.02 85)
    static let foregroundText = Color(hex: "EAEAEA")

    // Secondary background
    static let secondaryBackground = Color(hex: "1f1f2e").opacity(0.3)

    // Destructive
    static let destructiveRed = Color(hex: "EF4444")
}

// MARK: - Font Extensions
extension Font {
    // Serif font to match "Noto Serif SC" from reference
    // Make sure the Noto Serif SC fonts are added to the project and Info.plist
    // with the file names like:
    // - NotoSerifSC-Regular.ttf
    // - NotoSerifSC-Medium.ttf
    // - NotoSerifSC-SemiBold.ttf
    // - NotoSerifSC-Bold.ttf
    // - NotoSerifSC-Light.ttf
    //
    // The names below ("NotoSerifSC-Regular" etc.) must match the
    // PostScript names of the installed fonts.
    private static func notoSerifSCFontName(for weight: Font.Weight) -> String {
        switch weight {
        case .light:
            return "NotoSerifSC-Light"
        case .medium:
            return "NotoSerifSC-Medium"
        case .semibold:
            return "NotoSerifSC-SemiBold"
        case .bold, .heavy:
            return "NotoSerifSC-Bold"
        default:
            return "NotoSerifSC-Regular"
        }
    }

    static func appSerif(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return Font.custom(notoSerifSCFontName(for: weight), size: size)
    }

    static func appSerif(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        // Callers that care about Dynamic Type should pass an explicit size;
        // this helper keeps the API but uses a reasonable default.
        let defaultSize: CGFloat
        switch style {
        case .largeTitle: defaultSize = 34
        case .title: defaultSize = 28
        case .title2: defaultSize = 22
        case .title3: defaultSize = 20
        case .headline: defaultSize = 17
        case .subheadline: defaultSize = 15
        case .body: defaultSize = 17
        case .callout: defaultSize = 16
        case .footnote: defaultSize = 13
        case .caption: defaultSize = 12
        case .caption2: defaultSize = 11
        @unknown default: defaultSize = 17
        }
        return Font.custom(notoSerifSCFontName(for: weight), size: defaultSize)
    }
}

// MARK: - Theme Constants
struct Theme {
    static func backgroundGradient() -> LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: .deepSpaceStart, location: 0),
                .init(color: .deepSpaceMid, location: 0.5),
                .init(color: .deepSpaceEnd, location: 1.0)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static let cardCornerRadius: CGFloat = 16 // rounded-2xl
    static let buttonCornerRadius: CGFloat = 16 // rounded-2xl for buttons
    static let smallCornerRadius: CGFloat = 12 // rounded-xl
}

// MARK: - Background (Clean Gradient)
struct StarFieldBackground: View {
    var body: some View {
        ZStack {
            // Base gradient - deep space feel
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(hex: "08080f"), location: 0),
                    .init(color: Color(hex: "0d0d18"), location: 0.3),
                    .init(color: Color(hex: "111120"), location: 0.6),
                    .init(color: Color(hex: "0a0a14"), location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )

            // Subtle warm glow at top
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.flowingGold.opacity(0.03),
                    Color.clear
                ]),
                center: .top,
                startRadius: 0,
                endRadius: UIScreen.main.bounds.height * 0.6
            )

            // Very subtle accent at bottom
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(hex: "1a1a2e").opacity(0.3),
                    Color.clear
                ]),
                center: .bottom,
                startRadius: 0,
                endRadius: UIScreen.main.bounds.height * 0.5
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - Glass Card Component
struct GlassCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = 20

    init(padding: CGFloat = 20, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                ZStack {
                    Color.cardBackground
                    Color.white.opacity(0.02) // subtle glass effect
                }
            )
            .cornerRadius(Theme.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}

// MARK: - Animated Logo Component
struct AnimatedLogo: View {
    @State private var animationPhases: [Double] = Array(repeating: 0, count: 8)
    @State private var glowOpacity: Double = 0.3

    var body: some View {
        ZStack {
            // Outer circle with glow
            Circle()
                .stroke(Color.flowingGold.opacity(0.3), lineWidth: 2)
                .frame(width: 128, height: 128)
                .shadow(color: Color.flowingGold.opacity(glowOpacity), radius: 20)

            // Inner circle
            Circle()
                .stroke(Color.flowingGold.opacity(0.5), lineWidth: 1)
                .frame(width: 96, height: 96)

            // Center text
            Text("紫微")
                .font(.appSerif(size: 32, weight: .semibold))
                .foregroundColor(.flowingGold)

            // 8 animated star dots around the logo
            ForEach(0..<8, id: \.self) { i in
                Circle()
                    .fill(Color.flowingGold)
                    .frame(width: 6, height: 6)
                    .offset(y: -58) // Position on outer ring
                    .rotationEffect(.degrees(Double(i) * 45))
                    .opacity(animationPhases[i])
                    .scaleEffect(0.8 + animationPhases[i] * 0.4)
            }
        }
        .onAppear {
            // Animate each dot with delay
            for i in 0..<8 {
                withAnimation(
                    Animation.easeInOut(duration: 2)
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.2)
                ) {
                    animationPhases[i] = 1.0
                }
            }

            // Glow animation
            withAnimation(
                Animation.easeInOut(duration: 3)
                    .repeatForever(autoreverses: true)
            ) {
                glowOpacity = 0.6
            }
        }
    }
}

// MARK: - Primary Button Style
struct GoldButtonStyle: ButtonStyle {
    var isDisabled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.appSerif(size: 18, weight: .medium))
            .foregroundColor(.deepSpaceStart)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                ZStack {
                    Color.flowingGold

                    // Shimmer effect
                    if !configuration.isPressed {
                        ShimmerView()
                    }
                }
            )
            .cornerRadius(Theme.buttonCornerRadius)
            .opacity(isDisabled ? 0.5 : (configuration.isPressed ? 0.9 : 1.0))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Shimmer Effect
struct ShimmerView: View {
    @State private var shimmerOffset: CGFloat = -1

    var body: some View {
        GeometryReader { geometry in
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color.white.opacity(0.1),
                    Color.clear
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: geometry.size.width * 0.5)
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

// MARK: - Bottom Navigation Bar (Refined & Lightweight)
struct BottomNavBar: View {
    @Binding var currentPage: AppPage

    enum AppPage {
        case home
        case history
        case settings
    }

    private let navItems: [(page: AppPage, icon: String, label: String)] = [
        (.home, "safari", "排盘"),
        (.history, "clock", "历史"),
        (.settings, "gearshape", "设置")
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(navItems, id: \.page) { item in
                navButton(page: item.page, icon: item.icon, label: item.label)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            // Sleek glass effect with subtle gradient border
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.flowingGold.opacity(0.3),
                                    Color.white.opacity(0.1),
                                    Color.flowingGold.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 24)
        .padding(.bottom, 0)
    }

    private func navButton(page: AppPage, icon: String, label: String) -> some View {
        Button(action: {
            if currentPage != page {
                HapticManager.lightImpact()
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentPage = page
            }
        }) {
            VStack(spacing: 2) {
                Image(systemName: currentPage == page ? "\(icon).fill" : icon)
                    .font(.appSerif(size: 18, weight: currentPage == page ? .semibold : .regular))
                    .foregroundColor(currentPage == page ? .flowingGold : .mutedText.opacity(0.7))
                    .scaleEffect(currentPage == page ? 1.1 : 1.0)

                Text(label)
                    .font(.appSerif(size: 10, weight: currentPage == page ? .semibold : .regular))
                    .foregroundColor(currentPage == page ? .flowingGold : .mutedText.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

extension BottomNavBar.AppPage: Hashable {}

// MARK: - View Extensions
extension View {
    func glassCardStyle(padding: CGFloat = 20) -> some View {
        self
            .padding(padding)
            .background(Color.cardBackground)
            .cornerRadius(Theme.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}
