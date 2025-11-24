//
//  DataService.swift
//  Luminal Quest
//
//  Created by Luminal Quest Team
//

import Foundation
import Combine

class DataService: ObservableObject {
    static let shared = DataService()
    
    private let userProgressKey = "luminalquest_user_progress"
    private let levelsKey = "luminalquest_levels"
    private let dailyChallengeKey = "luminalquest_daily_challenge"
    private let leaderboardKey = "luminalquest_leaderboard"
    private let themesKey = "luminalquest_themes"
    private let coinsKey = "luminalquest_coins"
    private let selectedThemeKey = "luminalquest_selected_theme"
    
    private init() {
        initializeDefaultLevels()
        initializeDefaultThemes()
    }
    
    // MARK: - User Progress Management
    
    func saveUserProgress(_ progress: UserProgress) {
        if let encoded = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(encoded, forKey: userProgressKey)
        }
    }
    
    func loadUserProgress() -> UserProgress {
        if let data = UserDefaults.standard.data(forKey: userProgressKey),
           let progress = try? JSONDecoder().decode(UserProgress.self, from: data) {
            return progress
        }
        return UserProgress()
    }
    
    func resetUserProgress() {
        UserDefaults.standard.removeObject(forKey: userProgressKey)
    }
    
    // MARK: - Level Management
    
    func saveLevels(_ levels: [GameLevel]) {
        if let encoded = try? JSONEncoder().encode(levels) {
            UserDefaults.standard.set(encoded, forKey: levelsKey)
        }
    }
    
    func loadLevels() -> [GameLevel] {
        if let data = UserDefaults.standard.data(forKey: levelsKey),
           let levels = try? JSONDecoder().decode([GameLevel].self, from: data) {
            return levels
        }
        return generateDefaultLevels()
    }
    
    // Generate level with specific difficulty
    func generateLevel(difficulty: GameLevel.Difficulty, levelNumber: Int = 1) -> GameLevel {
        let (timeLimit, complexity, targetScore) = getLevelParameters(difficulty: difficulty)
        
        return GameLevel(
            levelNumber: levelNumber,
            title: getTitleForDifficulty(difficulty, number: levelNumber),
            description: getDescriptionForDifficulty(difficulty),
            difficulty: difficulty,
            targetScore: targetScore,
            timeLimit: timeLimit,
            puzzlePattern: generatePuzzlePattern(complexity: complexity, difficulty: difficulty),
            isUnlocked: true
        )
    }
    
    private func getLevelParameters(difficulty: GameLevel.Difficulty) -> (TimeInterval, Int, Int) {
        switch difficulty {
        case .easy:
            return (180, 5, 200)  // 3 minutes, 5 nodes, 200 points
        case .medium:
            return (120, 7, 350)  // 2 minutes, 7 nodes, 350 points
        case .hard:
            return (90, 9, 500)   // 1.5 minutes, 9 nodes, 500 points
        case .expert:
            return (60, 12, 800)  // 1 minute, 12 nodes, 800 points
        }
    }
    
    private func getTitleForDifficulty(_ difficulty: GameLevel.Difficulty, number: Int) -> String {
        switch difficulty {
        case .easy:
            return "Training \(number)"
        case .medium:
            return "Challenge \(number)"
        case .hard:
            return "Trial \(number)"
        case .expert:
            return "Mastery \(number)"
        }
    }
    
    private func getDescriptionForDifficulty(_ difficulty: GameLevel.Difficulty) -> String {
        switch difficulty {
        case .easy:
            return "Great start for beginners"
        case .medium:
            return "Test your skills"
        case .hard:
            return "For experienced players only"
        case .expert:
            return "Extreme challenge"
        }
    }
    
    private func initializeDefaultLevels() {
        // Only initialize if no levels exist
        if UserDefaults.standard.data(forKey: levelsKey) == nil {
            let defaultLevels = generateDefaultLevels()
            saveLevels(defaultLevels)
        }
    }
    
    private func generateDefaultLevels() -> [GameLevel] {
        var levels: [GameLevel] = []
        
        // Level 1 - Tutorial
        levels.append(GameLevel(
            levelNumber: 1,
            title: "First Contact",
            description: "Begin your journey into the Luminal Dimension",
            difficulty: .easy,
            targetScore: 100,
            timeLimit: nil,
            puzzlePattern: generatePuzzlePattern(complexity: 3),
            isUnlocked: true
        ))
        
        // Level 2-5 - Easy
        for i in 2...5 {
            levels.append(GameLevel(
                levelNumber: i,
                title: "Gateway \(i-1)",
                description: "Navigate through the dimensional gateways",
                difficulty: .easy,
                targetScore: 100 * i,
                timeLimit: 120,
                puzzlePattern: generatePuzzlePattern(complexity: 3 + i),
                isUnlocked: false
            ))
        }
        
        // Level 6-10 - Medium
        for i in 6...10 {
            levels.append(GameLevel(
                levelNumber: i,
                title: "Nexus \(i-5)",
                description: "Master the dimensional nexus points",
                difficulty: .medium,
                targetScore: 150 * i,
                timeLimit: 90,
                puzzlePattern: generatePuzzlePattern(complexity: 5 + i),
                isUnlocked: false
            ))
        }
        
        // Level 11-15 - Hard
        for i in 11...15 {
            levels.append(GameLevel(
                levelNumber: i,
                title: "Rift \(i-10)",
                description: "Challenge the dimensional rifts",
                difficulty: .hard,
                targetScore: 200 * i,
                timeLimit: 60,
                puzzlePattern: generatePuzzlePattern(complexity: 8 + i),
                isUnlocked: false
            ))
        }
        
        // Level 16-20 - Expert
        for i in 16...20 {
            levels.append(GameLevel(
                levelNumber: i,
                title: "Singularity \(i-15)",
                description: "Face the ultimate dimensional challenge",
                difficulty: .expert,
                targetScore: 300 * i,
                timeLimit: 45,
                puzzlePattern: generatePuzzlePattern(complexity: 12 + i),
                isUnlocked: false
            ))
        }
        
        return levels
    }
    
    private func generatePuzzlePattern(complexity: Int, difficulty: GameLevel.Difficulty = .easy) -> [PuzzleNode] {
        var nodes: [PuzzleNode] = []
        
        // Start node - создаем без connections, добавим потом
        let startNode = PuzzleNode(
            position: CGPoint(x: 0.5, y: 0.1),
            nodeType: .start,
            value: 0
        )
        nodes.append(startNode)
        
        // Calculate obstacle probability based on difficulty
        let obstacleProbability: Double
        switch difficulty {
        case .easy:
            obstacleProbability = 0.1
        case .medium:
            obstacleProbability = 0.2
        case .hard:
            obstacleProbability = 0.3
        case .expert:
            obstacleProbability = 0.4
        }
        
        // Generate intermediate nodes based on complexity
        for i in 1..<complexity {
            let x = Double.random(in: 0.2...0.8)
            let y = 0.1 + (Double(i) / Double(complexity)) * 0.7
            
            // Determine node type based on difficulty
            let nodeType: PuzzleNode.NodeType
            let random = Double.random(in: 0...1)
            
            if random < obstacleProbability {
                nodeType = .obstacle
            } else if random < obstacleProbability + 0.15 {
                nodeType = .powerup
            } else {
                nodeType = .checkpoint
            }
            
            let value: Int
            switch nodeType {
            case .checkpoint:
                value = Int.random(in: 20...50)
            case .obstacle:
                value = Int.random(in: 30...60)
            case .powerup:
                value = Int.random(in: 40...80)
            default:
                value = 0
            }
            
            let node = PuzzleNode(
                position: CGPoint(x: x, y: y),
                nodeType: nodeType,
                connections: [], // Заполним потом
                value: value
            )
            nodes.append(node)
        }
        
        // Goal node
        let goalNode = PuzzleNode(
            position: CGPoint(x: 0.5, y: 0.9),
            nodeType: .goal,
            connections: [],
            value: 100
        )
        nodes.append(goalNode)
        
        // Now create correct connections: from each node to nearby nodes
        var finalNodes: [PuzzleNode] = []
        for i in 0..<nodes.count {
            let node = nodes[i]
            var connections: [UUID] = []
            
            // Connect to multiple nearby nodes for alternative paths
            if i < nodes.count - 1 {
                // Always connect to next node
                connections.append(nodes[i + 1].id)
                
                // Also connect to node after next (skip one) if exists
                if i < nodes.count - 2 {
                    let distance = sqrt(
                        pow(nodes[i].position.x - nodes[i + 2].position.x, 2) +
                        pow(nodes[i].position.y - nodes[i + 2].position.y, 2)
                    )
                    // Only connect if reasonably close (not too far)
                    if distance < 0.5 {
                        connections.append(nodes[i + 2].id)
                    }
                }
                
                // For more complex levels, add connections to nodes at similar Y level (side paths)
                if complexity > 5 && i > 0 && i < nodes.count - 1 {
                    for j in 0..<nodes.count {
                        if j != i && j != i + 1 && j > i {
                            let yDiff = abs(nodes[i].position.y - nodes[j].position.y)
                            let xDiff = abs(nodes[i].position.x - nodes[j].position.x)
                            
                            // Connect to nodes at similar height but different x position
                            if yDiff < 0.15 && xDiff > 0.2 && !connections.contains(nodes[j].id) {
                                connections.append(nodes[j].id)
                            }
                        }
                    }
                }
            }
            
            // Create new node with correct connections
            let updatedNode = PuzzleNode(
                id: node.id,
                position: node.position,
                nodeType: node.nodeType,
                connections: connections,
                value: node.value
            )
            finalNodes.append(updatedNode)
        }
        
        return finalNodes
    }
    
    // MARK: - Achievement Management
    
    func getDefaultAchievements() -> [Achievement] {
        return [
            Achievement(
                title: "First Steps",
                description: "Complete your first level",
                icon: "star.fill",
                requirement: .completeLevels(count: 1)
            ),
            Achievement(
                title: "Explorer",
                description: "Complete 5 levels",
                icon: "map.fill",
                requirement: .completeLevels(count: 5)
            ),
            Achievement(
                title: "Master Navigator",
                description: "Complete 10 levels",
                icon: "crown.fill",
                requirement: .completeLevels(count: 10)
            ),
            Achievement(
                title: "Speed Demon",
                description: "Complete a level in under 30 seconds",
                icon: "bolt.fill",
                requirement: .completeInTime(seconds: 30)
            ),
            Achievement(
                title: "Score Hunter",
                description: "Reach a total score of 10,000",
                icon: "flame.fill",
                requirement: .reachScore(score: 10000)
            ),
            Achievement(
                title: "Perfect Streak",
                description: "Get 3 perfect scores in a row",
                icon: "sparkles",
                requirement: .perfectStreak(count: 3)
            ),
            Achievement(
                title: "Dedication",
                description: "Play for 7 consecutive days",
                icon: "calendar",
                requirement: .playDays(days: 7)
            )
        ]
    }
    
    // MARK: - Coins Management
    
    func getCoins() -> Int {
        return UserDefaults.standard.integer(forKey: coinsKey)
    }
    
    func addCoins(_ amount: Int) {
        let current = getCoins()
        UserDefaults.standard.set(current + amount, forKey: coinsKey)
    }
    
    func spendCoins(_ amount: Int) -> Bool {
        let current = getCoins()
        if current >= amount {
            UserDefaults.standard.set(current - amount, forKey: coinsKey)
            return true
        }
        return false
    }
    
    // MARK: - Daily Challenge Management
    
    func getDailyChallenge() -> DailyChallenge {
        // Check if we have a challenge for today
        if let data = UserDefaults.standard.data(forKey: dailyChallengeKey),
           let challenge = try? JSONDecoder().decode(DailyChallenge.self, from: data) {
            // Check if it's still today
            if Calendar.current.isDateInToday(challenge.date) {
                return challenge
            }
        }
        
        // Generate new daily challenge
        let newChallenge = DailyChallenge.generateDaily()
        saveDailyChallenge(newChallenge)
        return newChallenge
    }
    
    func saveDailyChallenge(_ challenge: DailyChallenge) {
        if let encoded = try? JSONEncoder().encode(challenge) {
            UserDefaults.standard.set(encoded, forKey: dailyChallengeKey)
        }
    }
    
    func completeDailyChallenge() {
        var challenge = getDailyChallenge()
        let completed = DailyChallenge(
            id: challenge.id,
            date: challenge.date,
            title: challenge.title,
            description: challenge.description,
            difficulty: challenge.difficulty,
            targetScore: challenge.targetScore,
            timeLimit: challenge.timeLimit,
            reward: challenge.reward,
            isCompleted: true
        )
        saveDailyChallenge(completed)
        addCoins(completed.reward)
    }
    
    // MARK: - Leaderboard Management
    
    func getLeaderboard() -> [LeaderboardEntry] {
        if let data = UserDefaults.standard.data(forKey: leaderboardKey),
           let entries = try? JSONDecoder().decode([LeaderboardEntry].self, from: data) {
            return entries.sorted { $0.score > $1.score }
        }
        return []
    }
    
    func addLeaderboardEntry(_ entry: LeaderboardEntry) {
        var leaderboard = getLeaderboard()
        leaderboard.append(entry)
        // Keep only top 100
        leaderboard = Array(leaderboard.sorted { $0.score > $1.score }.prefix(100))
        
        if let encoded = try? JSONEncoder().encode(leaderboard) {
            UserDefaults.standard.set(encoded, forKey: leaderboardKey)
        }
    }
    
    // MARK: - Theme Management
    
    func initializeDefaultThemes() {
        if UserDefaults.standard.data(forKey: themesKey) == nil {
            saveThemes(Theme.defaultThemes)
        }
    }
    
    func getThemes() -> [Theme] {
        if let data = UserDefaults.standard.data(forKey: themesKey),
           let themes = try? JSONDecoder().decode([Theme].self, from: data) {
            return themes
        }
        return Theme.defaultThemes
    }
    
    func saveThemes(_ themes: [Theme]) {
        if let encoded = try? JSONEncoder().encode(themes) {
            UserDefaults.standard.set(encoded, forKey: themesKey)
        }
    }
    
    func purchaseTheme(_ themeId: UUID) -> Bool {
        var themes = getThemes()
        guard let index = themes.firstIndex(where: { $0.id == themeId }) else { return false }
        
        let theme = themes[index]
        if theme.isPurchased { return true }
        
        if spendCoins(theme.price) {
            let purchased = Theme(
                id: theme.id,
                name: theme.name,
                backgroundColor: theme.backgroundColor,
                accentColor: theme.accentColor,
                price: theme.price,
                isPurchased: true,
                icon: theme.icon
            )
            themes[index] = purchased
            saveThemes(themes)
            return true
        }
        return false
    }
    
    func getSelectedTheme() -> Theme {
        if let themeIdString = UserDefaults.standard.string(forKey: selectedThemeKey),
           let themeId = UUID(uuidString: themeIdString) {
            let themes = getThemes()
            if let theme = themes.first(where: { $0.id == themeId && $0.isPurchased }) {
                return theme
            }
        }
        // Return default theme
        return Theme.defaultThemes.first!
    }
    
    func selectTheme(_ theme: Theme) {
        if theme.isPurchased {
            UserDefaults.standard.set(theme.id.uuidString, forKey: selectedThemeKey)
        }
    }
}

