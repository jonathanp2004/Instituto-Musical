//
//  TopicProgress.swift
//  Instituto Musical
//
//  Tracks per-topic mastery, boss status, difficulty level, and attempt history.
//

import Foundation
import SwiftData

@Model
final class TopicProgress {
    var id: UUID
    var topicID: String
    var adventureNumber: Int
    var totalAttempts: Int
    var correctAttempts: Int
    var masteryScore: Double
    var currentDifficulty: Int  // 0=Easy, 1=Medium, 2=Hard
    var bossDefeated: Bool
    var bossHighScore: Int
    var starsEarned: Int        // 0–3
    var lastAttemptDate: Date?
    var consecutiveCorrect: Int
    var consecutiveWrong: Int

    init(topicID: String, adventureNumber: Int) {
        self.id = UUID()
        self.topicID = topicID
        self.adventureNumber = adventureNumber
        self.totalAttempts = 0
        self.correctAttempts = 0
        self.masteryScore = 0.0
        self.currentDifficulty = 0
        self.bossDefeated = false
        self.bossHighScore = 0
        self.starsEarned = 0
        self.lastAttemptDate = nil
        self.consecutiveCorrect = 0
        self.consecutiveWrong = 0
    }

    // MARK: - Mastery

    var masteryLevel: MasteryLevel {
        switch masteryScore {
        case 0.0..<0.4:  return .novice
        case 0.4..<0.7:  return .practitioner
        case 0.7..<0.9:  return .skilled
        default:         return .master
        }
    }

    var isWeakArea: Bool {
        masteryScore < 0.6 && totalAttempts >= 5
    }

    var isUnlocked: Bool {
        // Adventure 1 is always unlocked. Others require previous boss defeated.
        adventureNumber <= 1
    }

    // MARK: - Recording Results

    /// Record the result of an activity (mini-game or boss attempt)
    func recordAttempt(questionsTotal: Int, questionsCorrect: Int) {
        totalAttempts += questionsTotal
        correctAttempts += questionsCorrect
        lastAttemptDate = Date()

        // Update mastery as a weighted rolling score
        let sessionScore = Double(questionsCorrect) / Double(max(1, questionsTotal))
        // Blend: 70% old mastery + 30% new session
        masteryScore = masteryScore * 0.7 + sessionScore * 0.3

        // Difficulty scaling
        if questionsCorrect == questionsTotal {
            consecutiveCorrect += 1
            consecutiveWrong = 0
            if consecutiveCorrect >= 3 && currentDifficulty < 2 {
                currentDifficulty += 1
                consecutiveCorrect = 0
            }
        } else if Double(questionsCorrect) / Double(questionsTotal) < 0.5 {
            consecutiveWrong += 1
            consecutiveCorrect = 0
            if consecutiveWrong >= 2 && currentDifficulty > 0 {
                currentDifficulty -= 1
                consecutiveWrong = 0
            }
        } else {
            consecutiveCorrect = 0
            consecutiveWrong = 0
        }
    }

    /// Record a boss attempt
    func recordBossAttempt(score: Int, passed: Bool) {
        if passed {
            bossDefeated = true
        }
        bossHighScore = max(bossHighScore, score)

        // Stars based on score percentage
        if score >= 90 {
            starsEarned = max(starsEarned, 3)
        } else if score >= 75 {
            starsEarned = max(starsEarned, 2)
        } else if passed {
            starsEarned = max(starsEarned, 1)
        }
    }

    /// Difficulty label
    var difficultyLabel: String {
        switch currentDifficulty {
        case 0: return "Easy"
        case 1: return "Medium"
        default: return "Hard"
        }
    }

    var difficultyLabelES: String {
        switch currentDifficulty {
        case 0: return "Fácil"
        case 1: return "Medio"
        default: return "Difícil"
        }
    }
}

// MARK: - Mastery Level Enum

enum MasteryLevel: String, Codable {
    case novice = "Novice"
    case practitioner = "Practitioner"
    case skilled = "Skilled"
    case master = "Master"

    var spanishName: String {
        switch self {
        case .novice: return "Novato"
        case .practitioner: return "Practicante"
        case .skilled: return "Hábil"
        case .master: return "Maestro"
        }
    }

    var color: String {
        switch self {
        case .novice: return "red"
        case .practitioner: return "yellow"
        case .skilled: return "blue"
        case .master: return "gold"
        }
    }
}
