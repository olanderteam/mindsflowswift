//
//  DashboardView.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import SwiftUI

/// Main Dashboard view with mental state panel
struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @StateObject private var collapseModeViewModel = CollapseModeViewModel()
    @State private var showingMentalStateUpdate = false
    @State private var showingQuickAddTask = false
    @State private var showingQuickAddWisdom = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: collapseModeViewModel.getUIConfiguration().spacing) {
                    // Header com saudação
                    headerSection
                    
                    // Current mental state
                    currentStateSection
                    
                    // Insight diária
                    dailyInsightSection
                    
                    // Daily statistics (hide in collapse mode if configured)
                    if !collapseModeViewModel.shouldHideFeature(.statistics) {
                        dailyStatsSection
                    }
                    
                    // Suggested tasks (hide in collapse mode if configured)
                    if !viewModel.suggestedTasks.isEmpty && !collapseModeViewModel.shouldHideFeature(.suggestions) {
                        suggestedTasksSection
                    }
                    
                    // Suggested wisdom (hide in collapse mode if configured)
                    if !viewModel.suggestedWisdom.isEmpty && !collapseModeViewModel.shouldHideFeature(.suggestions) {
                        suggestedWisdomSection
                    }
                    
                    // Ações rápidas
                    quickActionsSection
                }
                .collapsePadding()
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { 
                        // Show collapse settings
                    }) {
                        Image(systemName: collapseModeViewModel.isCollapseMode ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(collapseModeViewModel.isCollapseMode ? .purple : .gray)
                    }
                }
            }
            .refreshable {
                await viewModel.loadCurrentState()
            }
            .sheet(isPresented: $showingMentalStateUpdate) {
                MentalStateUpdateView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingQuickAddTask) {
                QuickAddTaskView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingQuickAddWisdom) {
                QuickAddWisdomView(viewModel: viewModel)
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
        .collapseMode(collapseModeViewModel)
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(greetingText)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("How are you feeling hoje?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Avatar ou ícone do usuário
                Circle()
                    .fill(viewModel.currentStateColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(viewModel.currentEmotion.icon)
                            .font(.title2)
                    )
            }
        }
    }
    
    // MARK: - Current Mental State
    
    private var currentStateSection: some View {
        CollapseAwareCard {
            VStack(spacing: collapseModeViewModel.getUIConfiguration().spacing) {
                // Main mental state card
                Button(action: { showingMentalStateUpdate = true }) {
                    VStack(spacing: collapseModeViewModel.getUIConfiguration().spacing) {
                        HStack {
                            CollapseAwareText(
                                text: "Current Mental State",
                                style: .headline
                            )
                            
                            Spacer()
                            
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        
                        HStack(spacing: collapseModeViewModel.getUIConfiguration().spacing) {
                            // Energia
                            VStack(spacing: 8) {
                                if !collapseModeViewModel.simplifyNavigation {
                                    Text("Energia")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                HStack(spacing: 4) {
                                    Image(systemName: viewModel.currentEnergyLevel.icon)
                                        .font(collapseModeViewModel.isCollapseMode ? .body : .title2)
                                    Text(viewModel.currentEnergyLevel.displayName)
                                        .font(collapseModeViewModel.isCollapseMode ? .caption : .subheadline)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(viewModel.currentEnergyLevel.color)
                            }
                            
                            if !collapseModeViewModel.isCollapseMode {
                                Divider()
                                    .frame(height: 40)
                            }
                            
                            // Emoção
                            VStack(spacing: 8) {
                                if !collapseModeViewModel.simplifyNavigation {
                                    Text("Emotion")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                HStack(spacing: 4) {
                                    Text(viewModel.currentEmotion.icon)
                                        .font(collapseModeViewModel.isCollapseMode ? .body : .title2)
                                    Text(viewModel.currentEmotion.displayName)
                                        .font(collapseModeViewModel.isCollapseMode ? .caption : .subheadline)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(viewModel.currentStateColor)
                            }
                            
                            Spacer()
                        }
                        
                        // Recommendation (hide in collapse mode)
                        if !collapseModeViewModel.simplifyNavigation {
                            Text(viewModel.currentRecommendation)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.top, 4)
                        }
                    }
                    .padding(collapseModeViewModel.getUIConfiguration().padding)
                    .background(Color(.systemGray6))
                    .cornerRadius(collapseModeViewModel.isCollapseMode ? 8 : 16)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Last update (hide in collapse mode)
                if !collapseModeViewModel.simplifyNavigation {
                    Text("Updated \(viewModel.lastUpdated.formatted(date: .omitted, time: .shortened))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Insight Diária
    
    private var dailyInsightSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Insight do Dia")
                    .font(.headline)
                Spacer()
            }
            
            Text(viewModel.dailyInsight)
                .font(.body)
                .lineSpacing(2)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.yellow.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                        )
                )
        }
    }
    
    // MARK: - Estatísticas Diárias
    
    private var dailyStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hoje")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                StatCard(
                    title: "Tarefas",
                    value: "\(viewModel.todayStats.completedTasks)/\(viewModel.todayStats.totalTasks)",
                    subtitle: viewModel.todayStats.completionRateText,
                    icon: "checkmark.circle",
                    color: .green
                )
                
                StatCard(
                    title: "Wisdom",
                    value: "\(viewModel.todayStats.wisdomAdded)",
                    subtitle: "adicionados",
                    icon: "book",
                    color: .purple
                )
                
                StatCard(
                    title: "Check-ins",
                    value: "\(viewModel.todayStats.energyCheckins)",
                    subtitle: "de energia",
                    icon: "heart",
                    color: .red
                )
                
                StatCard(
                    title: "Sequência",
                    value: "\(viewModel.todayStats.currentStreak)",
                    subtitle: "dias",
                    icon: "flame",
                    color: .orange
                )
            }
        }
    }
    
    // MARK: - Tarefas Sugeridas
    
    private var suggestedTasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Tarefas Sugeridas")
                    .font(.headline)
                Spacer()
                NavigationLink("Ver todas") {
                    // TODO: Navegar para TasksView
                    Text("Tasks View")
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            VStack(spacing: 8) {
                ForEach(viewModel.suggestedTasks) { task in
                    SuggestedTaskRow(task: task) {
                        _Concurrency.Task {
                            await viewModel.quickCompleteTask(task)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Wisdom Sugerido
    
    private var suggestedWisdomSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Wisdom Recomendado")
                    .font(.headline)
                Spacer()
                NavigationLink("Ver todos") {
                    WisdomView()
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            VStack(spacing: 8) {
                ForEach(viewModel.suggestedWisdom) { wisdom in
                    SuggestedWisdomRow(wisdom: wisdom)
                }
            }
        }
    }
    
    // MARK: - Ações Rápidas
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
            
            HStack(spacing: 12) {
                QuickActionButton(
                    title: "Update State",
                    icon: "heart.circle",
                    color: .red
                ) {
                    showingMentalStateUpdate = true
                }
                
                QuickActionButton(
                    title: "Nova Tarefa",
                    icon: "plus.circle",
                    color: .green
                ) {
                    showingQuickAddTask = true
                }
                
                QuickActionButton(
                    title: "Nova Wisdom",
                    icon: "lightbulb.circle",
                    color: .purple
                ) {
                    showingQuickAddWisdom = true
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            return "Bom dia!"
        case 12..<18:
            return "Boa tarde!"
        default:
            return "Boa noite!"
        }
    }
}

// MARK: - Supporting Views

/// Row para tarefa sugerida
struct SuggestedTaskRow: View {
    let task: Task
    let onComplete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onComplete) {
                Image(systemName: "circle")
                    .font(.title3)
                    .foregroundColor(.green)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 8) {
                    HStack(spacing: 2) {
                        Image(systemName: task.energyLevel.icon)
                        Text(task.energyLevel.displayName)
                    }
                    .font(.caption)
                    .foregroundColor(task.energyLevel.color)
                    
                    if let purpose = task.purpose, !purpose.isEmpty {
                        Text("• \(purpose)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

/// Row para wisdom sugerido
struct SuggestedWisdomRow: View {
    let wisdom: Wisdom
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: wisdom.category.icon)
                    Text(wisdom.category.displayName)
                }
                .font(.caption)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(wisdom.category.color.opacity(0.2))
                .foregroundColor(wisdom.category.color)
                .cornerRadius(6)
                
                Spacer()
                
                Text(wisdom.emotion.icon)
                    .font(.caption)
            }
            
            Text(wisdom.content)
                .font(.subheadline)
                .lineLimit(2)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

/// Botão para ações rápidas
struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}