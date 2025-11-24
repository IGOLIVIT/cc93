//
//  DailyChallenge.swift
//  Luminal Quest
//
//  Created by Luminal Quest Team
//

import Foundation

struct DailyChallenge: Identifiable, Codable {
    let id: UUID
    let date: Date
    let title: String
    let description: String
    let difficulty: GameLevel.Difficulty
    let targetScore: Int
    let timeLimit: TimeInterval
    let reward: Int
    let isCompleted: Bool
    
    init(id: UUID = UUID(), date: Date = Date(), title: String, description: String, difficulty: GameLevel.Difficulty, targetScore: Int, timeLimit: TimeInterval, reward: Int, isCompleted: Bool = false) {
        self.id = id
        self.date = date
        self.title = title
        self.description = description
        self.difficulty = difficulty
        self.targetScore = targetScore
        self.timeLimit = timeLimit
        self.reward = reward
        self.isCompleted = isCompleted
    }
    
    static func generateDaily() -> DailyChallenge {
        let difficulties: [GameLevel.Difficulty] = [.easy, .medium, .hard, .expert]
        let randomDifficulty = difficulties.randomElement() ?? .medium
        
        let titles = [
            "Speed Run",
            "Perfect Path",
            "Time Master",
            "Combo King",
            "Flawless Victory"
        ]
        
        let descriptions = [
            "Complete without hitting obstacles",
            "Finish under target time",
            "Get max combo",
            "Score above target",
            "Collect all power-ups"
        ]
        
        return DailyChallenge(
            title: titles.randomElement() ?? "Daily Challenge",
            description: descriptions.randomElement() ?? "Complete the challenge",
            difficulty: randomDifficulty,
            targetScore: Int.random(in: 300...800),
            timeLimit: Double.random(in: 60...180),
            reward: Int.random(in: 50...200)
        )
    }
}

struct LeaderboardEntry: Identifiable, Codable {
    let id: UUID
    let playerName: String
    let score: Int
    let level: Int
    let difficulty: String
    let date: Date
    
    init(id: UUID = UUID(), playerName: String, score: Int, level: Int, difficulty: String, date: Date = Date()) {
        self.id = id
        self.playerName = playerName
        self.score = score
        self.level = level
        self.difficulty = difficulty
        self.date = date
    }
}

struct Theme: Identifiable, Codable {
    let id: UUID
    let name: String
    let backgroundColor: String
    let accentColor: String
    let price: Int
    let isPurchased: Bool
    let icon: String
    
    init(id: UUID = UUID(), name: String, backgroundColor: String, accentColor: String, price: Int, isPurchased: Bool = false, icon: String = "paintpalette.fill") {
        self.id = id
        self.name = name
        self.backgroundColor = backgroundColor
        self.accentColor = accentColor
        self.price = price
        self.isPurchased = isPurchased
        self.icon = icon
    }
    
    static let defaultThemes: [Theme] = [
        Theme(name: "Midnight", backgroundColor: "1D1F30", accentColor: "FE284A", price: 0, isPurchased: true),
        Theme(name: "Ocean", backgroundColor: "0A1929", accentColor: "00B4D8", price: 100),
        Theme(name: "Forest", backgroundColor: "1A2F1A", accentColor: "52B788", price: 150),
        Theme(name: "Sunset", backgroundColor: "2D1B2E", accentColor: "FF6B35", price: 150),
        Theme(name: "Neon", backgroundColor: "0D0221", accentColor: "FF006E", price: 200),
        Theme(name: "Golden", backgroundColor: "1C1810", accentColor: "FFD60A", price: 250)
    ]
}

