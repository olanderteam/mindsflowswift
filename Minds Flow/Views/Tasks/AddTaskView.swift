//
//  AddTaskView.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import SwiftUI

/// View para adicionar nova tarefa
struct AddTaskView: View {
    @ObservedObject var viewModel: TasksViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var selectedEnergyLevel: EnergyLevel = .medium
    @State private var purpose: String = ""
    @State private var isCreating = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Formulário principal
                    formSection
                    
                    // Configurações avançadas
                    advancedSection
                    
                    // Preview da tarefa
                    if !title.isEmpty {
                        previewSection
                    }
                }
                .padding()
            }
            .navigationTitle("Nova Tarefa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Criar") {
                        createTask()
                    }
                    .disabled(title.isEmpty || isCreating)
                }
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Criar Nova Tarefa")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Defina uma tarefa clara e alcançável para seu crescimento")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Formulário Principal
    
    private var formSection: some View {
        VStack(spacing: 20) {
            // Título
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "text.cursor")
                        .foregroundColor(.blue)
                    Text("Título *")
                        .font(.headline)
                }
                
                TextField("Ex: Revisar projeto, Meditar 10 min, Estudar Swift...", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Text("\(title.count)/100")
                    .font(.caption2)
                    .foregroundColor(title.count > 80 ? .red : .secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            // Descrição
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "doc.text")
                        .foregroundColor(.green)
                    Text("Descrição")
                        .font(.headline)
                }
                
                TextField("Detalhes sobre a tarefa, contexto ou observações...", text: $description, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
                
                Text("\(description.count)/500")
                    .font(.caption2)
                    .foregroundColor(description.count > 400 ? .red : .secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
    
    // MARK: - Configurações Avançadas
    
    private var advancedSection: some View {
        VStack(spacing: 20) {
            // Nível de energia
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "bolt.fill")
                        .foregroundColor(.yellow)
                    Text("Nível de Energia Necessário")
                        .font(.headline)
                }
                
                VStack(spacing: 8) {
                    ForEach(EnergyLevel.allCases, id: \.self) { level in
                        EnergyLevelSelectionCard(
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
                HStack {
                    Image(systemName: "target")
                        .foregroundColor(.purple)
                    Text("Propósito")
                        .font(.headline)
                }
                
                TextField("Por que essa tarefa é importante para você?", text: $purpose)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Text("Conecte a tarefa com seus objetivos maiores")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Preview
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "eye")
                    .foregroundColor(.blue)
                Text("Preview")
                    .font(.headline)
            }
            
            TaskPreviewCard(
                title: title,
                description: description,
                energyLevel: selectedEnergyLevel,
                purpose: purpose
            )
        }
    }
    
    // MARK: - Actions
    
    private func createTask() {
        isCreating = true
        
        _Concurrency.Task {
            await viewModel.createTask(
                title: title,
                description: description.isEmpty ? "" : description,
                energyLevel: selectedEnergyLevel,
                purpose: purpose.isEmpty ? "" : purpose
            )
            
            await MainActor.run {
                isCreating = false
                dismiss()
            }
        }
    }
}

// MARK: - Supporting Views

/// Card para seleção de nível de energia
struct EnergyLevelSelectionCard: View {
    let level: EnergyLevel
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: level.icon)
                    .font(.title2)
                    .foregroundColor(level.color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(level.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(level.taskDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Card de preview da tarefa
struct TaskPreviewCard: View {
    let title: String
    let description: String
    let energyLevel: EnergyLevel
    let purpose: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Título
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            // Descrição
            if !description.isEmpty {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            // Metadados
            HStack(spacing: 12) {
                // Nível de energia
                HStack(spacing: 2) {
                    Image(systemName: energyLevel.icon)
                    Text(energyLevel.displayName)
                }
                .font(.caption)
                .foregroundColor(energyLevel.color)
                
                // Propósito
                if !purpose.isEmpty {
                    Text("• \(purpose)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Data
                Text(Date().formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Extensions

extension EnergyLevel {
    var taskDescription: String {
        switch self {
        case .high:
            return "Tarefas complexas, criativas ou desafiadoras"
        case .medium:
            return "Tarefas moderadas, organização e planejamento"
        case .low:
            return "Tarefas simples, autocuidado e descanso"
        }
    }
}

// MARK: - Preview

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView(viewModel: TasksViewModel())
    }
}