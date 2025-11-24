//
//  SettingsView.swift
//  Luminal Quest
//
//  Created by Luminal Quest Team
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1D1F30")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Stats Section
                        statsSection
                        
                        // Game Settings
                        gameSettingsSection
                        
                        // Account Actions
                        accountSection
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "FE284A"))
                }
            }
            .alert("Delete Account", isPresented: $viewModel.showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    viewModel.deleteAccount()
                    dismiss()
                }
            } message: {
                Text("This will reset all your progress and return you to the onboarding screen. This action cannot be undone.")
            }
            .alert("Reset Progress", isPresented: $viewModel.showResetConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    viewModel.resetProgress()
                }
            } message: {
                Text("This will reset all your game progress, scores, and achievements. This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Sections
    
    private var statsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Your Stats")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(spacing: 12) {
                StatRow(
                    title: "Total Score",
                    value: "\(viewModel.userProgress.totalScore)",
                    icon: "star.fill",
                    color: Color(hex: "FE284A")
                )
                
                StatRow(
                    title: "Levels Completed",
                    value: "\(viewModel.userProgress.completedLevels.count)/20",
                    icon: "flag.fill",
                    color: Color.blue
                )
                
                StatRow(
                    title: "Achievements",
                    value: "\(viewModel.getAchievementCount())/\(viewModel.getTotalAchievements())",
                    icon: "trophy.fill",
                    color: Color.yellow
                )
                
                StatRow(
                    title: "Games Played",
                    value: "\(viewModel.userProgress.gamesPlayed)",
                    icon: "gamecontroller.fill",
                    color: Color.green
                )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
        }
    }
    
    private var gameSettingsSection: some View {
        SettingsSection(title: "Game Settings") {
            SettingsToggle(
                title: "Haptic Feedback",
                icon: "iphone.radiowaves.left.and.right",
                isOn: $viewModel.hapticsEnabled,
                action: { viewModel.toggleHaptics() }
            )
        }
    }
    
    private var accountSection: some View {
        SettingsSection(title: "Data") {
            SettingsButton(
                title: "Reset Progress",
                icon: "arrow.counterclockwise",
                color: .orange,
                action: {
                    viewModel.showResetConfirmation = true
                }
            )
            
            SettingsButton(
                title: "Start Over (Delete Account)",
                icon: "trash.fill",
                color: .red,
                action: {
                    viewModel.showDeleteConfirmation = true
                }
            )
        }
    }
}

// MARK: - Supporting Views

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(spacing: 0) {
                content
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
        }
    }
}

struct SettingsToggle: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "FE284A"))
                .frame(width: 32)
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color(hex: "FE284A"))
                .onChange(of: isOn) { _ in
                    action()
                }
        }
        .padding(.vertical, 8)
    }
}

struct SettingsButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 32)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(.vertical, 8)
        }
    }
}

struct StatRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 32)
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.vertical, 8)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

