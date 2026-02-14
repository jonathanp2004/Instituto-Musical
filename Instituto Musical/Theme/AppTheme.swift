//
//  AppTheme.swift
//  Instituto Musical
//
//  Centralized design tokens: colors, fonts, spacing, and reusable styles.
//

import SwiftUI

// MARK: - Colors

extension Color {
    // Primary palette
    static let imPrimary = Color(hex: "4A90D9")       // Vibrant blue
    static let imSecondary = Color(hex: "7B61FF")      // Purple accent
    static let imAccent = Color(hex: "FF6B6B")         // Coral/red for alerts

    // Region colors
    static let regionEcho = Color(hex: "5DADE2")       // Region 1: Light blue
    static let regionForest = Color(hex: "2ECC71")     // Region 2: Green
    static let regionRhythm = Color(hex: "F39C12")     // Region 3: Orange/gold
    static let regionMaster = Color(hex: "9B59B6")     // Region 4: Purple

    // Feedback
    static let imCorrect = Color(hex: "27AE60")
    static let imWrong = Color(hex: "E74C3C")
    static let imWarning = Color(hex: "F1C40F")

    // Mastery levels
    static let masteryNovice = Color(hex: "E74C3C")
    static let masteryPractitioner = Color(hex: "F1C40F")
    static let masterySkilled = Color(hex: "3498DB")
    static let masteryMaster = Color(hex: "F39C12")

    // Piano
    static let pianoWhiteKey = Color(hex: "FAFAFA")
    static let pianoBlackKey = Color(hex: "1A1A2E")
    static let pianoHighlight = Color(hex: "4A90D9").opacity(0.4)
    static let pianoPressed = Color(hex: "4A90D9").opacity(0.7)

    // Backgrounds
    static let imBackground = Color(hex: "0F0F23")     // Dark navy
    static let imSurface = Color(hex: "1A1A3E")        // Slightly lighter surface
    static let imCard = Color(hex: "252550")            // Card background

    // Text
    static let imTextPrimary = Color.white
    static let imTextSecondary = Color.white.opacity(0.7)
    static let imTextMuted = Color.white.opacity(0.4)
}

// MARK: - Hex Color Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
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

// MARK: - Fonts

extension Font {
    static let imTitle = Font.system(size: 28, weight: .bold, design: .rounded)
    static let imHeadline = Font.system(size: 22, weight: .bold, design: .rounded)
    static let imSubheadline = Font.system(size: 18, weight: .semibold, design: .rounded)
    static let imBody = Font.system(size: 16, weight: .regular, design: .rounded)
    static let imCaption = Font.system(size: 13, weight: .medium, design: .rounded)
    static let imLargeNumber = Font.system(size: 48, weight: .heavy, design: .rounded)
    static let imGamePrompt = Font.system(size: 24, weight: .bold, design: .rounded)
}

// MARK: - Reusable View Modifiers

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.imCard)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var color: Color = .imPrimary

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.imSubheadline)
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.imSubheadline)
            .foregroundStyle(.imPrimary)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(Color.imPrimary.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

// MARK: - Star Rating View

struct StarRatingView: View {
    let stars: Int // 0-3
    let maxStars: Int = 3
    var size: CGFloat = 24

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<maxStars, id: \.self) { index in
                Image(systemName: index < stars ? "star.fill" : "star")
                    .font(.system(size: size))
                    .foregroundStyle(index < stars ? Color.imWarning : Color.imTextMuted)
            }
        }
    }
}

// MARK: - XP Badge View

struct XPBadge: View {
    let amount: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "sparkles")
                .font(.caption)
            Text("+\(amount) XP")
                .font(.imCaption)
        }
        .foregroundStyle(.imWarning)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Color.imWarning.opacity(0.15))
        .clipShape(Capsule())
    }
}

// MARK: - Mastery Bar

struct MasteryBar: View {
    let score: Double // 0.0–1.0
    let label: String

    var barColor: Color {
        switch score {
        case 0.0..<0.4: return .masteryNovice
        case 0.4..<0.7: return .masteryPractitioner
        case 0.7..<0.9: return .masterySkilled
        default: return .masteryMaster
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.imCaption)
                    .foregroundStyle(.imTextSecondary)
                Spacer()
                Text("\(Int(score * 100))%")
                    .font(.imCaption)
                    .foregroundStyle(.imTextPrimary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(barColor)
                        .frame(width: geo.size.width * score)
                }
            }
            .frame(height: 8)
        }
    }
}
