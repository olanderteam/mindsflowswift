//
//  CollapseModeView.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import SwiftUI

/// View para configurar e gerenciar o modo colapso minimalista
struct CollapseModeView: View {
    @StateObject private var viewModel = CollapseModeViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header explicativo
                    headerSection
                    
                    // Toggle principal
                    mainToggleSection
                    
                    // Configurações do modo colapso
                    if viewModel.isCollapseMode {
                        configurationSection
                    }
                    
                    // Preview do modo
                    previewSection
                    
                    // Benefícios
                    benefitsSection
                }
                .padding()
            }
            .navigationTitle("Modo Colapso")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Concluído") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "eye.slash.fill")
                .font(.system(size: 40))
                .foregroundColor(.purple)
            
            Text("Modo Colapso Minimalista")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Reduza distrações visuais e foque no essencial. Perfeito para momentos de baixa energia ou quando você precisa de máxima concentração.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.purple.opacity(0.1))
        )
    }
    
    // MARK: - Main Toggle Section
    
    private var mainToggleSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ativar Modo Colapso")
                        .font(.headline)
                    
                    Text("Interface minimalista e focada")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $viewModel.isCollapseMode)
                    .toggleStyle(SwitchToggleStyle(tint: .purple))
            }
            
            if viewModel.isCollapseMode {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                    
                    Text("O modo colapso está ativo. A interface será simplificada para reduzir distrações.")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Configuration Section
    
    private var configurationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Configurações")
                .font(.headline)
            
            VStack(spacing: 12) {
                // Ocultar estatísticas
                ConfigToggleRow(
                    title: "Ocultar Estatísticas",
                    description: "Remove gráficos e números do dashboard",
                    icon: "chart.bar.xaxis",
                    isOn: $viewModel.hideStatistics
                )
                
                // Simplificar navegação
                ConfigToggleRow(
                    title: "Navegação Simplificada",
                    description: "Reduz ícones e textos da navegação",
                    icon: "sidebar.left",
                    isOn: $viewModel.simplifyNavigation
                )
                
                // Ocultar sugestões
                ConfigToggleRow(
                    title: "Ocultar Sugestões",
                    description: "Remove recomendações automáticas",
                    icon: "lightbulb",
                    isOn: $viewModel.hideSuggestions
                )
                
                // Modo escuro forçado
                ConfigToggleRow(
                    title: "Forçar Modo Escuro",
                    description: "Ativa automaticamente o tema escuro",
                    icon: "moon.fill",
                    isOn: $viewModel.forceDarkMode
                )
                
                // Reduzir animações
                ConfigToggleRow(
                    title: "Reduzir Animações",
                    description: "Minimiza transições e efeitos visuais",
                    icon: "slowmo",
                    isOn: $viewModel.reduceAnimations
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Preview Section
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preview")
                .font(.headline)
            
            if viewModel.isCollapseMode {
                CollapseModePreview(
                    hideStatistics: viewModel.hideStatistics,
                    simplifyNavigation: viewModel.simplifyNavigation,
                    hideSuggestions: viewModel.hideSuggestions
                )
            } else {
                Text("Ative o modo colapso para ver o preview")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Benefits Section
    
    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Benefícios")
                .font(.headline)
            
            VStack(spacing: 8) {
                BenefitRow(
                    icon: "brain.head.profile",
                    title: "Reduz Sobrecarga Cognitiva",
                    description: "Menos elementos visuais para processar"
                )
                
                BenefitRow(
                    icon: "target",
                    title: "Aumenta o Foco",
                    description: "Interface limpa para máxima concentração"
                )
                
                BenefitRow(
                    icon: "battery.100",
                    title: "Economiza Energia Mental",
                    description: "Ideal para momentos de baixa energia"
                )
                
                BenefitRow(
                    icon: "speedometer",
                    title: "Melhora Performance",
                    description: "Interface mais rápida e responsiva"
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Supporting Views

/// Row para configurações de toggle
struct ConfigToggleRow: View {
    let title: String
    let description: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.purple)
                .frame(width: 25)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: .purple))
        }
        .padding(.vertical, 4)
    }
}

/// Preview do modo colapso
struct CollapseModePreview: View {
    let hideStatistics: Bool
    let simplifyNavigation: Bool
    let hideSuggestions: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            // Header simulado
            HStack {
                Text("Dashboard")
                    .font(.caption)
                    .fontWeight(.bold)
                
                Spacer()
                
                if !simplifyNavigation {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 6, height: 6)
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 6, height: 6)
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 6, height: 6)
                    }
                }
            }
            
            // Conteúdo simulado
            VStack(spacing: 6) {
                if !hideStatistics {
                    HStack(spacing: 4) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 20)
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 20)
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 20)
                    }
                }
                
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(height: 30)
                
                if !hideSuggestions {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 20)
                }
            }
            
            // Navegação simulada
            HStack {
                ForEach(0..<(simplifyNavigation ? 3 : 5), id: \.self) { _ in
                    Circle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: simplifyNavigation ? 8 : 12, height: simplifyNavigation ? 8 : 12)
                }
            }
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(8)
    }
}

/// Row para benefícios
struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.green)
                .frame(width: 25)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

struct CollapseModeView_Previews: PreviewProvider {
    static var previews: some View {
        CollapseModeView()
    }
}