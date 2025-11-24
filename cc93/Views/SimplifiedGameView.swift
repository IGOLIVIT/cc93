//
//  SimplifiedGameView.swift
//  Luminal Quest
//
//  Created by Luminal Quest Team
//

import SwiftUI

struct SimplifiedGameView: View {
    let level: GameLevel
    @ObservedObject var gameViewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showInstructions = true
    @State private var showNextLevel = false
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "1D1F30")
                .ignoresSafeArea()
            
            if showInstructions {
                instructionsOverlay
            } else {
                gameContent
            }
            
            // Pause overlay
            if gameViewModel.isGamePaused {
                pauseOverlay
            }
            
            // Result overlay
            if let result = gameViewModel.gameResult {
                resultOverlay(result: result)
            }
        }
        .onAppear {
            gameViewModel.startLevel(level)
        }
    }
    
    // MARK: - Instructions Overlay
    
    private var instructionsOverlay: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color(hex: "FE284A"))
                    
                    Text("How to Play")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    InstructionRow(
                        icon: "hand.tap.fill",
                        color: .green,
                        title: "Start",
                        description: "Tap the green node (START) to begin"
                    )
                    
                    InstructionRow(
                        icon: "arrow.right.circle.fill",
                        color: .blue,
                        title: "Path",
                        description: "Tap blue nodes in sequence, collecting points"
                    )
                    
                    InstructionRow(
                        icon: "xmark.circle.fill",
                        color: .red,
                        title: "Avoid",
                        description: "Red nodes subtract points - avoid them!"
                    )
                    
                    InstructionRow(
                        icon: "bolt.circle.fill",
                        color: .yellow,
                        title: "Bonuses",
                        description: "Yellow nodes give double points and time"
                    )
                    
                    InstructionRow(
                        icon: "flag.fill",
                        color: Color(hex: "FE284A"),
                        title: "Goal",
                        description: "Reach the pink flag to win!"
                    )
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        showInstructions = false
                    }
                }) {
                    Text("Start Game")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "FE284A"))
                        )
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
    
    // MARK: - Game Content
    
    private var gameContent: some View {
        VStack(spacing: 0) {
            // Header
            gameHeader
            
            // Instructions hint
            if gameViewModel.selectedNodes.isEmpty && gameViewModel.isGameActive {
                instructionHint
            }
            
            // Game area
            GeometryReader { geometry in
                ZStack {
                    // Connection lines (background) - не блокирует нажатия
                    ConnectionLinesView(
                        nodes: level.puzzlePattern,
                        selectedNodes: gameViewModel.selectedNodes,
                        geometry: geometry
                    )
                    .allowsHitTesting(false)
                    
                    // Puzzle nodes - используем новый подход
                    ForEach(level.puzzlePattern) { node in
                        InteractiveNodeView(
                            node: node,
                            isSelected: gameViewModel.selectedNodes.contains { $0.id == node.id },
                            geometry: geometry,
                            onTap: {
                                gameViewModel.handleNodeTap(node)
                            }
                        )
                    }
                }
            }
            
            // Score panel
            scorePanel
        }
    }
    
    private var instructionHint: some View {
        HStack(spacing: 12) {
            Image(systemName: "hand.tap.fill")
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "FE284A"))
            
            Text("Tap the green START node to begin")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "FE284A").opacity(0.2))
        )
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
    
    private var gameHeader: some View {
        HStack {
            // Pause button
            Button(action: {
                gameViewModel.pauseGame()
            }) {
                Image(systemName: "pause.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            // Level info
            VStack(spacing: 4) {
                Text(level.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                if let timeLimit = level.timeLimit {
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 12))
                        Text(formatTime(gameViewModel.timeRemaining))
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(gameViewModel.timeRemaining < 10 ? .red : .white.opacity(0.8))
                }
            }
            
            Spacer()
            
            // Combo indicator
            if gameViewModel.currentCombo > 0 {
                VStack(spacing: 2) {
                    Text("x\(gameViewModel.currentCombo)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "FE284A"))
                    Text("COMBO")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                }
            } else {
                Spacer()
                    .frame(width: 44)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(hex: "1D1F30"))
    }
    
    private var scorePanel: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Score")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                Text("\(gameViewModel.score)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Goal")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                Text("\(level.targetScore)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(hex: "FE284A"))
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
    }
    
    // MARK: - Overlays
    
    private var pauseOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("Paused")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(spacing: 16) {
                    Button(action: {
                        gameViewModel.resumeGame()
                    }) {
                        Text("Continue")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(hex: "FE284A"))
                            )
                    }
                    
                    Button(action: {
                        showInstructions = true
                        gameViewModel.resumeGame()
                    }) {
                        Text("Show Instructions")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            )
                    }
                    
                    Button(action: {
                        gameViewModel.resetGame()
                    }) {
                        Text("Restart")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            )
                    }
                    
                    Button(action: {
                        gameViewModel.exitGame()
                        dismiss()
                    }) {
                        Text("Exit")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                    }
                }
                .padding(.horizontal, 40)
            }
        }
    }
    
    private func resultOverlay(result: GameViewModel.GameResult) -> some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                switch result {
                case .victory(let score, let stars, let time):
                    victoryView(score: score, stars: stars, time: time)
                case .defeat(let reason):
                    defeatView(reason: reason)
                }
            }
        }
    }
    
    private func victoryView(score: Int, stars: Int, time: TimeInterval) -> some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color(hex: "FE284A").opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "trophy.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: "FE284A"))
            }
            
            Text("Level Complete!")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                ForEach(0..<3) { index in
                    Image(systemName: index < stars ? "star.fill" : "star")
                        .font(.system(size: 32))
                        .foregroundColor(index < stars ? Color(hex: "FE284A") : .white.opacity(0.3))
                }
            }
            
            VStack(spacing: 12) {
                HStack {
                    Text("Score:")
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text("\(score)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                
                HStack {
                    Text("Time:")
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text(formatTime(time))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                HStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(Color(hex: "FE284A"))
                    Text("Coins Earned:")
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text("+\(stars * 25 + (score / 10))")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "FE284A"))
                }
            }
            .font(.system(size: 18))
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
            )
            .padding(.horizontal, 40)
            
            VStack(spacing: 12) {
                // Next Level button
                Button(action: {
                    let nextLevel = DataService.shared.generateLevel(
                        difficulty: level.difficulty,
                        levelNumber: level.levelNumber + 1
                    )
                    gameViewModel.startLevel(nextLevel)
                }) {
                    HStack {
                        Text("Next Level")
                            .font(.system(size: 18, weight: .bold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "FE284A"))
                    )
                }
                
                Button(action: {
                    gameViewModel.resetGame()
                }) {
                    Text("Play Again")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )
                }
                
                Button(action: {
                    gameViewModel.exitGame()
                    dismiss()
                }) {
                    Text("Exit to Menu")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                }
            }
            .padding(.horizontal, 40)
        }
    }
    
    private func defeatView(reason: String) -> some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
            }
            
            Text("Failed")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            
            Text(reason)
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.7))
            
            VStack(spacing: 12) {
                Button(action: {
                    gameViewModel.resetGame()
                }) {
                    Text("Попробовать снова")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "FE284A"))
                        )
                }
                
                Button(action: {
                    gameViewModel.exitGame()
                    dismiss()
                }) {
                    Text("Exit")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )
                }
            }
            .padding(.horizontal, 40)
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Interactive Node View (новый подход)

struct InteractiveNodeView: View {
    let node: PuzzleNode
    let isSelected: Bool
    let geometry: GeometryProxy
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(nodeColor.opacity(isSelected ? 1.0 : 0.8))
                    .frame(width: 60, height: 60)
                
                if isSelected {
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 60, height: 60)
                }
                
                Image(systemName: nodeIcon)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: 60, height: 60)
        .position(
            x: geometry.size.width * node.position.x,
            y: geometry.size.height * node.position.y
        )
    }
    
    private var nodeColor: Color {
        switch node.nodeType {
        case .start:
            return Color.green
        case .checkpoint:
            return Color.blue
        case .obstacle:
            return Color.red
        case .goal:
            return Color(hex: "FE284A")
        case .powerup:
            return Color.yellow
        }
    }
    
    private var nodeIcon: String {
        switch node.nodeType {
        case .start:
            return "play.fill"
        case .checkpoint:
            return "checkmark"
        case .obstacle:
            return "xmark"
        case .goal:
            return "flag.fill"
        case .powerup:
            return "bolt.fill"
        }
    }
}

// MARK: - Instruction Row

struct InstructionRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
