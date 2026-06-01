import SwiftUI

// MARK: - Card Data Model
struct CarouselCard: Identifiable {
    let id: String
    let titleKey: String  // Used for localization lookup
    let subtitleKey: String  // Used for localization lookup
    let icon: String
    let isMain: Bool

    // Localized title based on current language
    func title(using strings: LocalizedStrings) -> String {
        switch id {
        case "history": return strings.historyCardTitle
        case "reading": return strings.readingCardTitle
        case "settings": return strings.settingsCardTitle
        default: return titleKey
        }
    }

    // Localized subtitle based on current language
    func subtitle(using strings: LocalizedStrings) -> String {
        switch id {
        case "history": return strings.historyCardSubtitle
        case "reading": return strings.readingCardSubtitle
        case "settings": return strings.settingsCardSubtitle
        default: return subtitleKey
        }
    }

    // Style properties
    var gradientColors: [Color] {
        if isMain {
            return [Color.flowingGold.opacity(0.2), Color.flowingGold.opacity(0.1), Color.flowingGold.opacity(0.2)]
        } else {
            return [Color(hex: "2d2d3a").opacity(0.9), Color(hex: "3a3a4a").opacity(0.8), Color(hex: "2d2d3a").opacity(0.9)]
        }
    }

    var borderColor: Color {
        isMain ? Color.flowingGold.opacity(0.4) : Color(hex: "6b7280").opacity(0.3)
    }

    var accentColor: Color {
        isMain ? Color.flowingGold : Color(hex: "cbd5e1")
    }

    var iconBackgroundColor: Color {
        isMain ? Color.flowingGold.opacity(0.2) : Color(hex: "4b5563").opacity(0.3)
    }
}

// MARK: - Home Carousel View
struct HomeCarouselView: View {
    let onStartReading: () -> Void
    let onGoToHistory: () -> Void
    let onGoToSettings: () -> Void

    @ObservedObject private var localizationManager = LocalizationManager.shared

    @State private var activeIndex: Int = 1
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging: Bool = false
    @State private var dragStartTime: Date = Date()
    @State private var totalDragDistance: CGFloat = 0

    // Animation states
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0
    @State private var titleOffset: CGFloat = 20
    @State private var titleOpacity: Double = 0
    @State private var cardsOpacity: Double = 0
    @State private var indicatorOpacity: Double = 0
    @State private var footerOpacity: Double = 0
    @State private var swipeHintOffset: CGFloat = 0  // For swipe hint animation

    // Logo Rotation
    @State private var outerRotation: Double = 0
    @State private var innerRotation: Double = 0

    private let cards: [CarouselCard] = [
        CarouselCard(id: "history", titleKey: "History", subtitleKey: "View past readings", icon: "clock", isMain: false),
        CarouselCard(id: "reading", titleKey: "Start Reading", subtitleKey: "Explore your chart", icon: "sparkles", isMain: true),
        CarouselCard(id: "settings", titleKey: "Settings", subtitleKey: "Customize preferences", icon: "gearshape", isMain: false)
    ]

    private let cardWidth: CGFloat = 224  // w-56 = 224px
    private let cardHeight: CGFloat = 288 // h-72 = 288px
    private let cardSpacing: CGFloat = 140

    // Minimum drag distance to be considered a swipe (prevents accidental taps from triggering swipe)
    private let minDragDistanceForSwipe: CGFloat = 15

    private var strings: LocalizedStrings {
        localizationManager.strings
    }

    var body: some View {
        ZStack {
            // Ambient Effects
            EtherealCloudView()
                .ignoresSafeArea()

            RisingChiView()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 60)

                // Logo with concentric circles
                logoSection
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                // Title and subtitle
                titleSection
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)

                // Swipe hint
                Text(strings.swipeHint)
                    .font(.appSerif(size: 14, weight: .regular))
                    .foregroundColor(.mutedText)
                    .padding(.top, 8)
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)

                Spacer()
                    .frame(height: 40)

                // Card Carousel
                cardCarouselSection
                    .opacity(cardsOpacity)

                // Dot Indicators
                dotIndicators
                    .opacity(indicatorOpacity)
                    .padding(.top, 24)

                Spacer()

                // Footer
                footerSection
                    .opacity(footerOpacity)
                    .padding(.bottom, 100)
            }
            .onAppear {
                startAnimations()
            }
        }
    }

    // MARK: - Logo Section
    private var logoSection: some View {
        ZStack {
            // Outer rotating circle
            Circle()
                .trim(from: 0, to: 0.8) // Make it partial for rotation visibility
                .stroke(Color.flowingGold.opacity(0.3), style: StrokeStyle(lineWidth: 1, lineCap: .round))
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(outerRotation))

            // Inner rotating circle (opposite direction)
            Circle()
                .trim(from: 0, to: 0.6) // Make it partial for rotation visibility
                .stroke(Color.flowingGold.opacity(0.2), style: StrokeStyle(lineWidth: 1, lineCap: .round))
                .frame(width: 64, height: 64)
                .rotationEffect(.degrees(innerRotation))

            // Center text
            Text(strings.appLogo)
                .font(.appSerif(size: 24, weight: .semibold))
                .foregroundColor(.flowingGold)

            // Animated star dots
            ForEach(0..<4, id: \.self) { i in
                OrbitingDot(index: i)
            }
        }
        .padding(.bottom, 24)
    }

    // MARK: - Title Section
    private var titleSection: some View {
        VStack(spacing: 8) {
            Text(strings.appTitle)
                .font(.appSerif(size: 24, weight: .semibold))
                .foregroundColor(.foregroundText)
                .tracking(4)
        }
    }

    // MARK: - Card Carousel Section
    private var cardCarouselSection: some View {
        ZStack {
            // Left arrow - more visible
            if activeIndex > 0 {
                Button(action: goToPrev) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.flowingGold.opacity(0.7))
                }
                .accessibilityLabel(strings.previousCard)
                .offset(x: -UIScreen.main.bounds.width / 2 + 28)
                .transition(.opacity)
            }

            // Right arrow - more visible
            if activeIndex < cards.count - 1 {
                Button(action: goToNext) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.flowingGold.opacity(0.7))
                }
                .accessibilityLabel(strings.nextCard)
                .offset(x: UIScreen.main.bounds.width / 2 - 28)
                .transition(.opacity)
            }

            // Cards - side cards are now more visible to hint at swipe
            ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                let offset = index - activeIndex
                let isActive = index == activeIndex
                let isVisible = abs(offset) <= 1

                if isVisible {
                    CardView(
                        card: card,
                        isActive: isActive,
                        strings: strings
                    )
                    .offset(x: CGFloat(offset) * cardSpacing + dragOffset + (isActive ? swipeHintOffset : 0))
                    .scaleEffect(isActive ? 1.0 : 0.75)
                    .opacity(isActive ? 1.0 : 0.35)  // Subtle but visible
                    .blur(radius: isActive ? 0 : 1.5)
                    .zIndex(isActive ? 10 : 1)
                    .rotation3DEffect(
                        .degrees(Double(offset) * -6),  // Slightly less rotation
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .allowsHitTesting(isActive && !isDragging)
                    .onTapGesture {
                        if !isDragging && abs(totalDragDistance) < minDragDistanceForSwipe {
                            handleCardTap(index: index)
                        }
                    }
                    .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.75, blendDuration: 0.1), value: activeIndex)
                }
            }
        }
        .frame(maxWidth: .infinity)  // 扩大宽度以便在卡片外也能拖拽
        .frame(height: cardHeight + 20)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 5)
                .onChanged { value in
                    if !isDragging {
                        isDragging = true
                        dragStartTime = Date()
                        totalDragDistance = 0
                    }
                    dragOffset = value.translation.width
                    totalDragDistance = abs(value.translation.width)
                }
                .onEnded { value in
                    let velocity = value.predictedEndTranslation.width - value.translation.width
                    let threshold: CGFloat = 40
                    let velocityThreshold: CGFloat = 200

                    // Check both distance and velocity for better swipe detection
                    let shouldSwipeLeft = (value.translation.width > threshold || velocity > velocityThreshold) && activeIndex > 0
                    let shouldSwipeRight = (value.translation.width < -threshold || velocity < -velocityThreshold) && activeIndex < cards.count - 1

                    withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.75, blendDuration: 0.1)) {
                        if shouldSwipeLeft {
                            activeIndex -= 1
                        } else if shouldSwipeRight {
                            activeIndex += 1
                        }
                        dragOffset = 0
                    }

                    // Delay resetting isDragging to prevent accidental tap after swipe
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        isDragging = false
                        totalDragDistance = 0
                    }
                }
        )
    }

    // MARK: - Dot Indicators
    private var dotIndicators: some View {
        HStack(spacing: 8) {
            ForEach(Array(cards.enumerated()), id: \.element.id) { index, _ in
                Capsule()
                    .fill(index == activeIndex ? Color.flowingGold : Color.mutedText.opacity(0.3))
                    .frame(width: index == activeIndex ? 24 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.3), value: activeIndex)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            activeIndex = index
                        }
                    }
            }
        }
    }

    // MARK: - Footer Section
    private var footerSection: some View {
        HStack(spacing: 16) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.clear, Color.mutedText.opacity(0.3)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 48, height: 1)

            Text(strings.motto)
                .font(.appSerif(size: 12, weight: .regular))
                .foregroundColor(.mutedText.opacity(0.4))
                .tracking(6)

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.mutedText.opacity(0.3), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 48, height: 1)
        }
    }

    // MARK: - Actions
    private func goToPrev() {
        if activeIndex > 0 {
            HapticManager.selection()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                activeIndex -= 1
            }
        }
    }

    private func goToNext() {
        if activeIndex < cards.count - 1 {
            HapticManager.selection()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                activeIndex += 1
            }
        }
    }

    private func handleCardTap(index: Int) {
        if isDragging { return }

        if index == activeIndex {
            // Haptic feedback for card activation
            HapticManager.softImpact()
            // Navigate to the selected feature
            switch cards[index].id {
            case "reading":
                onStartReading()
            case "history":
                onGoToHistory()
            case "settings":
                onGoToSettings()
            default:
                break
            }
        } else {
            // Haptic feedback for card switch
            HapticManager.lightImpact()
            // Make tapped card active
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                activeIndex = index
            }
        }
    }

    private func startAnimations() {
        // Logo animation
        withAnimation(.easeOut(duration: 0.6)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }

        // Title animation
        withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
            titleOffset = 0
            titleOpacity = 1.0
        }

        // Cards animation
        withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
            cardsOpacity = 1.0
        }

        // Indicators animation
        withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
            indicatorOpacity = 1.0
        }

        // Footer animation
        withAnimation(.easeOut(duration: 0.8).delay(0.8)) {
            footerOpacity = 1.0
        }

        // Logo Rotation Animation
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            outerRotation = 360
        }
        withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
            innerRotation = -360
        }

        // Subtle swipe hint animation - wiggle the card slightly
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeInOut(duration: 0.3)) {
                swipeHintOffset = -12
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    swipeHintOffset = 12
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        swipeHintOffset = 0
                    }
                }
            }
        }
    }
}

// MARK: - Orbiting Dot
struct OrbitingDot: View {
    let index: Int
    @State private var animationProgress: CGFloat = 0

    var body: some View {
        Circle()
            .fill(Color.flowingGold)
            .frame(width: 6, height: 6)
            .offset(x: cos(animationProgress + CGFloat(index) * .pi / 2) * 36,
                    y: sin(animationProgress + CGFloat(index) * .pi / 2) * 36)
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 8)
                        .repeatForever(autoreverses: false)
                        .delay(Double(index) * 0.5)
                ) {
                    animationProgress = .pi * 2
                }
            }
    }
}

// MARK: - Card View
struct CardView: View {
    let card: CarouselCard
    let isActive: Bool
    let strings: LocalizedStrings

    @State private var shimmerOffset: CGFloat = -1
    @State private var sparkleOpacity: [Double] = [0.3, 0.3, 0.3, 0.3]
    @State private var sparklePositions: [(x: CGFloat, y: CGFloat)] = []
    @State private var iconGlowOpacity: Double = 0.3

    private let cardWidth: CGFloat = 224
    private let cardHeight: CGFloat = 288

    var body: some View {
        ZStack {
            // Background with gradient
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: card.gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(card.borderColor, lineWidth: 1)
                )

            // Shimmer effect for main card
            if card.isMain && isActive {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.flowingGold.opacity(0.05),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .mask(
                        GeometryReader { geometry in
                            Rectangle()
                                .frame(width: geometry.size.width * 0.4)
                                .offset(x: shimmerOffset * geometry.size.width)
                        }
                    )
                    .onAppear {
                        withAnimation(
                            Animation.linear(duration: 3)
                                .repeatForever(autoreverses: false)
                                .delay(2)
                        ) {
                            shimmerOffset = 1.5
                        }
                    }
            }

            // Decorative circles
            VStack {
                HStack {
                    Spacer()
                    Circle()
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                        .frame(width: 96, height: 96)
                        .offset(x: 24, y: -24)
                }
                Spacer()
                HStack {
                    Circle()
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                        .frame(width: 64, height: 64)
                        .offset(x: -16, y: 16)
                    Spacer()
                }
            }

            // Card content
            VStack(spacing: 0) {
                Spacer()

                // Icon background
                ZStack {
                    // Glow ring for main card
                    if card.isMain && isActive {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.flowingGold.opacity(iconGlowOpacity * 0.3))
                            .frame(width: 80, height: 80)
                            .blur(radius: 12)
                    }

                    RoundedRectangle(cornerRadius: 16)
                        .fill(card.iconBackgroundColor)
                        .frame(width: 64, height: 64)

                    Image(systemName: card.icon)
                        .font(.appSerif(size: 32, weight: .medium))
                        .foregroundColor(card.accentColor)
                }
                .padding(.bottom, 24)

                // Title - only show when active
                if isActive {
                    Text(card.title(using: strings))
                        .font(.appSerif(size: 20, weight: .medium))
                        .foregroundColor(card.accentColor)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 8)

                    // Subtitle
                    Text(card.subtitle(using: strings))
                        .font(.appSerif(size: 14, weight: .regular))
                        .foregroundColor(.mutedText)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }

                Spacer()

                // Tap hint - only show when active
                if isActive {
                    Text(strings.tapToEnter)
                        .font(.appSerif(size: 12, weight: .regular))
                        .foregroundColor(.mutedText.opacity(0.6))
                        .padding(.bottom, 24)
                } else {
                    Spacer()
                        .frame(height: 44)
                }
            }
            .padding(24)

            // Sparkles for main card when active
            if card.isMain && isActive {
                ForEach(0..<4, id: \.self) { i in
                    if i < sparklePositions.count {
                        Circle()
                            .fill(Color.flowingGold.opacity(0.6))
                            .frame(width: 4, height: 4)
                            .position(x: sparklePositions[i].x, y: sparklePositions[i].y)
                            .opacity(sparkleOpacity[i])
                            .scaleEffect(sparkleOpacity[i] > 0.5 ? 1.5 : 1.0)
                    }
                }
            }
        }
        .frame(width: cardWidth, height: card.isMain && isActive ? cardHeight + 20 : cardHeight)
        .shadow(
            color: card.isMain && isActive ? Color.flowingGold.opacity(0.2) : Color.clear,
            radius: 20,
            x: 0,
            y: 10
        )
        .contentShape(Rectangle())
        .onAppear {
            // Generate stable sparkle positions
            if sparklePositions.isEmpty {
                sparklePositions = (0..<4).map { _ in
                    (x: CGFloat.random(in: 30...cardWidth-30),
                     y: CGFloat.random(in: 50...cardHeight-80))
                }
            }

            // Start sparkle animations with staggered delays
            // Use DispatchQueue instead of .delay() on repeatForever to avoid animation timing conflicts
            for i in 0..<4 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.3) {
                    withAnimation(
                        Animation.easeInOut(duration: 2 + Double.random(in: 0...1))
                            .repeatForever(autoreverses: true)
                    ) {
                        sparkleOpacity[i] = 0.8
                    }
                }
            }

            // Icon glow animation for main card
            if card.isMain {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    iconGlowOpacity = 0.7
                }
            }
        }
    }
}

// MARK: - Ethereal Cloud / Mist View
struct EtherealCloudView: View {
    @State private var move = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Cloud 1 - Flowing Gold Mist
                Ellipse()
                    .fill(Color.flowingGold.opacity(0.06))
                    .frame(width: geometry.size.width * 1.6, height: 240)
                    .offset(x: move ? -geometry.size.width * 0.3 : geometry.size.width * 0.3, y: -120)
                    .blur(radius: 70)

                // Cloud 2 - Deep Mystery Mist
                Ellipse()
                    .fill(Color(hex: "4A4A6A").opacity(0.08))
                    .frame(width: geometry.size.width * 1.4, height: 200)
                    .offset(x: move ? geometry.size.width * 0.2 : -geometry.size.width * 0.2, y: 140)
                    .blur(radius: 60)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onAppear {
                withAnimation(.easeInOut(duration: 15).repeatForever(autoreverses: true)) {
                    move.toggle()
                }
            }
        }
    }
}

// MARK: - Rising Chi (Energy) Particles
struct RisingChiView: View {
    @State private var particles: [Particle] = []

    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var scale: CGFloat
        var opacity: Double
        var speed: CGFloat
    }

    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(Color.flowingGold)
                        .frame(width: 3, height: 3)
                        .scaleEffect(particle.scale)
                        .opacity(particle.opacity)
                        .position(x: particle.x, y: particle.y)
                }
            }
            .onReceive(timer) { _ in
                updateParticles(in: geometry.size)
            }
        }
    }

    private func updateParticles(in size: CGSize) {
        // Add new particle
        if Double.random(in: 0...1) < 0.15 { // Adjusted density
            particles.append(Particle(
                x: CGFloat.random(in: 0...size.width),
                y: size.height + 20,
                scale: CGFloat.random(in: 0.3...1.0),
                opacity: Double.random(in: 0.1...0.5),
                speed: CGFloat.random(in: 0.2...1.5)
            ))
        }

        // Update existing
        for i in particles.indices {
            particles[i].y -= particles[i].speed
            particles[i].opacity -= 0.003
            particles[i].x += CGFloat.random(in: -0.2...0.2) // Slight drift
        }

        // Remove dead particles
        particles.removeAll { $0.y < -20 || $0.opacity <= 0 }
    }
}

// MARK: - Preview
struct HomeCarouselView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            StarFieldBackground()
            HomeCarouselView(
                onStartReading: {},
                onGoToHistory: {},
                onGoToSettings: {}
            )
        }
    }
}
