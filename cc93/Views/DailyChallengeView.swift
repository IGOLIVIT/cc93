//
//  DailyChallengeView.swift
//  Luminal Quest
//
//  Created by Luminal Quest Team
//

import SwiftUI

struct DailyChallengeView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var gameViewModel = GameViewModel()
    @State private var challenge: DailyChallenge = DataService.shared.getDailyChallenge()
    @State private var showGame = false
    @State private var challengeLevel: GameLevel?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1D1F30")
                    .ignoresSafeArea()
                
                if showGame, let level = challengeLevel {
                    SimplifiedGameView(level: level, gameViewModel: gameViewModel)
                        .onDisappear {
                            // Check if challenge was completed when game view closes
                            if case .victory = gameViewModel.gameResult {
                                if !challenge.isCompleted {
                                    DataService.shared.completeDailyChallenge()
                                    challenge = DataService.shared.getDailyChallenge()
                                }
                            }
                        }
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Challenge Icon
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "FE284A").opacity(0.2))
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: challenge.isCompleted ? "checkmark.circle.fill" : "calendar")
                                    .font(.system(size: 60))
                                    .foregroundColor(Color(hex: "FE284A"))
                            }
                            .padding(.top, 40)
                            
                            // Challenge Info
                            VStack(spacing: 12) {
                                Text("Daily Challenge")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(hex: "FE284A"))
                                
                                Text(challenge.title)
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                
                                Text(challenge.description)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.6))
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.horizontal, 32)
                            
                            // Stats
                            VStack(spacing: 16) {
                                DailyChallengeStatRow(icon: "target", label: "Target Score", value: "\(challenge.targetScore)")
                                DailyChallengeStatRow(icon: "clock.fill", label: "Time Limit", value: "\(Int(challenge.timeLimit))s")
                                DailyChallengeStatRow(icon: "dollarsign.circle.fill", label: "Reward", value: "\(challenge.reward) coins")
                                
                                DifficultyBadge(difficulty: challenge.difficulty)
                                    .frame(maxWidth: .infinity)
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.05))
                            )
                            .padding(.horizontal, 20)
                            
                            // Start Button
                            if challenge.isCompleted {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20))
                                    Text("Completed Today!")
                                        .font(.system(size: 18, weight: .bold))
                                }
                                .foregroundColor(.green)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.green.opacity(0.2))
                                )
                                .padding(.horizontal, 20)
                            } else {
                                Button(action: {
                                    // Generate level once and save it
                                    challengeLevel = createChallengeLevel()
                                    showGame = true
                                }) {
                                    HStack {
                                        Image(systemName: "play.fill")
                                            .font(.system(size: 20))
                                        Text("Start Challenge")
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
                                .padding(.horizontal, 20)
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
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
    
    private func createChallengeLevel() -> GameLevel {
        return DataService.shared.generateLevel(
            difficulty: challenge.difficulty,
            levelNumber: 999 // Special number for daily challenge
        )
    }
}

struct DailyChallengeStatRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color(hex: "FE284A"))
                .frame(width: 30)
            
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.6))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

