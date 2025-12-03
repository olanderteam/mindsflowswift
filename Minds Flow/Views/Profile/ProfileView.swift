//
//  ProfileView.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import SwiftUI

/// Main view of user profile
struct ProfileView: View {
    @ObservedObject private var authManager = AuthManager.shared
    @StateObject private var collapseModeViewModel = CollapseModeViewModel()
    @State private var showingCollapseModeSettings = false
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile header
                    profileHeaderSection
                    
                    // Quick settings
                    quickSettingsSection
                    
                    // Advanced settings
                    advancedSettingsSection
                    
                    // About the app
                    aboutSection
                    
                    // Logout
                    logoutSection
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingCollapseModeSettings) {
            CollapseModeView()
        }
        .alert("Sign Out", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                _Concurrency.Task {
                    try? await AuthManager.shared.signOut()
                }
            }
        } message: {
            Text("Are you sure you want to sign out of your account?")
        }
    }
    
    // MARK: - Profile Header
    
    private var profileHeaderSection: some View {
        VStack(spacing: 16) {
            // Avatar
            Circle()
                .fill(Color.blue.gradient)
                .frame(width: 80, height: 80)
                .overlay {
                    Text(authManager.userProfile?.initials ?? authManager.currentUser?.email?.prefix(1).uppercased() ?? "U")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            
            // Name and email
            VStack(spacing: 4) {
                Text(authManager.userProfile?.name ?? "User")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(authManager.currentUser?.email ?? "user@example.com")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Status do modo colapso
            if collapseModeViewModel.isCollapseMode {
                HStack(spacing: 6) {
                    Image(systemName: "eye.slash.fill")
                        .font(.caption)
                    Text("Modo Colapso Ativo")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.purple.opacity(0.1))
                .foregroundColor(.purple)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    // MARK: - Quick Settings
    
    private var quickSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Settings")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                // Modo colapso
                SettingsRow(
                    icon: "eye.slash.fill",
                    title: "Modo Colapso",
                    subtitle: collapseModeViewModel.isCollapseMode ? "Ativo" : "Inativo",
                    color: .purple,
                    hasToggle: true,
                    isToggleOn: $collapseModeViewModel.isCollapseMode
                ) {
                    showingCollapseModeSettings = true
                }
                
                // Notificações
                SettingsRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    subtitle: "Reminders and updates",
                    color: .orange,
                    hasToggle: false
                ) {
                    // TODO: Implement notification settings
                }
                
                // Theme
                SettingsRow(
                    icon: "paintbrush.fill",
                    title: "Theme",
                    subtitle: "App appearance",
                    color: .blue,
                    hasToggle: false
                ) {
                    // TODO: Implement theme settings
                }
            }
        }
    }
    
    // MARK: - Advanced Settings
    
    private var advancedSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Advanced Settings")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                // Data and privacy
                SettingsRow(
                    icon: "lock.shield.fill",
                    title: "Data and Privacy",
                    subtitle: "Control your data",
                    color: .green,
                    hasToggle: false
                ) {
                    // TODO: Implement privacy settings
                }
                
                // Backup and synchronization
                SettingsRow(
                    icon: "icloud.fill",
                    title: "Backup and Sync",
                    subtitle: "Keep your data safe",
                    color: .blue,
                    hasToggle: false
                ) {
                    // TODO: Implement backup settings
                }
                
                // Export data
                SettingsRow(
                    icon: "square.and.arrow.up.fill",
                    title: "Export Data",
                    subtitle: "Download a copy of your data",
                    color: .indigo,
                    hasToggle: false
                ) {
                    // TODO: Implementar exportação de dados
                }
            }
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                // App version
                SettingsRow(
                    icon: "info.circle.fill",
                    title: "App Version",
                    subtitle: "1.0.0 (Build 1)",
                    color: .gray,
                    hasToggle: false
                ) {
                    // Does nothing
                }
                
                // Termos de uso
                SettingsRow(
                    icon: "doc.text.fill",
                    title: "Termos de Uso",
                    subtitle: "Leia nossos termos",
                    color: .brown,
                    hasToggle: false
                ) {
                    // TODO: Mostrar termos de uso
                }
                
                // Privacy policy
                SettingsRow(
                    icon: "hand.raised.fill",
                    title: "Privacy Policy",
                    subtitle: "How we protect your data",
                    color: .teal,
                    hasToggle: false
                ) {
                    // TODO: Show privacy policy
                }
            }
        }
    }
    
    // MARK: - Logout Section
    
    private var logoutSection: some View {
        Button(action: { showingLogoutAlert = true }) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.title3)
                    .foregroundColor(.red)
                
                Text("Sign Out")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.red)
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.red.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Supporting Views

/// Row for settings
struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let hasToggle: Bool
    @Binding var isToggleOn: Bool
    let action: () -> Void
    
    init(
        icon: String,
        title: String,
        subtitle: String,
        color: Color,
        hasToggle: Bool,
        isToggleOn: Binding<Bool> = .constant(false),
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.color = color
        self.hasToggle = hasToggle
        self._isToggleOn = isToggleOn
        self.action = action
    }
    
    var body: some View {
        Button(action: hasToggle ? {} : action) {
            HStack(spacing: 12) {
                // Ícone
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 25)
                
                // Conteúdo
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Toggle ou seta
                if hasToggle {
                    Toggle("", isOn: $isToggleOn)
                        .toggleStyle(SwitchToggleStyle(tint: color))
                        .onChange(of: isToggleOn) { _ in
                            action()
                        }
                } else {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}