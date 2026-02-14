//
//  OnboardingView.swift
//  Instituto Musical
//
//  3-page onboarding carousel introducing the app concept.
//

import SwiftUI

struct OnboardingView: View {
    let coordinator: AppCoordinator
    @State private var currentPage = 0

    private let pages: [(icon: String, title: String, subtitle: String)] = [
        ("music.note.house.fill",
         "Bienvenido a\nInstituto Musical",
         "Viaja por un mundo de fantasía y aprende teoría musical jugando."),
        ("map.fill",
         "16 Aventuras\nTe Esperan",
         "Desde semitonos hasta acordes — cada tierra enseña un concepto nuevo con mini-juegos."),
        ("star.fill",
         "Gana XP,\nSube de Nivel",
         "Completa desafíos, derrota jefes, desbloquea habilidades y personaliza tu personaje.")
    ]

    var body: some View {
        ZStack {
            Color.imBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        VStack(spacing: 24) {
                            Spacer()

                            Image(systemName: pages[index].icon)
                                .font(.system(size: 80))
                                .foregroundStyle(
                                    index == 0 ? Color.imPrimary :
                                    index == 1 ? Color.regionForest :
                                    Color.imWarning
                                )
                                .symbolEffect(.pulse, options: .repeating)

                            Text(pages[index].title)
                                .font(.imTitle)
                                .foregroundStyle(.imTextPrimary)
                                .multilineTextAlignment(.center)

                            Text(pages[index].subtitle)
                                .font(.imBody)
                                .foregroundStyle(.imTextSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)

                            Spacer()
                            Spacer()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))

                // Bottom button
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation { currentPage += 1 }
                    } else {
                        coordinator.completeOnboarding()
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? "Siguiente" : "¡Empezar!")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
}
