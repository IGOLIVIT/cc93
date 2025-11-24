//
//  HomeView.swift
//  Luminal Quest
//
//  Created by Luminal Quest Team
//

import SwiftUI

struct HomeView: View {
    @StateObject private var gameViewModel = GameViewModel()
    @State private var showSettings = false
    @State private var showLevelSelector = false
    @State private var showDifficultyPicker = false
    @State private var showDailyChallenge = false
    @State private var showLeaderboard = false
    @State private var showThemeShop = false
    @State private var selectedLevel: GameLevel?
    @State private var selectedDifficulty: GameLevel.Difficulty = .easy
    @State private var levels: [GameLevel] = []
    @State private var coins: Int = 0
    @State private var currentTheme: Theme = Theme.defaultThemes.first!
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(hex: currentTheme.backgroundColor)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // Progress bar
                            titleView
                            
                            // Daily Challenge
                            dailyChallengeCard
                            
                            // Quick play section
                            quickPlaySection
                            
                            // Stats cards
                            statsView
                            
                            // Leaderboard preview
                            leaderboardPreview
                            
                            // Achievements preview
                            achievementsPreview
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(item: $selectedLevel) { level in
                SimplifiedGameView(level: level, gameViewModel: gameViewModel)
            }
            .sheet(isPresented: $showDifficultyPicker) {
                DifficultyPickerView(selectedDifficulty: $selectedDifficulty, onStart: {
                    // Generate level with selected difficulty
                    let level = DataService.shared.generateLevel(
                        difficulty: selectedDifficulty,
                        levelNumber: gameViewModel.userProgress.currentLevel
                    )
                    selectedLevel = level
                    showDifficultyPicker = false
                })
            }
            .sheet(isPresented: $showDailyChallenge) {
                DailyChallengeView()
            }
            .sheet(isPresented: $showLeaderboard) {
                LeaderboardView()
            }
            .sheet(isPresented: $showThemeShop) {
                ThemeShopView(currentTheme: $currentTheme, coins: $coins)
            }
            .onAppear {
                loadLevels()
                loadCoins()
                loadTheme()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var headerView: some View {
        HStack {
            // User level badge
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color(hex: currentTheme.accentColor).opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Text("\(gameViewModel.userProgress.currentLevel)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: currentTheme.accentColor))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Level")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                    Text("Player")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
            
            // Coins display
            HStack(spacing: 6) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: currentTheme.accentColor))
                Text("\(coins)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.1))
            )
            
            Button(action: {
                showThemeShop = true
            }) {
                Image(systemName: "paintpalette.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
            .padding(.leading, 8)
            
            Button(action: {
                showSettings = true
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
            }
            .padding(.leading, 8)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(hex: currentTheme.backgroundColor))
    }
    
    private var titleView: some View {
        VStack(spacing: 16) {
            Text("Your Progress")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            // Progress bar
            VStack(spacing: 8) {
                HStack {
                    Text("Level Progress")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text("\(gameViewModel.userProgress.completedLevels.count) / 20")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: currentTheme.accentColor))
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: currentTheme.accentColor),
                                        Color(hex: currentTheme.accentColor).opacity(0.7)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geometry.size.width * CGFloat(gameViewModel.userProgress.completedLevels.count) / 20.0,
                                height: 12
                            )
                    }
                }
                .frame(height: 12)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
        }
        .frame(maxWidth: .infinity)
    }
    
    private var statsView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Statistics")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    StatCard(
                        title: "Total Score",
                        value: "\(gameViewModel.userProgress.totalScore)",
                        icon: "star.fill",
                        color: Color(hex: currentTheme.accentColor)
                    )
                    
                    StatCard(
                        title: "Best Score",
                        value: "\(gameViewModel.userProgress.completedLevels.values.map { $0.bestScore }.max() ?? 0)",
                        icon: "trophy.fill",
                        color: Color.yellow
                    )
                }
                
                HStack(spacing: 12) {
                    StatCard(
                        title: "Games Played",
                        value: "\(gameViewModel.userProgress.gamesPlayed)",
                        icon: "gamecontroller.fill",
                        color: Color.blue
                    )
                    
                    StatCard(
                        title: "Achievements",
                        value: "\(gameViewModel.userProgress.achievements.filter { $0.isUnlocked }.count)",
                        icon: "rosette",
                        color: Color.green
                    )
                }
            }
        }
    }
    
    private var quickPlaySection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Quick Play")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }
            
            Button(action: {
                showDifficultyPicker = true
            }) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: currentTheme.accentColor).opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "play.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color(hex: currentTheme.accentColor))
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Start Game")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Choose difficulty and begin")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.3))
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                )
            }
            
            Button(action: {
                showLevelSelector = true
            }) {
                HStack {
                    Image(systemName: "square.grid.3x3.fill")
                        .font(.system(size: 18))
                    Text("Select Level")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                )
            }
            .sheet(isPresented: $showLevelSelector) {
                LevelSelectorView(levels: levels, selectedLevel: $selectedLevel)
            }
        }
    }
    
    private var achievementsPreview: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Achievements")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text("\(gameViewModel.userProgress.achievements.filter { $0.isUnlocked }.count)/\(DataService.shared.getDefaultAchievements().count)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(DataService.shared.getDefaultAchievements().prefix(5)) { achievement in
                        AchievementBadge(achievement: achievement, isUnlocked: gameViewModel.userProgress.achievements.contains { $0.id == achievement.id && $0.isUnlocked })
                    }
                }
            }
        }
    }
    
    private var dailyChallengeCard: some View {
        let challenge = DataService.shared.getDailyChallenge()
        
        return Button(action: {
            showDailyChallenge = true
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(hex: currentTheme.accentColor).opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: challenge.isCompleted ? "checkmark.circle.fill" : "calendar")
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: currentTheme.accentColor))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Daily Challenge")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: currentTheme.accentColor))
                    
                    Text(challenge.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 12))
                        Text("+\(challenge.reward) coins")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
        }
        .opacity(challenge.isCompleted ? 0.5 : 1.0)
        .disabled(challenge.isCompleted)
    }
    
    private var leaderboardPreview: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Leaderboard")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Button(action: {
                    showLeaderboard = true
                }) {
                    Text("View All")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: currentTheme.accentColor))
                }
            }
            
            let leaderboard = DataService.shared.getLeaderboard().prefix(3)
            
            if leaderboard.isEmpty {
                Text("No entries yet. Play to get on the leaderboard!")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 16)
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(leaderboard.enumerated()), id: \.element.id) { index, entry in
                        LeaderboardRow(entry: entry, rank: index + 1, accentColor: currentTheme.accentColor)
                    }
                }
            }
        }
    }
    
    private func loadLevels() {
        levels = DataService.shared.loadLevels()
        // Update unlock status based on user progress
        levels = levels.map { level in
            GameLevel(
                id: level.id,
                levelNumber: level.levelNumber,
                title: level.title,
                description: level.description,
                difficulty: level.difficulty,
                targetScore: level.targetScore,
                timeLimit: level.timeLimit,
                puzzlePattern: level.puzzlePattern,
                isUnlocked: level.levelNumber <= gameViewModel.userProgress.highestLevelUnlocked
            )
        }
    }
    
    private func getCurrentLevel() -> GameLevel? {
        return levels.first { $0.levelNumber == gameViewModel.userProgress.currentLevel }
    }
    
    private func loadCoins() {
        coins = DataService.shared.getCoins()
    }
    
    private func loadTheme() {
        currentTheme = DataService.shared.getSelectedTheme()
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct LevelCard: View {
    let level: GameLevel
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Level icon
                ZStack {
                    Circle()
                        .fill(Color(hex: "FE284A").opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Text("\(level.levelNumber)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "FE284A"))
                }
                
                // Level info
                VStack(alignment: .leading, spacing: 6) {
                    Text(level.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(level.description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(2)
                    
                    HStack(spacing: 8) {
                        DifficultyBadge(difficulty: level.difficulty)
                        
                        if let timeLimit = level.timeLimit {
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 10))
                                Text("\(Int(timeLimit))s")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
        }
    }
}

struct DifficultyBadge: View {
    let difficulty: GameLevel.Difficulty
    
    var body: some View {
        Text(difficulty.rawValue)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(difficultyColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(difficultyColor.opacity(0.2))
            )
    }
    
    private var difficultyColor: Color {
        switch difficulty {
        case .easy:
            return .green
        case .medium:
            return .yellow
        case .hard:
            return .orange
        case .expert:
            return .red
        }
    }
}

struct AchievementBadge: View {
    let achievement: Achievement
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color(hex: "FE284A").opacity(0.2) : Color.white.opacity(0.05))
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isUnlocked ? Color(hex: "FE284A") : .white.opacity(0.3))
            }
            
            Text(achievement.title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(isUnlocked ? 1.0 : 0.5))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 80)
        }
    }
}

// MARK: - Level Selector View

struct LevelSelectorView: View {
    let levels: [GameLevel]
    @Binding var selectedLevel: GameLevel?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1D1F30")
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(levels) { level in
                            LevelGridItem(level: level) {
                                if level.isUnlocked {
                                    selectedLevel = level
                                    dismiss()
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Select Level")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "FE284A"))
                }
            }
        }
    }
}

struct LevelGridItem: View {
    let level: GameLevel
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(level.isUnlocked ? Color(hex: "FE284A").opacity(0.2) : Color.white.opacity(0.05))
                        .frame(width: 60, height: 60)
                    
                    if level.isUnlocked {
                        Text("\(level.levelNumber)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "FE284A"))
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.3))
                    }
                }
                
                Text(level.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(level.isUnlocked ? 1.0 : 0.5))
                    .lineLimit(1)
                
                DifficultyBadge(difficulty: level.difficulty)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
        }
        .disabled(!level.isUnlocked)
    }
}

struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    let rank: Int
    let accentColor: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text("#\(rank)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(rankColor)
                .frame(width: 40, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.playerName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Level \(entry.level) • \(entry.difficulty)")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Text("\(entry.score)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: accentColor))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return Color(hex: "FFD700") // Gold
        case 2: return Color(hex: "C0C0C0") // Silver
        case 3: return Color(hex: "CD7F32") // Bronze
        default: return .white.opacity(0.6)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

