//
//  AuthView.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import SwiftUI

/// Main view that manages authentication state
/// Decides whether to show login screens or main app
struct AuthView: View {
    
    // MARK: - Properties
    @ObservedObject private var authManager = AuthManager.shared
    @State private var isLoading = true
    
    // MARK: - Body
    var body: some View {
        Group {
            if isLoading {
                // Loading screen
                LoadingView()
            } else if authManager.isAuthenticated {
                // Authenticated user - show main app
                let _ = print("🔍 AuthView: User is authenticated, showing main app")
                TabView {
                    DashboardView()
                        .tabItem {
                            Label("Dashboard", systemImage: "house.fill")
                        }
                    
                    TasksView()
                        .tabItem {
                            Label("Tasks", systemImage: "checkmark.circle.fill")
                        }
                    
                    WisdomView()
                        .tabItem {
                            Label("Wisdom", systemImage: "brain.head.profile")
                        }
                    
                    HistoryView()
                        .tabItem {
                            Label("History", systemImage: "chart.line.uptrend.xyaxis")
                        }
                    
                    ProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person.fill")
                        }
                }
            } else {
                // Unauthenticated user - show login
                let _ = print("🔍 AuthView: User is NOT authenticated, showing login")
                LoginView()
            }
        }
        .onChange(of: authManager.isAuthenticated) { newValue in
            print("🔍 AuthView: isAuthenticated changed to \(newValue)")
        }
        .onAppear {
            // Simulate a small delay for authentication verification
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isLoading = false
            }
        }
    }
}

// MARK: - Loading View

/// Initial app loading screen
struct LoadingView: View {
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 30) {
            
            // Animated logo
            Image(systemName: "brain.head.profile")
                .font(.system(size: 100))
                .foregroundColor(.blue)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            // App name
            Text("Minds Flow")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Loading indicator
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(1.2)
            
            // Loading text
            Text("Preparing your experience...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Main Tab View (Placeholder)

/// Main view with tab navigation
/// This is a temporary implementation that will be expanded later
struct MainTabView: View {
    
    @StateObject private var supabaseManager = SupabaseManager.shared
    
    var body: some View {
        TabView {
            
            // Dashboard
            DashboardView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Dashboard")
                }
            
            // Tasks
            TasksView()
                    .tabItem {
                        Image(systemName: "checkmark.circle")
                        Text("Tasks")
                    }
            
            // Wisdom
            WisdomView()
                .tabItem {
                    Image(systemName: "book")
                    Text("Wisdom")
                }
            
            // History
            HistoryView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("History")
                }
            
            // Profile
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
        }
        .accentColor(.blue)
    }
}


// MARK: - Preview

#Preview {
    AuthView()
}