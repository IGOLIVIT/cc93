//
//  ThemeShopView.swift
//  Luminal Quest
//
//  Created by Luminal Quest Team
//

import SwiftUI

struct ThemeShopView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var currentTheme: Theme
    @Binding var coins: Int
    @State private var themes: [Theme] = []
    @State private var showPurchaseAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: currentTheme.backgroundColor)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Coins Display
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: currentTheme.accentColor))
                        
                        Text("\(coins) Coins")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.05))
                    
                    // Themes Grid
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(themes) { theme in
                                ThemeCard(
                                    theme: theme,
                                    isSelected: theme.id == currentTheme.id,
                                    onTap: {
                                        if theme.isPurchased {
                                            selectTheme(theme)
                                        } else {
                                            purchaseTheme(theme)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("Theme Shop")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: currentTheme.accentColor))
                }
            }
            .alert("Theme Shop", isPresented: $showPurchaseAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                loadThemes()
            }
        }
    }
    
    private func loadThemes() {
        themes = DataService.shared.getThemes()
    }
    
    private func purchaseTheme(_ theme: Theme) {
        if DataService.shared.purchaseTheme(theme.id) {
            alertMessage = "Theme '\(theme.name)' purchased successfully!"
            loadThemes()
            coins = DataService.shared.getCoins()
        } else {
            alertMessage = "Not enough coins! You need \(theme.price) coins."
        }
        showPurchaseAlert = true
    }
    
    private func selectTheme(_ theme: Theme) {
        DataService.shared.selectTheme(theme)
        currentTheme = theme
        alertMessage = "Theme '\(theme.name)' activated!"
        showPurchaseAlert = true
    }
}

struct ThemeCard: View {
    let theme: Theme
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Theme Preview
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: theme.backgroundColor))
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: theme.accentColor), lineWidth: 3)
                        )
                    
                    VStack(spacing: 8) {
                        Image(systemName: theme.icon)
                            .font(.system(size: 30))
                            .foregroundColor(Color(hex: theme.accentColor))
                        
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.green)
                        }
                    }
                }
                
                // Theme Info
                VStack(spacing: 6) {
                    Text(theme.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    if theme.isPurchased {
                        Text(isSelected ? "Active" : "Owned")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(isSelected ? .green : .white.opacity(0.6))
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 12))
                            Text("\(theme.price)")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(Color(hex: theme.accentColor))
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
            )
        }
    }
}

