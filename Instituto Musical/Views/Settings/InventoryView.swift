//
//  InventoryView.swift
//  Instituto Musical
//
//  Displays all earned badges, cosmetics, and rewards.
//

import SwiftUI
import SwiftData

struct InventoryView: View {
    @Query private var items: [InventoryItem]
    @Query private var profiles: [UserProfile]

    private var profile: UserProfile? { profiles.first }

    private var badges: [InventoryItem] { items.filter { $0.category == "badge" } }
    private var cosmetics: [InventoryItem] { items.filter { $0.category == "cosmetic" } }
    private var tools: [InventoryItem] { items.filter { $0.category == "tool" } }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.imBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Character preview
                        if let profile = profile {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(Color.imPrimary.opacity(0.15))
                                        .frame(width: 100, height: 100)
                                    Image(systemName: profile.avatarBase)
                                        .font(.system(size: 44))
                                        .foregroundStyle(.imPrimary)
                                }
                                Text(profile.displayName)
                                    .font(.imSubheadline)
                                    .foregroundStyle(.imTextPrimary)
                                Text(profile.title)
                                    .font(.imCaption)
                                    .foregroundStyle(.imSecondary)
                            }
                        }

                        // Badges
                        InventorySectionView(title: "Insignias", icon: "medal.fill", items: badges)

                        // Cosmetics
                        InventorySectionView(title: "Cosméticos", icon: "tshirt.fill", items: cosmetics)

                        // Tools
                        InventorySectionView(title: "Herramientas", icon: "wrench.and.screwdriver.fill", items: tools)

                        if items.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "backpack")
                                    .font(.system(size: 48))
                                    .foregroundStyle(.imTextMuted)
                                Text("Tu inventario está vacío")
                                    .font(.imBody)
                                    .foregroundStyle(.imTextMuted)
                                Text("¡Completa aventuras para ganar recompensas!")
                                    .font(.imCaption)
                                    .foregroundStyle(.imTextMuted)
                            }
                            .padding(.top, 40)
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Inventario")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.imBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

struct InventorySectionView: View {
    let title: String
    let icon: String
    let items: [InventoryItem]

    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .foregroundStyle(.imSecondary)
                    Text(title)
                        .font(.imSubheadline)
                        .foregroundStyle(.imTextPrimary)
                    Text("(\(items.count))")
                        .font(.imCaption)
                        .foregroundStyle(.imTextMuted)
                }

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                    ForEach(items, id: \.id) { item in
                        VStack(spacing: 4) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(item.isEquipped ? Color.imPrimary.opacity(0.2) : Color.imCard)
                                    .frame(width: 64, height: 64)
                                Image(systemName: "star.fill")
                                    .foregroundStyle(item.isEquipped ? .imPrimary : .imTextMuted)
                            }
                            Text(item.itemID.replacingOccurrences(of: "_", with: " ").prefix(10))
                                .font(.system(size: 9))
                                .foregroundStyle(.imTextMuted)
                                .lineLimit(1)
                        }
                    }
                }
            }
            .cardStyle()
            .padding(.horizontal)
        }
    }
}
