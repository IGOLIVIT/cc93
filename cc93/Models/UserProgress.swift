//
//  UserProgress.swift
//  Luminal Quest
//
//  Created by Luminal Quest Team
//

import Foundation

struct UserProgress: Codable {
    var currentLevel: Int
    var highestLevelUnlocked: Int
    var totalScore: Int
    var achievements: [Achievement]
    var completedLevels: [Int: LevelStats]
    var lastPlayedDate: Date
    var totalPlayTime: TimeInterval
    var gamesPlayed: Int
    
    init(currentLevel: Int = 1, highestLevelUnlocked: Int = 1, totalScore: Int = 0, achievements: [Achievement] = [], completedLevels: [Int: LevelStats] = [:], lastPlayedDate: Date = Date(), totalPlayTime: TimeInterval = 0, gamesPlayed: Int = 0) {
        self.currentLevel = currentLevel
        self.highestLevelUnlocked = highestLevelUnlocked
        self.totalScore = totalScore
        self.achievements = achievements
        self.completedLevels = completedLevels
        self.lastPlayedDate = lastPlayedDate
        self.totalPlayTime = totalPlayTime
        self.gamesPlayed = gamesPlayed
    }
}

struct LevelStats: Codable {
    let levelNumber: Int
    let bestScore: Int
    let bestTime: TimeInterval
    let attempts: Int
    let completedDate: Date
    let stars: Int
    
    init(levelNumber: Int, bestScore: Int, bestTime: TimeInterval, attempts: Int = 1, completedDate: Date = Date(), stars: Int = 0) {
        self.levelNumber = levelNumber
        self.bestScore = bestScore
        self.bestTime = bestTime
        self.attempts = attempts
        self.completedDate = completedDate
        self.stars = stars
    }
}

struct Achievement: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let isUnlocked: Bool
    let unlockedDate: Date?
    let requirement: AchievementRequirement
    
    enum AchievementRequirement: Codable {
        case completeLevels(count: Int)
        case reachScore(score: Int)
        case completeInTime(seconds: TimeInterval)
        case perfectStreak(count: Int)
        case playDays(days: Int)
        
        var description: String {
            switch self {
            case .completeLevels(let count):
                return "Complete \(count) levels"
            case .reachScore(let score):
                return "Reach a total score of \(score)"
            case .completeInTime(let seconds):
                return "Complete a level in under \(Int(seconds)) seconds"
            case .perfectStreak(let count):
                return "Get \(count) perfect scores in a row"
            case .playDays(let days):
                return "Play for \(days) consecutive days"
            }
        }
    }
    
    init(id: UUID = UUID(), title: String, description: String, icon: String, isUnlocked: Bool = false, unlockedDate: Date? = nil, requirement: AchievementRequirement) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.isUnlocked = isUnlocked
        self.unlockedDate = unlockedDate
        self.requirement = requirement
    }
}

