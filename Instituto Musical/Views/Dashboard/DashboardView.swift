//
//  DashboardView.swift
//  Instituto Musical
//
//  Progress dashboard: overall stats, per-topic mastery bars, streak, weak areas.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var profiles: [UserProfile]
    @Query(sort: \TopicProgress.adventureNumber) private var allProgress: [TopicProgress]

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.imBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Level & XP card
                        if let profile = profile {
                            VStack(spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(profile.title)
                                            .font(.imCaption)
                                            .foregroundStyle(.imSecondary)
                                        Text("Nivel \(profile.currentLevel)")
                                            .font(.imTitle)
                                            .foregroundStyle(.imTextPrimary)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text("XP Total")
                                            .font(.imCaption)
                                            .foregroundStyle(.imTextMuted)
                                        Text("\(profile.totalXP)")
                                            .font(.imHeadline)
                                            .foregroundStyle(.imWarning)
                                    }
                                }

                                // XP bar
                                VStack(spacing: 4) {
                                    GeometryReader { geo in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color.white.opacity(0.1))
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color.imSecondary)
                                                .frame(width: geo.size.width * profile.levelProgress)
                                        }
                                    }
                                    .frame(height: 12)

                                    Text("\(profile.xpInCurrentLevel) / \(profile.xpForNextLevel) XP")
                                        .font(.imCaption)
                                        .foregroundStyle(.imTextMuted)
                                }

                                // Streak
                                HStack {
                                    Image(systemName: "flame.fill")
                                        .foregroundStyle(.orange)
                                    Text("Racha: \(profile.currentStreak) días")
                                        .font(.imBody)
                                        .foregroundStyle(.imTextPrimary)
                                    Spacer()
                                    Text("Máxima: \(profile.longestStreak)")
                                        .font(.imCaption)
                                        .foregroundStyle(.imTextMuted)
                                }
                            }
                            .cardStyle()
                            .padding(.horizontal)
                        }

                        // Weak Areas
                        let weakAreas = allProgress.filter { $0.isWeakArea }
                        if !weakAreas.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(.imWarning)
                                    Text("Áreas a Mejorar")
                                        .font(.imSubheadline)
                                        .foregroundStyle(.imTextPrimary)
                                }
                                ForEach(weakAreas, id: \.id) { progress in
                                    if let land = LandData.land(number: progress.adventureNumber) {
                                        MasteryBar(score: progress.masteryScore, label: land.nameES)
                                    }
                                }
                            }
                            .cardStyle()
                            .padding(.horizontal)
                        }

                        // All Topics Mastery
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Dominio por Tema")
                                .font(.imSubheadline)
                                .foregroundStyle(.imTextPrimary)

                            ForEach(allProgress, id: \.id) { progress in
                                if progress.totalAttempts > 0, let land = LandData.land(number: progress.adventureNumber) {
                                    MasteryBar(score: progress.masteryScore, label: land.nameES)
                                }
                            }

                            if allProgress.filter({ $0.totalAttempts > 0 }).isEmpty {
                                Text("¡Completa tu primera aventura para ver tu progreso!")
                                    .font(.imBody)
                                    .foregroundStyle(.imTextMuted)
                                    .padding(.vertical, 20)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .cardStyle()
                        .padding(.horizontal)

                        Spacer(minLength: 40)
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Progreso")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.imBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}
