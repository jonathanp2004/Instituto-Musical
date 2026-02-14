//
//  InventoryItem.swift
//  Instituto Musical
//
//  Tracks earned rewards: badges, cosmetics, instrument skins, abilities, etc.
//

import Foundation
import SwiftData

@Model
final class InventoryItem {
    var id: UUID
    var itemID: String
    var category: String    // "badge", "cosmetic", "skin", "tool", "ability", "powerup"
    var earnedDate: Date
    var isEquipped: Bool
    var quantity: Int        // for consumables (e.g., streak freezes)

    init(itemID: String, category: String, quantity: Int = 1) {
        self.id = UUID()
        self.itemID = itemID
        self.category = category
        self.earnedDate = Date()
        self.isEquipped = false
        self.quantity = quantity
    }
}
