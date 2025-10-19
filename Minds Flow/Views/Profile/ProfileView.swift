//
//  ProfileView.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import SwiftUI

/// View principal do perfil do usuário
struct ProfileView: View {
    @ObservedObject private var authManager = AuthManager.shared
    @StateObject private var collapseModeViewModel = CollapseModeViewModel()
    @State private var showingCollapseModeSettings = false
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header do perfil
                    profileHeaderSection
                    
                    // Configurações rápidas
                    quickSettingsSection
                    
                    // Configurações avançadas
                    advancedSettingsSection
                    
                    // Sobre o app
                    aboutSection
                    
                    // Logout
                    logoutSection
                }
                .padding()
            }
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingCollapseModeSettings) {
            CollapseModeView()
        }
        .alert("Sair da Conta", isPresented: $showingLogoutAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Sair", role: .destructive) {
                _Concurrency.Task {
                    try? await AuthManager.shared.signOut()
                }
            }
        } message: {
            Text("Tem certeza que deseja sair da sua conta?")
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
            
            // Nome e email
            VStack(spacing: 4) {
                Text(authManager.userProfile?.name ?? "Usuário")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(authManager.currentUser?.email ?? "usuario@exemplo.com")
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
            Text("Configurações Rápidas")
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
                    title: "Notificações",
                    subtitle: "Lembretes e atualizações",
                    color: .orange,
                    hasToggle: false
                ) {
                    // TODO: Implementar configurações de notificação
                }
                
                // Tema
                SettingsRow(
                    icon: "paintbrush.fill",
                    title: "Tema",
                    subtitle: "Aparência do app",
                    color: .blue,
                    hasToggle: false
                ) {
                    // TODO: Implementar configurações de tema
                }
            }
        }
    }
    
    // MARK: - Advanced Settings
    
    private var advancedSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Configurações Avançadas")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                // Dados e privacidade
                SettingsRow(
                    icon: "lock.shield.fill",
                    title: "Dados e Privacidade",
                    subtitle: "Controle seus dados",
                    color: .green,
                    hasToggle: false
                ) {
                    // TODO: Implementar configurações de privacidade
                }
                
                // Backup e sincronização
                SettingsRow(
                    icon: "icloud.fill",
                    title: "Backup e Sincronização",
                    subtitle: "Mantenha seus dados seguros",
                    color: .blue,
                    hasToggle: false
                ) {
                    // TODO: Implementar configurações de backup
                }
                
                // Exportar dados
                SettingsRow(
                    icon: "square.and.arrow.up.fill",
                    title: "Exportar Dados",
                    subtitle: "Baixe uma cópia dos seus dados",
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
            Text("Sobre")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                // Versão do app
                SettingsRow(
                    icon: "info.circle.fill",
                    title: "Versão do App",
                    subtitle: "1.0.0 (Build 1)",
                    color: .gray,
                    hasToggle: false
                ) {
                    // Não faz nada
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
                
                // Política de privacidade
                SettingsRow(
                    icon: "hand.raised.fill",
                    title: "Política de Privacidade",
                    subtitle: "Como protegemos seus dados",
                    color: .teal,
                    hasToggle: false
                ) {
                    // TODO: Mostrar política de privacidade
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
                
                Text("Sair da Conta")
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

/// Row para configurações
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