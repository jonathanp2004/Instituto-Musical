//
//  WorldMapView.swift
//  Instituto Musical
//
//  Scrollable world map showing all 4 regions with land nodes.
//  Locked lands are grayed out; completed lands show stars.
//

import SwiftUI
import SwiftData

struct WorldMapView: View {
    let coordinator: AppCoordinator
    @Query private var profiles: [UserProfile]
    @Query(sort: \TopicProgress.adventureNumber) private var allProgress: [TopicProgress]

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        ZStack {
            Color.imBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Player header
                    if let profile = profile {
                        PlayerHeaderView(profile: profile)
                            .padding(.horizontal)
                            .padding(.top, 8)
                    }

                    // Regions (reversed so Region 4 is at top = "summit")
                    ForEach((1...4).reversed(), id: \.self) { regionIndex in
                        RegionSectionView(
                            regionIndex: regionIndex,
                            lands: LandData.lands(for: regionIndex),
                            progressMap: progressMap,
                            coordinator: coordinator
                        )
                    }

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle("Mundo Sonoro")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.imBackground, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    /// Map topicID → TopicProgress for quick lookup
    private var progressMap: [String: TopicProgress] {
        Dictionary(uniqueKeysWithValues: allProgress.map { ($0.topicID, $0) })
    }
}

// MARK: - Player Header

struct PlayerHeaderView: View {
    let profile: UserProfile

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.imPrimary.opacity(0.2))
                    .frame(width: 50, height: 50)
                Image(systemName: profile.avatarBase)
                    .font(.title2)
                    .foregroundStyle(.imPrimary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(profile.displayName)
                    .font(.imSubheadline)
                    .foregroundStyle(.imTextPrimary)

                HStack(spacing: 8) {
                    // Level
                    Text("Lvl \(profile.currentLevel)")
                        .font(.imCaption)
                        .foregroundStyle(.imSecondary)

                    // XP progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.white.opacity(0.1))
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.imSecondary)
                                .frame(width: geo.size.width * profile.levelProgress)
                        }
                    }
                    .frame(height: 6)

                    Text("\(profile.xpInCurrentLevel)/\(profile.xpForNextLevel)")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(.imTextMuted)
                }
            }

            Spacer()

            // Streak
            VStack(spacing: 2) {
                Image(systemName: profile.isStreakActive ? "flame.fill" : "flame")
                    .foregroundStyle(profile.isStreakActive ? .orange : .imTextMuted)
                Text("\(profile.currentStreak)")
                    .font(.imCaption)
                    .foregroundStyle(.imTextPrimary)
            }
        }
        .padding()
        .background(Color.imSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Region Section

struct RegionSectionView: View {
    let regionIndex: Int
    let lands: [Land]
    let progressMap: [String: TopicProgress]
    let coordinator: AppCoordinator

    var regionInfo: (en: String, es: String, color: Color) {
        LandData.regionNames[regionIndex - 1]
    }

    var body: some View {
        VStack(spacing: 16) {
            // Region header
            HStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(regionInfo.color)
                    .frame(width: 4, height: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Región \(regionIndex)")
                        .font(.imCaption)
                        .foregroundStyle(regionInfo.color)
                    Text(regionInfo.es)
                        .font(.imSubheadline)
                        .foregroundStyle(.imTextPrimary)
                }
                Spacer()
            }
            .padding(.horizontal)

            // Land nodes
            ForEach(lands) { land in
                let progress = progressMap[land.topicID]
                let isUnlocked = isLandUnlocked(land)

                Button {
                    if isUnlocked {
                        coordinator.navigateToLand(land)
                    }
                } label: {
                    LandNodeView(
                        land: land,
                        progress: progress,
                        isUnlocked: isUnlocked
                    )
                }
                .disabled(!isUnlocked)
            }
        }
        .padding(.vertical, 16)
    }

    private func isLandUnlocked(_ land: Land) -> Bool {
        guard let prereq = land.prerequisite else { return true }
        let prereqTopicID = "adventure_\(prereq)"
        return progressMap[prereqTopicID]?.bossDefeated ?? false
    }
}

// MARK: - Land Node

struct LandNodeView: View {
    let land: Land
    let progress: TopicProgress?
    let isUnlocked: Bool

    var body: some View {
        HStack(spacing: 16) {
            // Icon circle
            ZStack {
                Circle()
                    .fill(isUnlocked ? land.regionColor.opacity(0.2) : Color.imCard)
                    .frame(width: 56, height: 56)

                if isUnlocked {
                    Image(systemName: land.icon)
                        .font(.title2)
                        .foregroundStyle(land.regionColor)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.title3)
                        .foregroundStyle(.imTextMuted)
                }

                // Boss defeated checkmark
                if progress?.bossDefeated == true {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.imCorrect)
                        .offset(x: 20, y: -20)
                }
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(land.nameES)
                    .font(.imBody)
                    .fontWeight(.semibold)
                    .foregroundStyle(isUnlocked ? .imTextPrimary : .imTextMuted)

                if isUnlocked {
                    if let progress = progress, progress.bossDefeated {
                        StarRatingView(stars: progress.starsEarned, size: 14)
                    } else if let progress = progress, progress.totalAttempts > 0 {
                        MasteryBar(score: progress.masteryScore, label: progress.masteryLevel.spanishName)
                            .frame(height: 24)
                    } else {
                        Text("Nuevo")
                            .font(.imCaption)
                            .foregroundStyle(land.regionColor)
                    }
                } else {
                    Text("Derrota al jefe anterior para desbloquear")
                        .font(.system(size: 11))
                        .foregroundStyle(.imTextMuted)
                }
            }

            Spacer()

            if isUnlocked {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.imTextMuted)
            }
        }
        .padding()
        .background(isUnlocked ? Color.imSurface : Color.imCard.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal)
    }
}
