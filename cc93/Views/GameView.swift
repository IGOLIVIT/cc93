//
//  GameView.swift
//  Luminal Quest
//
//  Created by Luminal Quest Team
//

import SwiftUI

struct GameView: View {
    let level: GameLevel
    @ObservedObject var gameViewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "1D1F30")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                gameHeader
                
                // Game area
                GeometryReader { geometry in
                    ZStack {
                        // Puzzle nodes
                        ForEach(level.puzzlePattern) { node in
                            NodeView(
                                node: node,
                                isSelected: gameViewModel.selectedNodes.contains { $0.id == node.id },
                                geometry: geometry
                            )
                            .onTapGesture {
                                gameViewModel.handleNodeTap(node)
                            }
                        }
                        
                        // Connection lines
                        ConnectionLinesView(
                            nodes: level.puzzlePattern,
                            selectedNodes: gameViewModel.selectedNodes,
                            geometry: geometry
                        )
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation
                            }
                            .onEnded { value in
                                gameViewModel.handleSwipeGesture(
                                    from: value.startLocation,
                                    to: value.location
                                )
                                dragOffset = .zero
                            }
                    )
                }
                
                // Score panel
                scorePanel
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
                Text("Target")
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
                        Text("Resume")
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
            // Victory icon
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
            
            // Stars
            HStack(spacing: 12) {
                ForEach(0..<3) { index in
                    Image(systemName: index < stars ? "star.fill" : "star")
                        .font(.system(size: 32))
                        .foregroundColor(index < stars ? Color(hex: "FE284A") : .white.opacity(0.3))
                }
            }
            
            // Stats
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
            }
            .font(.system(size: 18))
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
            )
            .padding(.horizontal, 40)
            
            // Buttons
            VStack(spacing: 12) {
                Button(action: {
                    gameViewModel.exitGame()
                    dismiss()
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
            }
            .padding(.horizontal, 40)
        }
    }
    
    private func defeatView(reason: String) -> some View {
        VStack(spacing: 24) {
            // Defeat icon
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
            }
            
            Text("Level Failed")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            
            Text(reason)
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.7))
            
            // Buttons
            VStack(spacing: 12) {
                Button(action: {
                    gameViewModel.resetGame()
                }) {
                    Text("Try Again")
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

// MARK: - Node View

struct NodeView: View {
    let node: PuzzleNode
    let isSelected: Bool
    let geometry: GeometryProxy
    
    var body: some View {
        ZStack {
            Circle()
                .fill(nodeColor.opacity(isSelected ? 1.0 : 0.8))
                .frame(width: 50, height: 50)
            
            if isSelected {
                Circle()
                    .stroke(Color.white, lineWidth: 3)
                    .frame(width: 50, height: 50)
            }
            
            Image(systemName: nodeIcon)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(width: 50, height: 50)
        .position(
            x: geometry.size.width * node.position.x,
            y: geometry.size.height * node.position.y
        )
        .contentShape(Circle().size(width: 50, height: 50))
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

// MARK: - Connection Lines View

struct ConnectionLinesView: View {
    let nodes: [PuzzleNode]
    let selectedNodes: [PuzzleNode]
    let geometry: GeometryProxy
    
    var body: some View {
        Canvas { context, size in
            // Draw all connections
            for node in nodes {
                for connectionId in node.connections {
                    if let connectedNode = nodes.first(where: { $0.id == connectionId }) {
                        let start = CGPoint(
                            x: size.width * node.position.x,
                            y: size.height * node.position.y
                        )
                        let end = CGPoint(
                            x: size.width * connectedNode.position.x,
                            y: size.height * connectedNode.position.y
                        )
                        
                        var path = Path()
                        path.move(to: start)
                        path.addLine(to: end)
                        
                        context.stroke(
                            path,
                            with: .color(.white.opacity(0.2)),
                            lineWidth: 2
                        )
                    }
                }
            }
            
            // Draw selected path
            if selectedNodes.count > 1 {
                var path = Path()
                let firstNode = selectedNodes[0]
                let firstPoint = CGPoint(
                    x: size.width * firstNode.position.x,
                    y: size.height * firstNode.position.y
                )
                path.move(to: firstPoint)
                
                for node in selectedNodes.dropFirst() {
                    let point = CGPoint(
                        x: size.width * node.position.x,
                        y: size.height * node.position.y
                    )
                    path.addLine(to: point)
                }
                
                context.stroke(
                    path,
                    with: .color(Color(hex: "FE284A")),
                    lineWidth: 4
                )
            }
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(
            level: GameLevel(
                levelNumber: 1,
                title: "Test Level",
                description: "Test",
                difficulty: .easy,
                targetScore: 100,
                isUnlocked: true
            ),
            gameViewModel: GameViewModel()
        )
    }
}

