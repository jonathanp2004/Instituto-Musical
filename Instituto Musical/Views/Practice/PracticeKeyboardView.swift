//
//  PracticeKeyboardView.swift
//  Instituto Musical
//
//  Free-play piano keyboard for practice. Shows note name when played.
//

import SwiftUI

struct PracticeKeyboardView: View {
    @State private var lastPlayedNote: NoteName?
    @State private var lastOctave: Int = 4
    private let audio = AudioService.shared

    var body: some View {
        NavigationStack {
            ZStack {
                Color.imBackground.ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()

                    // Note display
                    VStack(spacing: 8) {
                        if let note = lastPlayedNote {
                            Text(note.spanishName)
                                .font(.system(size: 64, weight: .heavy, design: .rounded))
                                .foregroundStyle(.imPrimary)
                                .transition(.scale)

                            Text(note.englishName)
                                .font(.imSubheadline)
                                .foregroundStyle(.imTextMuted)

                            if note.isBlackKey {
                                Text("(\(note.spanishFlat) / \(note.englishFlat))")
                                    .font(.imCaption)
                                    .foregroundStyle(.imTextMuted)
                            }
                        } else {
                            Text("🎹")
                                .font(.system(size: 60))
                            Text("Toca una tecla")
                                .font(.imBody)
                                .foregroundStyle(.imTextMuted)
                        }
                    }
                    .animation(.spring(response: 0.2), value: lastPlayedNote)

                    Spacer()

                    // Keyboard
                    PianoKeyboardView(
                        startOctave: 3,
                        octaveCount: 2,
                        onKeyTapped: { note, octave in
                            lastPlayedNote = note
                            lastOctave = octave
                            audio.playNote(note, octave: octave, duration: 1.5)
                        },
                        showLabels: true,
                        labelLanguage: "es"
                    )
                    .frame(height: 200)
                    .padding(.bottom, 8)
                }
            }
            .navigationTitle("Practica Libre")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.imBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .onAppear { audio.setup() }
    }
}
