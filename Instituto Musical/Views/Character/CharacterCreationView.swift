//
//  CharacterCreationView.swift
//  Instituto Musical
//
//  Character creation: name input, avatar selection, language preference.
//

import SwiftUI
import SwiftData

struct CharacterCreationView: View {
    let coordinator: AppCoordinator
    @Environment(\.modelContext) private var modelContext

    @State private var displayName = ""
    @State private var selectedAvatar = 0
    @State private var selectedLanguage = "es"

    private let avatars = [
        ("figure.stand", "Avatar 1"),
        ("figure.wave", "Avatar 2"),
        ("figure.run", "Avatar 3"),
        ("figure.dance", "Avatar 4"),
        ("figure.martial.arts", "Avatar 5"),
        ("figure.cooldown", "Avatar 6")
    ]

    var body: some View {
        ZStack {
            Color.imBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Crea Tu Personaje")
                            .font(.imTitle)
                            .foregroundStyle(.imTextPrimary)
                        Text("Create Your Character")
                            .font(.imCaption)
                            .foregroundStyle(.imTextMuted)
                    }
                    .padding(.top, 40)

                    // Avatar Selection
                    VStack(spacing: 12) {
                        // Selected avatar large preview
                        ZStack {
                            Circle()
                                .fill(Color.imPrimary.opacity(0.2))
                                .frame(width: 120, height: 120)
                            Image(systemName: avatars[selectedAvatar].0)
                                .font(.system(size: 50))
                                .foregroundStyle(.imPrimary)
                        }

                        // Avatar grid
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                            ForEach(0..<avatars.count, id: \.self) { index in
                                Button {
                                    withAnimation { selectedAvatar = index }
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(index == selectedAvatar ? Color.imPrimary.opacity(0.3) : Color.imCard)
                                            .frame(width: 70, height: 70)
                                            .overlay(
                                                Circle()
                                                    .stroke(index == selectedAvatar ? Color.imPrimary : Color.clear, lineWidth: 3)
                                            )
                                        Image(systemName: avatars[index].0)
                                            .font(.system(size: 28))
                                            .foregroundStyle(index == selectedAvatar ? .imPrimary : .imTextSecondary)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Name Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tu Nombre / Your Name")
                            .font(.imCaption)
                            .foregroundStyle(.imTextSecondary)

                        TextField("", text: $displayName, prompt: Text("Escribe tu nombre...").foregroundStyle(.imTextMuted))
                            .font(.imBody)
                            .foregroundStyle(.imTextPrimary)
                            .padding()
                            .background(Color.imCard)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.imPrimary.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 24)

                    // Language Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Idioma / Language")
                            .font(.imCaption)
                            .foregroundStyle(.imTextSecondary)

                        HStack(spacing: 12) {
                            LanguageButton(label: "Español", code: "es", selected: $selectedLanguage)
                            LanguageButton(label: "English", code: "en", selected: $selectedLanguage)
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 20)

                    // Create Button
                    Button {
                        createProfile()
                    } label: {
                        Text("¡Crear Personaje!")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(displayName.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(displayName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
            }
        }
    }

    private func createProfile() {
        let profile = UserProfile(
            displayName: displayName.trimmingCharacters(in: .whitespaces),
            avatarBase: avatars[selectedAvatar].0,
            preferredLanguage: selectedLanguage
        )
        modelContext.insert(profile)

        // Create initial TopicProgress for all 16 adventures
        for land in LandData.allLands {
            let progress = TopicProgress(topicID: land.topicID, adventureNumber: land.number)
            modelContext.insert(progress)
        }

        try? modelContext.save()
        coordinator.completeCharacterCreation()
    }
}

// MARK: - Language Button

struct LanguageButton: View {
    let label: String
    let code: String
    @Binding var selected: String

    var body: some View {
        Button {
            withAnimation { selected = code }
        } label: {
            Text(label)
                .font(.imBody)
                .foregroundStyle(selected == code ? .white : .imTextSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(selected == code ? Color.imPrimary : Color.imCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(selected == code ? Color.imPrimary : Color.imTextMuted.opacity(0.3), lineWidth: 1)
                )
        }
    }
}
