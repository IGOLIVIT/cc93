//
//  GameViewModel.swift
//  Luminal Quest
//
//  Created by Luminal Quest Team
//

import SwiftUI
import Combine
import UIKit

class GameViewModel: ObservableObject {
    @Published var currentLevel: GameLevel?
    @Published var userProgress: UserProgress
    @Published var score: Int = 0
    @Published var timeRemaining: TimeInterval = 0
    @Published var isGameActive: Bool = false
    @Published var isGamePaused: Bool = false
    @Published var gameResult: GameResult?
    @Published var selectedNodes: [PuzzleNode] = []
    @Published var currentCombo: Int = 0
    @Published var showLevelComplete: Bool = false
    
    private var timer: Timer?
    private var gameStartTime: Date?
    private let dataService = DataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    enum GameResult {
        case victory(score: Int, stars: Int, time: TimeInterval)
        case defeat(reason: String)
    }
    
    init() {
        self.userProgress = dataService.loadUserProgress()
    }
    
    // MARK: - Game Flow
    
    func startLevel(_ level: GameLevel) {
        currentLevel = level
        score = 0
        timeRemaining = level.timeLimit ?? 0
        isGameActive = true
        isGamePaused = false
        gameResult = nil
        selectedNodes = []
        currentCombo = 0
        gameStartTime = Date()
        
        // Debug: Print level info and connections
        print("🎮 Starting Level \(level.levelNumber) - \(level.title)")
        print("📊 Difficulty: \(level.difficulty)")
        print("🎯 Target Score: \(level.targetScore)")
        print("🔗 Total nodes: \(level.puzzlePattern.count)")
        
        for (index, node) in level.puzzlePattern.enumerated() {
            print("Node \(index): \(node.nodeType) - Connections: \(node.connections.count) - IDs: \(node.connections)")
        }
        
        if level.timeLimit != nil {
            startTimer()
        }
        
        NetworkService.shared.logEvent("level_started", parameters: [
            "level_number": level.levelNumber,
            "difficulty": level.difficulty.rawValue
        ])
    }
    
    func pauseGame() {
        isGamePaused = true
        timer?.invalidate()
    }
    
    func resumeGame() {
        isGamePaused = false
        if currentLevel?.timeLimit != nil {
            startTimer()
        }
    }
    
    func endGame(victory: Bool) {
        // Ensure we're on main thread for UI updates
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.isGameActive = false
            self.timer?.invalidate()
            
            guard let level = self.currentLevel else { return }
            
            if victory {
                let timeTaken = Date().timeIntervalSince(self.gameStartTime ?? Date())
                let stars = self.calculateStars(score: self.score, targetScore: level.targetScore, timeTaken: timeTaken)
                self.gameResult = .victory(score: self.score, stars: stars, time: timeTaken)
                
                // Update user progress
                self.updateProgressForCompletedLevel(level: level, score: self.score, time: timeTaken, stars: stars)
                
                // Add to leaderboard
                let leaderboardEntry = LeaderboardEntry(
                    playerName: "Player",
                    score: self.score,
                    level: level.levelNumber,
                    difficulty: level.difficulty.rawValue.capitalized
                )
                DataService.shared.addLeaderboardEntry(leaderboardEntry)
                
                NetworkService.shared.logEvent("level_completed", parameters: [
                    "level_number": level.levelNumber,
                    "score": self.score,
                    "stars": stars,
                    "time": timeTaken
                ])
            } else {
                self.gameResult = .defeat(reason: "Time's up!")
                
                NetworkService.shared.logEvent("level_failed", parameters: [
                    "level_number": level.levelNumber,
                    "score": self.score
                ])
            }
        }
    }
    
    func resetGame() {
        if let level = currentLevel {
            startLevel(level)
        }
    }
    
    func exitGame() {
        isGameActive = false
        timer?.invalidate()
        currentLevel = nil
        score = 0
        gameResult = nil
    }
    
    // MARK: - Game Mechanics
    
    func handleNodeTap(_ node: PuzzleNode) {
        guard isGameActive && !isGamePaused else { return }
        
        // Check if this is a valid move
        if selectedNodes.isEmpty {
            // First node must be start node
            if node.nodeType == .start {
                selectedNodes.append(node)
                playHapticFeedback(.light)
            }
        } else {
            // Check if node is connected to last selected node
            let lastNode = selectedNodes.last!
            
            if lastNode.connections.contains(node.id) && !selectedNodes.contains(where: { $0.id == node.id }) {
                selectedNodes.append(node)
                processNodeSelection(node)
                playHapticFeedback(.medium)
            } else {
                // Invalid move - reset combo
                currentCombo = 0
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }
        }
    }
    
    func handleSwipeGesture(from startPoint: CGPoint, to endPoint: CGPoint) {
        guard isGameActive && !isGamePaused else { return }
        
        // Calculate swipe direction and magnitude
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let distance = sqrt(dx * dx + dy * dy)
        
        if distance > 50 {
            // Process swipe-based gameplay mechanic
            let angle = atan2(dy, dx)
            processSwipe(angle: angle, distance: distance)
        }
    }
    
    private func processNodeSelection(_ node: PuzzleNode) {
        switch node.nodeType {
        case .start:
            break
        case .checkpoint:
            score += node.value * (currentCombo + 1)
            currentCombo += 1
        case .obstacle:
            score = max(0, score - node.value)
            currentCombo = 0
        case .goal:
            score += node.value * (currentCombo + 1)
            endGame(victory: true)
        case .powerup:
            score += node.value * 2
            currentCombo += 2
            if let level = currentLevel, level.timeLimit != nil {
                timeRemaining += 10
            }
        }
    }
    
    private func processSwipe(angle: Double, distance: Double) {
        let points = Int(distance / 10)
        score += points
        currentCombo += 1
    }
    
    // MARK: - Timer Management
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.endGame(victory: false)
            }
        }
    }
    
    // MARK: - Progress Management
    
    private func updateProgressForCompletedLevel(level: GameLevel, score: Int, time: TimeInterval, stars: Int) {
        // Update level stats
        let stats = LevelStats(
            levelNumber: level.levelNumber,
            bestScore: score,
            bestTime: time,
            stars: stars
        )
        
        if let existingStats = userProgress.completedLevels[level.levelNumber] {
            // Update if better
            if score > existingStats.bestScore || time < existingStats.bestTime {
                userProgress.completedLevels[level.levelNumber] = stats
            }
        } else {
            userProgress.completedLevels[level.levelNumber] = stats
        }
        
        // Update total score
        userProgress.totalScore += score
        
        // Unlock next level
        if level.levelNumber >= userProgress.highestLevelUnlocked {
            userProgress.highestLevelUnlocked = level.levelNumber + 1
        }
        
        // Update current level
        userProgress.currentLevel = level.levelNumber + 1
        
        // Update stats
        userProgress.gamesPlayed += 1
        userProgress.lastPlayedDate = Date()
        
        // Award coins based on stars
        let coinsEarned = stars * 25 + (score / 10)
        DataService.shared.addCoins(coinsEarned)
        
        // Check and unlock achievements
        checkAchievements()
        
        // Save progress
        dataService.saveUserProgress(userProgress)
    }
    
    private func checkAchievements() {
        let defaultAchievements = dataService.getDefaultAchievements()
        
        for achievement in defaultAchievements {
            if !userProgress.achievements.contains(where: { $0.id == achievement.id && $0.isUnlocked }) {
                if shouldUnlockAchievement(achievement) {
                    let updatedAchievement = Achievement(
                        id: achievement.id,
                        title: achievement.title,
                        description: achievement.description,
                        icon: achievement.icon,
                        isUnlocked: true,
                        unlockedDate: Date(),
                        requirement: achievement.requirement
                    )
                    userProgress.achievements.append(updatedAchievement)
                }
            }
        }
    }
    
    private func shouldUnlockAchievement(_ achievement: Achievement) -> Bool {
        switch achievement.requirement {
        case .completeLevels(let count):
            return userProgress.completedLevels.count >= count
        case .reachScore(let targetScore):
            return userProgress.totalScore >= targetScore
        case .completeInTime(let seconds):
            return userProgress.completedLevels.values.contains { $0.bestTime <= seconds }
        case .perfectStreak(let count):
            // Simplified: check if user has count levels with max stars
            let perfectLevels = userProgress.completedLevels.values.filter { $0.stars == 3 }
            return perfectLevels.count >= count
        case .playDays(let days):
            // Simplified implementation
            return userProgress.gamesPlayed >= days
        }
    }
    
    private func calculateStars(score: Int, targetScore: Int, timeTaken: TimeInterval) -> Int {
        let scoreRatio = Double(score) / Double(targetScore)
        
        if scoreRatio >= 1.5 {
            return 3
        } else if scoreRatio >= 1.2 {
            return 2
        } else if scoreRatio >= 1.0 {
            return 1
        }
        return 0
    }
    
    // MARK: - Helper Methods
    
    private func playHapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

