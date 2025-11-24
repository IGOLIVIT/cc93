//
//  LeaderboardView.swift
//  Luminal Quest
//
//  Created by Luminal Quest Team
//

import SwiftUI

struct LeaderboardView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var leaderboard: [LeaderboardEntry] = []
    @State private var selectedFilter: LeaderboardFilter = .all
    
    enum LeaderboardFilter: String, CaseIterable {
        case all = "All Time"
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
        case expert = "Expert"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1D1F30")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(LeaderboardFilter.allCases, id: \.self) { filter in
                                FilterButton(
                                    title: filter.rawValue,
                                    isSelected: selectedFilter == filter,
                                    action: {
                                        selectedFilter = filter
                                        loadLeaderboard()
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.1))
                    
                    // Leaderboard List
                    if leaderboard.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "list.bullet.clipboard")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.3))
                            
                            Text("No Entries Yet")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Play games to appear on the leaderboard!")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(40)
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(Array(leaderboard.enumerated()), id: \.element.id) { index, entry in
                                    LeaderboardRow(entry: entry, rank: index + 1, accentColor: "FE284A")
                                }
                            }
                            .padding(20)
                        }
                    }
                }
            }
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "FE284A"))
                }
            }
            .onAppear {
                loadLeaderboard()
            }
        }
    }
    
    private func loadLeaderboard() {
        let allEntries = DataService.shared.getLeaderboard()
        
        switch selectedFilter {
        case .all:
            leaderboard = allEntries
        case .easy:
            leaderboard = allEntries.filter { $0.difficulty.lowercased() == "easy" }
        case .medium:
            leaderboard = allEntries.filter { $0.difficulty.lowercased() == "medium" }
        case .hard:
            leaderboard = allEntries.filter { $0.difficulty.lowercased() == "hard" }
        case .expert:
            leaderboard = allEntries.filter { $0.difficulty.lowercased() == "expert" }
        }
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color(hex: "FE284A") : Color.white.opacity(0.05))
                )
        }
    }
}

