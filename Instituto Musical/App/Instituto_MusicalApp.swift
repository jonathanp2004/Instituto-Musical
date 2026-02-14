//
//  Instituto_MusicalApp.swift
//  Instituto Musical
//
//  Created by Jonathan Padilla on 2/13/26.
//
//  Updated: SwiftData replaces CoreData. AppCoordinator manages navigation.
//

import SwiftUI
import SwiftData

@main
struct Instituto_MusicalApp: App {

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [
            UserProfile.self,
            TopicProgress.self,
            InventoryItem.self
        ])
    }
}

// MARK: - Root View

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    @State private var coordinator = AppCoordinator()
    @State private var audioService = AudioService.shared

    var body: some View {
        Group {
            switch coordinator.appState {
            case .loading:
                // Brief loading screen
                ZStack {
                    Color.imBackground.ignoresSafeArea()
                    VStack(spacing: 16) {
                        Image(systemName: "music.note.house.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.imPrimary)
                        Text("Instituto Musical")
                            .font(.imTitle)
                            .foregroundStyle(.imTextPrimary)
                    }
                }
                .onAppear {
                    audioService.setup()
                    coordinator.determineInitialState(hasProfile: !profiles.isEmpty)
                }

            case .onboarding:
                OnboardingView(coordinator: coordinator)
                    .transition(.opacity)

            case .characterCreation:
                CharacterCreationView(coordinator: coordinator)
                    .environment(\.modelContext, modelContext)
                    .transition(.move(edge: .trailing))

            case .main:
                MainTabView(coordinator: coordinator)
                    .transition(.opacity)
            }
        }
        .preferredColorScheme(.dark)
        .animation(.easeInOut(duration: 0.4), value: coordinator.appState)
    }
}
