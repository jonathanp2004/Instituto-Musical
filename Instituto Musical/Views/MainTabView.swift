//
//  MainTabView.swift
//  Instituto Musical
//
//  Bottom tab bar: Map, Progress, Practice, Inventory, Settings
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Bindable var coordinator: AppCoordinator

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            // Map Tab
            NavigationStack(path: $coordinator.mapNavigationPath) {
                WorldMapView(coordinator: coordinator)
                    .navigationDestination(for: Land.self) { land in
                        LandDetailView(land: land, coordinator: coordinator)
                    }
                    .navigationDestination(for: String.self) { gameID in
                        MiniGameRouterView(gameID: gameID, coordinator: coordinator)
                    }
            }
            .tabItem {
                Label("Mapa", systemImage: "map.fill")
            }
            .tag(AppCoordinator.Tab.map)

            // Dashboard Tab
            DashboardView()
                .tabItem {
                    Label("Progreso", systemImage: "chart.bar.fill")
                }
                .tag(AppCoordinator.Tab.dashboard)

            // Practice Tab
            PracticeKeyboardView()
                .tabItem {
                    Label("Practica", systemImage: "pianokeys")
                }
                .tag(AppCoordinator.Tab.practice)

            // Inventory Tab
            InventoryView()
                .tabItem {
                    Label("Inventario", systemImage: "backpack.fill")
                }
                .tag(AppCoordinator.Tab.inventory)

            // Settings Tab
            SettingsView()
                .tabItem {
                    Label("Ajustes", systemImage: "gearshape.fill")
                }
                .tag(AppCoordinator.Tab.settings)
        }
        .tint(.imPrimary)
    }
}

// MARK: - Mini-Game Router (routes gameID strings to the correct view)

struct MiniGameRouterView: View {
    let gameID: String
    let coordinator: AppCoordinator

    var body: some View {
        Group {
            switch gameID {
            case "step_bridge":
                StepBridgeGameView(coordinator: coordinator)
            case "key_hunter":
                KeyHunterGameView(coordinator: coordinator)
            case "note_calculator":
                NoteCalculatorGameView(coordinator: coordinator)
            default:
                // Placeholder for games not yet implemented
                ComingSoonGameView(gameID: gameID)
            }
        }
        .navigationBarBackButtonHidden(false)
    }
}

// MARK: - Coming Soon Placeholder

struct ComingSoonGameView: View {
    let gameID: String

    var body: some View {
        ZStack {
            Color.imBackground.ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "hammer.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.imSecondary)
                Text("Próximamente")
                    .font(.imTitle)
                    .foregroundStyle(.imTextPrimary)
                Text("This mini-game is coming soon!")
                    .font(.imBody)
                    .foregroundStyle(.imTextSecondary)
                Text("Game ID: \(gameID)")
                    .font(.imCaption)
                    .foregroundStyle(.imTextMuted)
            }
        }
    }
}
