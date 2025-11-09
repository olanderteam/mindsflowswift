//
//  QuickAddTaskView.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import SwiftUI

/// View to quickly add tasks do Dashboard
struct QuickAddTaskView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var selectedEnergyLevel: EnergyLevel = .medium
    @State private var purpose: String = ""
    @State private var isCreating = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Formulário
                    formSection
                    
                    // Sugestão baseada no estado atual
                    suggestionSection
                }
                .padding()
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createTask()
                    }
                    .disabled(title.isEmpty || isCreating)
                }
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Create New Task")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add a task aligned with your current state")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Formulário
    
    private var formSection: some View {
        VStack(spacing: 16) {
            // Título
            VStack(alignment: .leading, spacing: 8) {
                Text("Título *")
                    .font(.headline)
                
                TextField("Ex: Review project, Meditate 10 min...", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // Descrição
            VStack(alignment: .leading, spacing: 8) {
                Text("Descrição")
                    .font(.headline)
                
                TextField("Task details (optional)", text: $description, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(2...4)
            }
            
            // Nível de energia
            VStack(alignment: .leading, spacing: 12) {
                Text("Nível de Energia Necessário")
                    .font(.headline)
                
                HStack(spacing: 12) {
                    ForEach(EnergyLevel.allCases, id: \.self) { level in
                        EnergyLevelButton(
                            level: level,
                            isSelected: selectedEnergyLevel == level
                        ) {
                            selectedEnergyLevel = level
                        }
                    }
                }
            }
            
            // Propósito
            VStack(alignment: .leading, spacing: 8) {
                Text("Propósito")
                    .font(.headline)
                
                TextField("Por que essa tarefa é importante?", text: $purpose)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }
    
    // MARK: - Sugestão
    
    private var suggestionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Sugestão")
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(getSuggestionText())
                    .font(.body)
                
                if let suggestedTask = getSuggestedTaskTitle() {
                    Button("Usar sugestão: \"\(suggestedTask)\"") {
                        title = suggestedTask
                        selectedEnergyLevel = viewModel.currentEnergyLevel
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
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
    
    // MARK: - Actions
    
    private func createTask() {
        isCreating = true
        
        _Concurrency.Task {
            await viewModel.quickAddTask(
                title: title,
                energyLevel: selectedEnergyLevel,
                description: description,
                purpose: purpose
            )
            
            await MainActor.run {
                isCreating = false
                dismiss()
            }
        }
    }
    
    private func getSuggestionText() -> String {
        switch (viewModel.currentEnergyLevel, viewModel.currentEmotion) {
        case (.high, .creative):
            return "With your high energy and creativity, consider tasks involving brainstorming, design or innovation."
        case (.high, .focused):
            return "Take advantage of your intense focus for complex tasks that require deep concentration."
        case (.medium, .calm):
            return "Your calm state is ideal for organization, planning and administrative tasks."
        case (.low, .tired):
            return "With low energy, prefer simple tasks with low mental effort."
        default:
            return "Based on your current state (\(viewModel.currentEnergyLevel.displayName), \(viewModel.currentEmotion.displayName)), I suggest tasks suitable for your energy level."
        }
    }
    
    private func getSuggestedTaskTitle() -> String? {
        switch (viewModel.currentEnergyLevel, viewModel.currentEmotion) {
        case (.high, .creative):
            return "Brainstorming for new project"
        case (.high, .focused):
            return "Review important document"
        case (.medium, .calm):
            return "Organize week's schedule"
        case (.low, .tired):
            return "Meditate for 5 minutes"
        case (.low, .anxious):
            return "Breathe and take a break"
        default:
            return nil
        }
    }
}

// MARK: - Supporting Views

/// Botão para seleção de nível de energia
struct EnergyLevelButton: View {
    let level: EnergyLevel
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Image(systemName: level.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : level.color)
                
                Text(level.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? level.color : level.color.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

struct QuickAddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        QuickAddTaskView(viewModel: DashboardViewModel())
    }
}