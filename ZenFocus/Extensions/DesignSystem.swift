//
//  DesignSystem.swift
//  ZenFocus
//
//  Beautiful, calming design system for a wellness-focused productivity app
//

import SwiftUI

// MARK: - Color Palette
extension Color {
    // Primary Brand Colors - Soft, calming tones
    static let zenPrimary = Color("ZenPrimary") // Soft sage green
    static let zenSecondary = Color("ZenSecondary") // Warm terracotta
    static let zenAccent = Color("ZenAccent") // Golden amber
    
    // Background Colors
    static let zenBackground = Color("ZenBackground") // Warm off-white / dark charcoal
    static let zenSurface = Color("ZenSurface") // Card backgrounds
    static let zenSurfaceElevated = Color("ZenSurfaceElevated") // Elevated cards
    
    // Text Colors
    static let zenTextPrimary = Color("ZenTextPrimary")
    static let zenTextSecondary = Color("ZenTextSecondary")
    static let zenTextMuted = Color("ZenTextMuted")
    
    // Semantic Colors
    static let zenSuccess = Color("ZenSuccess") // Soft green
    static let zenWarning = Color("ZenWarning") // Warm orange
    static let zenError = Color("ZenError") // Soft coral
    static let zenInfo = Color("ZenInfo") // Calm blue
    
    // Timer State Colors
    static let zenFocus = Color(hex: "5B8A72") // Deep sage for focus
    static let zenBreak = Color(hex: "E8985E") // Warm terracotta for break
    static let zenRest = Color(hex: "7BA3C9") // Calm blue for long break
    
    // Gradient Colors
    static let zenGradientStart = Color(hex: "F7F5F2") // Warm cream
    static let zenGradientEnd = Color(hex: "E8E4DE") // Soft taupe
    
    // Dark Mode Variants
    static let zenDarkBackground = Color(hex: "1C1C1E")
    static let zenDarkSurface = Color(hex: "2C2C2E")
    static let zenDarkSurfaceElevated = Color(hex: "3A3A3C")
    
    // Heart Rate / Stress Colors
    static let zenHeartLow = Color(hex: "7BA3C9") // Calm - blue
    static let zenHeartMedium = Color(hex: "5B8A72") // Normal - green
    static let zenHeartElevated = Color(hex: "E8985E") // Elevated - orange
    static let zenHeartHigh = Color(hex: "D4726A") // High - coral
    
    // Initialize from hex string
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
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Typography
struct ZenFont {
    // Display - For large timer numbers
    static func display(_ size: CGFloat = 72) -> Font {
        .system(size: size, weight: .light, design: .rounded)
    }
    
    // Title - Section headers
    static func title(_ size: CGFloat = 28) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
    
    // Headline - Card titles
    static func headline(_ size: CGFloat = 20) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }
    
    // Body - Regular text
    static func body(_ size: CGFloat = 17) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }
    
    // Caption - Secondary information
    static func caption(_ size: CGFloat = 14) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }
    
    // Label - Buttons and small text
    static func label(_ size: CGFloat = 15) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }
    
    // Mono - For statistics
    static func mono(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }
}

// MARK: - Spacing
struct ZenSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

// MARK: - Corner Radius
struct ZenRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let full: CGFloat = 100
}

// MARK: - Shadows
extension View {
    func zenShadow(style: ZenShadowStyle = .medium) -> some View {
        self.shadow(
            color: Color.black.opacity(style.opacity),
            radius: style.radius,
            x: 0,
            y: style.y
        )
    }
}

enum ZenShadowStyle {
    case soft
    case medium
    case elevated
    
    var opacity: Double {
        switch self {
        case .soft: return 0.05
        case .medium: return 0.1
        case .elevated: return 0.15
        }
    }
    
    var radius: CGFloat {
        switch self {
        case .soft: return 8
        case .medium: return 16
        case .elevated: return 24
        }
    }
    
    var y: CGFloat {
        switch self {
        case .soft: return 2
        case .medium: return 4
        case .elevated: return 8
        }
    }
}

// MARK: - Gradients
struct ZenGradients {
    static let warmBackground = LinearGradient(
        colors: [Color(hex: "FBF9F7"), Color(hex: "F5F1EC")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let darkBackground = LinearGradient(
        colors: [Color(hex: "1C1C1E"), Color(hex: "141414")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let focusRing = LinearGradient(
        colors: [Color.zenFocus, Color.zenFocus.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let breakRing = LinearGradient(
        colors: [Color.zenBreak, Color.zenBreak.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let restRing = LinearGradient(
        colors: [Color.zenRest, Color.zenRest.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cardGlow = RadialGradient(
        colors: [Color.white.opacity(0.1), Color.clear],
        center: .topLeading,
        startRadius: 0,
        endRadius: 200
    )
}

// MARK: - Haptic Feedback
struct ZenHaptics {
    static func light() {
        let impactLight = UIImpactFeedbackGenerator(style: .light)
        impactLight.impactOccurred()
    }
    
    static func medium() {
        let impactMedium = UIImpactFeedbackGenerator(style: .medium)
        impactMedium.impactOccurred()
    }
    
    static func success() {
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
    }
    
    static func warning() {
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.warning)
    }
    
    static func selection() {
        let selection = UISelectionFeedbackGenerator()
        selection.selectionChanged()
    }
}

// MARK: - Animation Presets
extension Animation {
    static let zenSpring = Animation.spring(response: 0.4, dampingFraction: 0.75, blendDuration: 0)
    static let zenSmooth = Animation.easeInOut(duration: 0.3)
    static let zenSlow = Animation.easeInOut(duration: 0.5)
    static let zenBounce = Animation.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0)
}

// MARK: - View Modifiers
struct ZenCardStyle: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: ZenRadius.lg)
                    .fill(colorScheme == .dark ? Color.zenDarkSurface : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: ZenRadius.lg)
                            .fill(ZenGradients.cardGlow)
                    )
            )
            .zenShadow(style: .medium)
    }
}

extension View {
    func zenCard() -> some View {
        modifier(ZenCardStyle())
    }
}

// MARK: - Button Styles
struct ZenPrimaryButtonStyle: ButtonStyle {
    let color: Color
    
    init(color: Color = .zenFocus) {
        self.color = color
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ZenFont.label(17))
            .foregroundColor(.white)
            .padding(.horizontal, ZenSpacing.lg)
            .padding(.vertical, ZenSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: ZenRadius.full)
                    .fill(color)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.zenSpring, value: configuration.isPressed)
    }
}

struct ZenSecondaryButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ZenFont.label(17))
            .foregroundColor(colorScheme == .dark ? .white : .zenTextPrimary)
            .padding(.horizontal, ZenSpacing.lg)
            .padding(.vertical, ZenSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: ZenRadius.full)
                    .fill(colorScheme == .dark ? Color.zenDarkSurfaceElevated : Color.white)
            )
            .zenShadow(style: .soft)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.zenSpring, value: configuration.isPressed)
    }
}

struct ZenIconButtonStyle: ButtonStyle {
    let size: CGFloat
    
    init(size: CGFloat = 44) {
        self.size = size
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(Color.white.opacity(0.1))
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.zenSpring, value: configuration.isPressed)
    }
}
