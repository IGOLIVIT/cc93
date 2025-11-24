//
//  SettingsViewModel.swift
//  Luminal Quest
//
//  Created by Luminal Quest Team
//

import SwiftUI
import UIKit
import Combine

class SettingsViewModel: ObservableObject {
    @AppStorage("sound_enabled") var soundEnabled: Bool = true
    @AppStorage("music_enabled") var musicEnabled: Bool = true
    @AppStorage("haptics_enabled") var hapticsEnabled: Bool = true
    @AppStorage("notifications_enabled") var notificationsEnabled: Bool = true
    @AppStorage("difficulty_preference") var difficultyPreference: String = "medium"
    @AppStorage("show_tutorial") var showTutorial: Bool = true
    @AppStorage("color_blind_mode") var colorBlindMode: Bool = false
    @AppStorage("reduced_motion") var reducedMotion: Bool = false
    
    @Published var showDeleteConfirmation: Bool = false
    @Published var showResetConfirmation: Bool = false
    @Published var userProgress: UserProgress
    
    private let dataService = DataService.shared
    
    init() {
        self.userProgress = dataService.loadUserProgress()
    }
    
    // MARK: - Settings Actions
    
    func toggleSound() {
        soundEnabled.toggle()
        if hapticsEnabled {
            playHaptic()
        }
    }
    
    func toggleMusic() {
        musicEnabled.toggle()
        if hapticsEnabled {
            playHaptic()
        }
    }
    
    func toggleHaptics() {
        hapticsEnabled.toggle()
    }
    
    func toggleNotifications() {
        notificationsEnabled.toggle()
        if hapticsEnabled {
            playHaptic()
        }
    }
    
    func toggleColorBlindMode() {
        colorBlindMode.toggle()
        if hapticsEnabled {
            playHaptic()
        }
    }
    
    func toggleReducedMotion() {
        reducedMotion.toggle()
        if hapticsEnabled {
            playHaptic()
        }
    }
    
    func setDifficulty(_ difficulty: String) {
        difficultyPreference = difficulty
        if hapticsEnabled {
            playHaptic()
        }
    }
    
    // MARK: - Account Management
    
    func deleteAccount() {
        // Reset all user data
        dataService.resetUserProgress()
        
        // Reset AppStorage values
        soundEnabled = true
        musicEnabled = true
        hapticsEnabled = true
        notificationsEnabled = true
        difficultyPreference = "medium"
        colorBlindMode = false
        reducedMotion = false
        
        // Reset onboarding to show again
        UserDefaults.standard.set(false, forKey: "has_completed_onboarding")
        showTutorial = true
        
        // Reload progress
        userProgress = dataService.loadUserProgress()
        
        showDeleteConfirmation = false
        
        NetworkService.shared.logEvent("account_deleted")
    }
    
    func resetProgress() {
        dataService.resetUserProgress()
        userProgress = dataService.loadUserProgress()
        showResetConfirmation = false
        
        NetworkService.shared.logEvent("progress_reset")
    }
    
    // MARK: - Helper Methods
    
    private func playHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func getProgressPercentage() -> Double {
        let totalLevels = 20 // As defined in DataService
        return Double(userProgress.completedLevels.count) / Double(totalLevels) * 100
    }
    
    func getAchievementCount() -> Int {
        return userProgress.achievements.filter { $0.isUnlocked }.count
    }
    
    func getTotalAchievements() -> Int {
        return dataService.getDefaultAchievements().count
    }
}

