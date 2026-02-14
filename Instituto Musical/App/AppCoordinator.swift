//
//  AppCoordinator.swift
//  Instituto Musical
//
//  Manages root app state (onboarding vs main), tab selection, and navigation paths.
//

import SwiftUI
import SwiftData

@Observable
final class AppCoordinator {

    enum AppState: Equatable {
        case loading
        case onboarding
        case characterCreation
        case main
    }

    enum Tab: Hashable {
        case map
        case dashboard
        case practice
        case inventory
        case settings
    }

    var appState: AppState = .loading
    var selectedTab: Tab = .map
    var mapNavigationPath = NavigationPath()

    /// Check if user profile exists to determine initial state
    func determineInitialState(hasProfile: Bool) {
        if hasProfile {
            appState = .main
        } else {
            appState = .onboarding
        }
    }

    func completeOnboarding() {
        withAnimation(.easeInOut(duration: 0.5)) {
            appState = .characterCreation
        }
    }

    func completeCharacterCreation() {
        withAnimation(.easeInOut(duration: 0.5)) {
            appState = .main
        }
    }

    func navigateToLand(_ land: Land) {
        mapNavigationPath.append(land)
    }

    func navigateToMiniGame(_ gameID: String) {
        mapNavigationPath.append(gameID)
    }

    func popToMap() {
        mapNavigationPath = NavigationPath()
    }
}
