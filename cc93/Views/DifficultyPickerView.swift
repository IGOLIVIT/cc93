//
//  DifficultyPickerView.swift
//  Luminal Quest
//
//  Created by Luminal Quest Team
//

import SwiftUI

struct DifficultyPickerView: View {
    @Binding var selectedDifficulty: GameLevel.Difficulty
    let onStart: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1D1F30")
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    VStack(spacing: 16) {
                        Image(systemName: "speedometer")
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: "FE284A"))
                        
                        Text("Choose Difficulty")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Each difficulty affects time and obstacles")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.top, 40)
                    
                    VStack(spacing: 16) {
                        DifficultyCard(
                            difficulty: .easy,
                            isSelected: selectedDifficulty == .easy,
                            description: "More time, fewer obstacles"
                        ) {
                            selectedDifficulty = .easy
                        }
                        
                        DifficultyCard(
                            difficulty: .medium,
                            isSelected: selectedDifficulty == .medium,
                            description: "Balanced gameplay"
                        ) {
                            selectedDifficulty = .medium
                        }
                        
                        DifficultyCard(
                            difficulty: .hard,
                            isSelected: selectedDifficulty == .hard,
                            description: "Less time, more obstacles"
                        ) {
                            selectedDifficulty = .hard
                        }
                        
                        DifficultyCard(
                            difficulty: .expert,
                            isSelected: selectedDifficulty == .expert,
                            description: "For true masters!"
                        ) {
                            selectedDifficulty = .expert
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    Button(action: {
                        onStart()
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
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
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
}

struct DifficultyCard: View {
    let difficulty: GameLevel.Difficulty
    let isSelected: Bool
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(difficultyColor.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(difficultyColor)
                    } else {
                        Image(systemName: "circle")
                            .font(.system(size: 28))
                            .foregroundColor(difficultyColor.opacity(0.5))
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(difficultyName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                difficultyBadge
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? difficultyColor.opacity(0.1) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? difficultyColor : Color.clear, lineWidth: 2)
                    )
            )
        }
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
    
    private var difficultyName: String {
        switch difficulty {
        case .easy:
            return "Easy"
        case .medium:
            return "Medium"
        case .hard:
            return "Hard"
        case .expert:
            return "Expert"
        }
    }
    
    private var difficultyBadge: some View {
        HStack(spacing: 2) {
            ForEach(0..<difficultyLevel, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundColor(difficultyColor)
            }
        }
    }
    
    private var difficultyLevel: Int {
        switch difficulty {
        case .easy: return 1
        case .medium: return 2
        case .hard: return 3
        case .expert: return 4
        }
    }
}

struct DifficultyPickerView_Previews: PreviewProvider {
    static var previews: some View {
        DifficultyPickerView(
            selectedDifficulty: .constant(.easy),
            onStart: {}
        )
    }
}

