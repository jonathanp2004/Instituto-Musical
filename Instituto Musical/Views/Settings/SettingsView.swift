//
//  SettingsView.swift
//  Instituto Musical
//
//  Settings: language, sound, daily reminder, reset progress.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query private var profiles: [UserProfile]
    @Environment(\.modelContext) private var modelContext

    private var profile: UserProfile? { profiles.first }

    @State private var showResetAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.imBackground.ignoresSafeArea()

                List {
                    // Language
                    Section {
                        if let profile = profile {
                            Picker("Idioma / Language", selection: Binding(
                                get: { profile.preferredLanguage },
                                set: { profile.preferredLanguage = $0; try? modelContext.save() }
                            )) {
                                Text("Español").tag("es")
                                Text("English").tag("en")
                            }
                        }
                    } header: {
                        Text("Idioma")
                    }

                    // Sound
                    Section {
                        if let profile = profile {
                            Toggle("Sonido", isOn: Binding(
                                get: { profile.soundEnabled },
                                set: {
                                    profile.soundEnabled = $0
                                    AudioService.shared.isMuted = !$0
                                    try? modelContext.save()
                                }
                            ))
                        }
                    } header: {
                        Text("Audio")
                    }

                    // Notifications
                    Section {
                        if let profile = profile {
                            DatePicker(
                                "Recordatorio Diario",
                                selection: Binding(
                                    get: {
                                        Calendar.current.date(
                                            from: DateComponents(hour: profile.reminderHour, minute: profile.reminderMinute)
                                        ) ?? Date()
                                    },
                                    set: { date in
                                        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
                                        profile.reminderHour = components.hour ?? 17
                                        profile.reminderMinute = components.minute ?? 0
                                        try? modelContext.save()
                                    }
                                ),
                                displayedComponents: .hourAndMinute
                            )
                        }
                    } header: {
                        Text("Notificaciones")
                    }

                    // About
                    Section {
                        HStack {
                            Text("Versión")
                            Spacer()
                            Text("1.0.0")
                                .foregroundStyle(.secondary)
                        }
                        HStack {
                            Text("Desarrollador")
                            Spacer()
                            Text("Jonathan Padilla")
                                .foregroundStyle(.secondary)
                        }
                    } header: {
                        Text("Acerca de")
                    }

                    // Danger zone
                    Section {
                        Button("Reiniciar Progreso", role: .destructive) {
                            showResetAlert = true
                        }
                    } header: {
                        Text("Zona de Peligro")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Ajustes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.imBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("¿Reiniciar todo el progreso?", isPresented: $showResetAlert) {
                Button("Cancelar", role: .cancel) {}
                Button("Reiniciar", role: .destructive) {
                    resetProgress()
                }
            } message: {
                Text("Esto borrará todo tu XP, nivel, racha y progreso en las aventuras. No se puede deshacer.")
            }
        }
    }

    private func resetProgress() {
        if let profile = profile {
            profile.totalXP = 0
            profile.currentLevel = 1
            profile.currentStreak = 0
        }
        // Reset all topic progress
        let descriptor = FetchDescriptor<TopicProgress>()
        if let allProgress = try? modelContext.fetch(descriptor) {
            for progress in allProgress {
                modelContext.delete(progress)
            }
        }
        // Recreate fresh progress
        for land in LandData.allLands {
            modelContext.insert(TopicProgress(topicID: land.topicID, adventureNumber: land.number))
        }
        try? modelContext.save()
    }
}
