//
//  AuthView.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import SwiftUI

/// View principal que gerencia o estado de autenticação
/// Decide se mostra telas de login ou o app principal
struct AuthView: View {
    
    // MARK: - Properties
    @ObservedObject private var authManager = AuthManager.shared
    @State private var isLoading = true
    
    // MARK: - Body
    var body: some View {
        Group {
            if isLoading {
                // Tela de carregamento
                LoadingView()
            } else if authManager.isAuthenticated {
                // Usuário autenticado - mostrar app principal
                let _ = print("🔍 AuthView: User is authenticated, showing main app")
                TabView {
                    DashboardView()
                        .tabItem {
                            Label("Dashboard", systemImage: "house.fill")
                        }
                    
                    TasksView()
                        .tabItem {
                            Label("Tarefas", systemImage: "checkmark.circle.fill")
                        }
                    
                    WisdomView()
                        .tabItem {
                            Label("Wisdom", systemImage: "brain.head.profile")
                        }
                    
                    HistoryView()
                        .tabItem {
                            Label("Histórico", systemImage: "chart.line.uptrend.xyaxis")
                        }
                    
                    ProfileView()
                        .tabItem {
                            Label("Perfil", systemImage: "person.fill")
                        }
                }
            } else {
                // Usuário não autenticado - mostrar login
                let _ = print("🔍 AuthView: User is NOT authenticated, showing login")
                LoginView()
            }
        }
        .onChange(of: authManager.isAuthenticated) { newValue in
            print("🔍 AuthView: isAuthenticated changed to \(newValue)")
        }
        .onAppear {
            // Simular um pequeno delay para verificação de autenticação
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isLoading = false
            }
        }
    }
}

// MARK: - Loading View

/// Tela de carregamento inicial do app
struct LoadingView: View {
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 30) {
            
            // Logo animado
            Image(systemName: "brain.head.profile")
                .font(.system(size: 100))
                .foregroundColor(.blue)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            // Nome do app
            Text("Minds Flow")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Indicador de carregamento
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(1.2)
            
            // Texto de carregamento
            Text("Preparando sua experiência...")
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

/// View principal com navegação por abas
/// Esta é uma implementação temporária que será expandida posteriormente
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
            
            // Tarefas
            TasksView()
                    .tabItem {
                        Image(systemName: "checkmark.circle")
                        Text("Tarefas")
                    }
            
            // Wisdom
            WisdomView()
                .tabItem {
                    Image(systemName: "book")
                    Text("Wisdom")
                }
            
            // Histórico
            HistoryView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Histórico")
                }
            
            // Perfil
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Perfil")
                }
        }
        .accentColor(.blue)
    }
}


// MARK: - Preview

#Preview {
    AuthView()
}