//
//  UserProfile.swift
//  Instituto Musical
//
//  SwiftData model for the player's profile, XP, level, streak, and preferences.
//

import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var displayName: String
    var avatarBase: String
    var skinTone: String
    var hairStyle: String
    var equippedCosmetics: [String]
    var equippedAbilities: [String]
    var currentLevel: Int
    var totalXP: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastActivityDate: Date?
    var preferredLanguage: String
    var reminderHour: Int
    var reminderMinute: Int
    var soundEnabled: Bool
    var createdAt: Date

    init(
        displayName: String,
        avatarBase: String = "avatar_1",
        skinTone: String = "medium",
        hairStyle: String = "short_black",
        preferredLanguage: String = "es"
    ) {
        self.id = UUID()
        self.displayName = displayName
        self.avatarBase = avatarBase
        self.skinTone = skinTone
        self.hairStyle = hairStyle
        self.equippedCosmetics = []
        self.equippedAbilities = []
        self.currentLevel = 1
        self.totalXP = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastActivityDate = nil
        self.preferredLanguage = preferredLanguage
        self.reminderHour = 17
        self.reminderMinute = 0
        self.soundEnabled = true
        self.createdAt = Date()
    }

    // MARK: - XP & Level Calculations

    /// XP needed to reach the next level from the current level
    var xpForNextLevel: Int {
        100 + (currentLevel * 50)
    }

    /// XP the player has earned within their current level
    var xpInCurrentLevel: Int {
        var xpSpent = 0
        for lvl in 1..<currentLevel {
            xpSpent += 100 + (lvl * 50)
        }
        return max(0, totalXP - xpSpent)
    }

    /// Fraction (0.0–1.0) of progress toward next level
    var levelProgress: Double {
        Double(xpInCurrentLevel) / Double(max(1, xpForNextLevel))
    }

    /// Title based on level
    var title: String {
        switch currentLevel {
        case 1...9: return "Novato"
        case 10...24: return "Músico"
        case 25...49: return "Maestro"
        default: return "Gran Maestro"
        }
    }

    var titleEN: String {
        switch currentLevel {
        case 1...9: return "Novice"
        case 10...24: return "Musician"
        case 25...49: return "Master"
        default: return "Grand Master"
        }
    }

    // MARK: - XP Management

    /// Add XP and handle level-ups. Returns true if the player leveled up.
    @discardableResult
    func addXP(_ amount: Int) -> Bool {
        totalXP += amount
        var leveledUp = false

        while xpInCurrentLevel >= xpForNextLevel && currentLevel < 50 {
            currentLevel += 1
            leveledUp = true
        }

        return leveledUp
    }

    // MARK: - Streak Management

    /// Call this when the player completes any activity. Updates streak logic.
    func recordActivity() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastDate = lastActivityDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysBetween = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

            if daysBetween == 1 {
                // Consecutive day
                currentStreak += 1
            } else if daysBetween > 1 {
                // Streak broken
                currentStreak = 1
            }
            // daysBetween == 0 means same day, no change
        } else {
            // First ever activity
            currentStreak = 1
        }

        longestStreak = max(longestStreak, currentStreak)
        lastActivityDate = Date()
    }

    /// Streak bonus XP: 25 per day, caps at 250 (10-day streak)
    var streakBonusXP: Int {
        min(currentStreak * 25, 250)
    }

    /// Check if streak is still active (did they play yesterday or today?)
    var isStreakActive: Bool {
        guard let lastDate = lastActivityDate else { return false }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastDay = calendar.startOfDay(for: lastDate)
        let daysBetween = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
        return daysBetween <= 1
    }
}
