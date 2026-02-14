//
//  LandDetailView.swift
//  Instituto Musical
//
//  Detail screen for a land: story intro, learning objectives, mini-game list, boss challenge.
//

import SwiftUI
import SwiftData

struct LandDetailView: View {
    let land: Land
    let coordinator: AppCoordinator

    @Query private var allProgress: [TopicProgress]

    private var progress: TopicProgress? {
        allProgress.first { $0.topicID == land.topicID }
    }

    var body: some View {
        ZStack {
            Color.imBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Header
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(land.regionColor.opacity(0.2))
                                .frame(width: 80, height: 80)
                            Image(systemName: land.icon)
                                .font(.system(size: 36))
                                .foregroundStyle(land.regionColor)
                        }

                        Text(land.nameES)
                            .font(.imTitle)
                            .foregroundStyle(.imTextPrimary)

                        if let progress = progress, progress.bossDefeated {
                            StarRatingView(stars: progress.starsEarned)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)

                    // Story
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: "Historia")
                        Text(land.storyES)
                            .font(.imBody)
                            .foregroundStyle(.imTextSecondary)
                    }
                    .padding(.horizontal)

                    // Learning Objectives
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: "Objetivos")
                        ForEach(land.objectivesES, id: \.self) { objective in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark.circle")
                                    .font(.caption)
                                    .foregroundStyle(land.regionColor)
                                    .padding(.top, 2)
                                Text(objective)
                                    .font(.imBody)
                                    .foregroundStyle(.imTextSecondary)
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Mini-Games
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Mini-Juegos")

                        ForEach(land.miniGameIDs, id: \.self) { gameID in
                            Button {
                                coordinator.navigateToMiniGame(gameID)
                            } label: {
                                HStack {
                                    Image(systemName: "gamecontroller.fill")
                                        .foregroundStyle(land.regionColor)
                                    Text(gameDisplayName(gameID))
                                        .font(.imBody)
                                        .foregroundStyle(.imTextPrimary)
                                    Spacer()
                                    Image(systemName: "play.fill")
                                        .foregroundStyle(land.regionColor)
                                }
                                .padding()
                                .background(Color.imSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Boss Challenge
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Jefe Final")

                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "shield.fill")
                                    .font(.title2)
                                    .foregroundStyle(.imAccent)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(land.bossNameES)
                                        .font(.imSubheadline)
                                        .foregroundStyle(.imTextPrimary)
                                    Text("\(land.bossQuestionCount) preguntas • \(Int(land.bossPassingScore * 100))% para pasar")
                                        .font(.imCaption)
                                        .foregroundStyle(.imTextSecondary)
                                }
                                Spacer()
                                XPBadge(amount: land.bossXP)
                            }

                            if let progress = progress, progress.bossDefeated {
                                HStack {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundStyle(.imCorrect)
                                    Text("¡Derrotado! Puntuación: \(progress.bossHighScore)%")
                                        .font(.imCaption)
                                        .foregroundStyle(.imCorrect)
                                }
                            }

                            Button {
                                // TODO: Navigate to boss battle
                                coordinator.navigateToMiniGame("boss_\(land.id)")
                            } label: {
                                Text(progress?.bossDefeated == true ? "Reintentar Jefe" : "¡Enfrentar al Jefe!")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PrimaryButtonStyle(color: .imAccent))
                        }
                        .padding()
                        .background(Color.imSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.imBackground, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    // MARK: - Helpers

    private func gameDisplayName(_ id: String) -> String {
        let names: [String: String] = [
            "key_hunter": "Key Hunter / Cazador de Teclas",
            "note_sorter": "Note Sorter / Clasificador de Notas",
            "step_bridge": "Step Bridge / Puente de Pasos",
            "crystal_counter": "Crystal Counter / Contador de Cristales",
            "twin_flowers": "Twin Flowers / Flores Gemelas",
            "chromatic_path": "Chromatic Path / Camino Cromático",
            "note_calculator": "Note Calculator / Calculadora de Notas",
            "assembly_line": "Assembly Line / Línea de Ensamblaje",
            "trail_builder": "Trail Builder / Constructor de Senderos",
            "scale_detective": "Scale Detective / Detective de Escalas",
            "shadow_scale": "Shadow Scale / Escala Sombra",
            "major_or_minor": "Major or Minor? / ¿Mayor o Menor?",
            "tower_climb": "Tower Climb / Escalar la Torre",
            "circle_spinner": "Circle Spinner / Ruleta del Círculo",
            "interval_greenhouse": "Interval Greenhouse / Invernadero",
            "ear_garden": "Ear Garden / Jardín Auditivo",
            "tempo_match": "Tempo Match / Emparejar Tempo",
            "bpm_tapper": "BPM Tapper / Toca el BPM",
            "rhythm_assembly": "Rhythm Assembly / Ensamblaje Rítmico",
            "note_value_quiz": "Note Value Quiz / Quiz de Valores",
            "clock_face": "Clock Face / Carátula del Reloj",
            "measure_fill": "Measure Fill / Llenar Compás",
            "rhythm_hero": "Rhythm Hero / Héroe del Ritmo",
            "error_spotter": "Error Spotter / Buscador de Errores",
            "chord_forge": "Chord Forge / Forja de Acordes",
            "chord_ear_id": "Chord Ear ID / ID Auditiva de Acordes",
            "crystal_chord": "Crystal Chord / Acorde de Cristal",
            "major_or_minor_chord": "Major or Minor Chord? / ¿Acorde Mayor o Menor?",
            "bridge_builder": "Bridge Builder / Constructor de Puentes",
            "progression_ear": "Progression Ear / Oído de Progresiones",
            "gauntlet": "The Gauntlet / El Guantelete",
            "composition_chamber": "Composition Chamber / Cámara de Composición"
        ]
        return names[id] ?? id.replacingOccurrences(of: "_", with: " ").capitalized
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.imSubheadline)
            .foregroundStyle(.imTextPrimary)
    }
}
