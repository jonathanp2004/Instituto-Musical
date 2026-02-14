//
//  PianoKeyboardView.swift
//  Instituto Musical
//
//  Reusable 1–2 octave interactive piano keyboard.
//  Supports: tap callbacks, key highlighting, labels, and pressed state.
//

import SwiftUI

struct PianoKeyboardView: View {
    let startOctave: Int
    let octaveCount: Int
    var onKeyTapped: ((NoteName, Int) -> Void)? = nil
    var highlightedKeys: Set<NoteName> = []
    var showLabels: Bool = true
    var labelLanguage: String = "es"  // "en" or "es"

    // Layout constants
    private let whiteKeyWidth: CGFloat = 44
    private let whiteKeyHeight: CGFloat = 160
    private let blackKeyWidth: CGFloat = 28
    private let blackKeyHeight: CGFloat = 100

    private let whiteNotes: [NoteName] = [.C, .D, .E, .F, .G, .A, .B]

    var body: some View {
        GeometryReader { geo in
            let totalWhiteKeys = octaveCount * 7
            let calculatedWhiteWidth = geo.size.width / CGFloat(totalWhiteKeys)
            let keyWidth = min(calculatedWhiteWidth, whiteKeyWidth)
            let keyHeight = min(geo.size.height, whiteKeyHeight)
            let bKeyWidth = keyWidth * 0.65
            let bKeyHeight = keyHeight * 0.62

            ZStack(alignment: .topLeading) {
                // White keys
                HStack(spacing: 1) {
                    ForEach(0..<octaveCount, id: \.self) { octaveOffset in
                        let octave = startOctave + octaveOffset
                        ForEach(whiteNotes, id: \.self) { note in
                            WhiteKeyView(
                                note: note,
                                octave: octave,
                                width: keyWidth - 1,
                                height: keyHeight,
                                isHighlighted: highlightedKeys.contains(note),
                                showLabel: showLabels,
                                labelLanguage: labelLanguage,
                                onTap: { onKeyTapped?(note, octave) }
                            )
                        }
                    }
                }

                // Black keys (overlaid)
                HStack(spacing: 0) {
                    ForEach(0..<octaveCount, id: \.self) { octaveOffset in
                        let octave = startOctave + octaveOffset
                        let baseOffset = CGFloat(octaveOffset * 7)

                        // C#
                        BlackKeyView(note: .CSharp, octave: octave, width: bKeyWidth, height: bKeyHeight,
                                     isHighlighted: highlightedKeys.contains(.CSharp),
                                     onTap: { onKeyTapped?(.CSharp, octave) })
                            .offset(x: (baseOffset + 1) * keyWidth - bKeyWidth / 2)

                        // D#
                        BlackKeyView(note: .DSharp, octave: octave, width: bKeyWidth, height: bKeyHeight,
                                     isHighlighted: highlightedKeys.contains(.DSharp),
                                     onTap: { onKeyTapped?(.DSharp, octave) })
                            .offset(x: (baseOffset + 2) * keyWidth - bKeyWidth / 2)

                        // F#
                        BlackKeyView(note: .FSharp, octave: octave, width: bKeyWidth, height: bKeyHeight,
                                     isHighlighted: highlightedKeys.contains(.FSharp),
                                     onTap: { onKeyTapped?(.FSharp, octave) })
                            .offset(x: (baseOffset + 4) * keyWidth - bKeyWidth / 2)

                        // G#
                        BlackKeyView(note: .GSharp, octave: octave, width: bKeyWidth, height: bKeyHeight,
                                     isHighlighted: highlightedKeys.contains(.GSharp),
                                     onTap: { onKeyTapped?(.GSharp, octave) })
                            .offset(x: (baseOffset + 5) * keyWidth - bKeyWidth / 2)

                        // A#
                        BlackKeyView(note: .ASharp, octave: octave, width: bKeyWidth, height: bKeyHeight,
                                     isHighlighted: highlightedKeys.contains(.ASharp),
                                     onTap: { onKeyTapped?(.ASharp, octave) })
                            .offset(x: (baseOffset + 6) * keyWidth - bKeyWidth / 2)
                    }
                }
            }
            .frame(width: CGFloat(totalWhiteKeys) * keyWidth, height: keyHeight)
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - White Key

struct WhiteKeyView: View {
    let note: NoteName
    let octave: Int
    let width: CGFloat
    let height: CGFloat
    let isHighlighted: Bool
    let showLabel: Bool
    let labelLanguage: String
    let onTap: () -> Void

    @State private var isPressed = false

    var label: String {
        labelLanguage == "es" ? note.spanishName : note.englishName
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 4)
                .fill(keyColor)
                .shadow(color: .black.opacity(0.2), radius: 2, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                )

            if showLabel {
                Text(label)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(isHighlighted ? .white : .gray)
                    .padding(.bottom, 8)
            }
        }
        .frame(width: width, height: height)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.1)) { isPressed = true }
            onTap()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeOut(duration: 0.1)) { isPressed = false }
            }
        }
    }

    private var keyColor: Color {
        if isPressed { return .pianoPressed }
        if isHighlighted { return .pianoHighlight }
        return .pianoWhiteKey
    }
}

// MARK: - Black Key

struct BlackKeyView: View {
    let note: NoteName
    let octave: Int
    let width: CGFloat
    let height: CGFloat
    let isHighlighted: Bool
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(keyColor)
            .frame(width: width, height: height)
            .shadow(color: .black.opacity(0.4), radius: 3, y: 3)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .zIndex(1)  // above white keys
            .onTapGesture {
                withAnimation(.easeOut(duration: 0.1)) { isPressed = true }
                onTap()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.easeOut(duration: 0.1)) { isPressed = false }
                }
            }
    }

    private var keyColor: Color {
        if isPressed { return Color(hex: "4A90D9") }
        if isHighlighted { return Color(hex: "6B48FF") }
        return .pianoBlackKey
    }
}
