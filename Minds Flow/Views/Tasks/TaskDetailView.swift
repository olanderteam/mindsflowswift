//
//  TaskDetailView.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import SwiftUI

/// View para visualizar e editar detalhes de uma tarefa
struct TaskDetailView: View {
    let task: Task
    @ObservedObject var viewModel: TasksViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var isEditing = false
    @State private var editedTitle: String
    @State private var editedDescription: String
    @State private var editedEnergyLevel: EnergyLevel
    @State private var editedPurpose: String
    @State private var showingDeleteAlert = false
    @State private var isUpdating = false
    
    init(task: Task, viewModel: TasksViewModel) {
        self.task = task
        self.viewModel = viewModel
        self._editedTitle = State(initialValue: task.title)
        self._editedDescription = State(initialValue: task.description ?? "")
        self._editedEnergyLevel = State(initialValue: task.energyLevel)
        self._editedPurpose = State(initialValue: task.purpose ?? "")
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header com status
                headerSection
                
                // Conteúdo principal
                if isEditing {
                    editingSection
                } else {
                    viewingSection
                }
                
                // Metadados
                metadataSection
                
                // Ações
                actionsSection
            }
            .padding()
        }
        .navigationTitle("Detalhes")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditing {
                    HStack {
                        Button("Cancelar") {
                            cancelEditing()
                        }
                        
                        Button("Salvar") {
                            saveChanges()
                        }
                        .disabled(editedTitle.isEmpty || isUpdating)
                    }
                } else {
                    Button("Editar") {
                        isEditing = true
                    }
                }
            }
        }
        .alert("Excluir Tarefa", isPresented: $showingDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Excluir", role: .destructive) {
                deleteTask()
            }
        } message: {
            Text("Tem certeza que deseja excluir esta tarefa? Esta ação não pode ser desfeita.")
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Status da tarefa
            HStack {
                Button(action: toggleCompletion) {
                    HStack(spacing: 8) {
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.title)
                            .foregroundColor(task.isCompleted ? .green : .gray)
                        
                        Text(task.isCompleted ? "Concluída" : "Pendente")
                            .font(.headline)
                            .fontWeight(.medium)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                // Indicador de prioridade baseado na energia
                VStack(spacing: 2) {
                    Image(systemName: task.energyLevel.icon)
                        .font(.title2)
                        .foregroundColor(task.energyLevel.color)
                    
                    Text(task.energyLevel.displayName)
                        .font(.caption)
                        .foregroundColor(task.energyLevel.color)
                }
            }
            
            // Barra de progresso visual
            if task.isCompleted {
                HStack {
                    Text("Concluída em")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let completedAt = task.completedAt {
                        Text(completedAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(task.isCompleted ? Color.green.opacity(0.1) : Color(.systemGray6))
        )
    }
    
    // MARK: - Visualização
    
    private var viewingSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Título
            VStack(alignment: .leading, spacing: 8) {
                Text("Título")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(task.title)
                    .font(.title2)
                    .fontWeight(.medium)
                    .strikethrough(task.isCompleted)
            }
            
            // Descrição
            if let description = task.description, !description.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Descrição")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(description)
                        .font(.body)
                        .lineSpacing(2)
                }
            }
            
            // Propósito
            if let purpose = task.purpose, !purpose.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Propósito")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(purpose)
                        .font(.body)
                        .foregroundColor(.purple)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.purple.opacity(0.1))
                        )
                }
            }
        }
    }
    
    // MARK: - Edição
    
    private var editingSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Título
            VStack(alignment: .leading, spacing: 8) {
                Text("Título *")
                    .font(.headline)
                
                TextField("Título da tarefa", text: $editedTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // Descrição
            VStack(alignment: .leading, spacing: 8) {
                Text("Descrição")
                    .font(.headline)
                
                TextField("Descrição da tarefa", text: $editedDescription, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
            }
            
            // Nível de energia
            VStack(alignment: .leading, spacing: 12) {
                Text("Nível de Energia")
                    .font(.headline)
                
                VStack(spacing: 8) {
                    ForEach(EnergyLevel.allCases, id: \.self) { level in
                        EnergyLevelEditCard(
                            level: level,
                            isSelected: editedEnergyLevel == level
                        ) {
                            editedEnergyLevel = level
                        }
                    }
                }
            }
            
            // Propósito
            VStack(alignment: .leading, spacing: 8) {
                Text("Propósito")
                    .font(.headline)
                
                TextField("Por que essa tarefa é importante?", text: $editedPurpose)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }
    
    // MARK: - Metadados
    
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Informações")
                .font(.headline)
            
            VStack(spacing: 8) {
                MetadataRow(
                    icon: "calendar",
                    title: "Criada em",
                    value: task.createdAt.formatted(date: .abbreviated, time: .shortened),
                    color: .blue
                )
                
                if task.updatedAt != task.createdAt {
                    MetadataRow(
                        icon: "pencil",
                        title: "Atualizada em",
                        value: task.updatedAt.formatted(date: .abbreviated, time: .shortened),
                        color: .orange
                    )
                }
                
                if let completedAt = task.completedAt {
                    MetadataRow(
                        icon: "checkmark.circle",
                        title: "Concluída em",
                        value: completedAt.formatted(date: .abbreviated, time: .shortened),
                        color: .green
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Ações
    
    private var actionsSection: some View {
        VStack(spacing: 12) {
            if !isEditing {
                // Botão de completar/descompletar
                Button(action: toggleCompletion) {
                    HStack {
                        Image(systemName: task.isCompleted ? "arrow.counterclockwise" : "checkmark")
                        Text(task.isCompleted ? "Marcar como Pendente" : "Marcar como Concluída")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(task.isCompleted ? Color.orange : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                // Botão de excluir
                Button(action: { showingDeleteAlert = true }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Excluir Tarefa")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func toggleCompletion() {
        _Concurrency.Task {
            await viewModel.toggleTaskCompletion(task)
        }
    }
    
    private func saveChanges() {
        isUpdating = true
        
        var updatedTask = task
        updatedTask.title = editedTitle
        updatedTask.description = editedDescription
        updatedTask.energyLevel = editedEnergyLevel
        updatedTask.purpose = editedPurpose
        
        _Concurrency.Task {
            await viewModel.updateTask(updatedTask)
            
            await MainActor.run {
                isUpdating = false
                isEditing = false
            }
        }
    }
    
    private func cancelEditing() {
        editedTitle = task.title
        editedDescription = task.description ?? ""
        editedEnergyLevel = task.energyLevel
        editedPurpose = task.purpose ?? ""
        isEditing = false
    }
    
    private func deleteTask() {
        _Concurrency.Task {
            await viewModel.deleteTask(task)
            await MainActor.run {
                dismiss()
            }
        }
    }
}

// MARK: - Supporting Views

/// Card para edição de nível de energia
struct EnergyLevelEditCard: View {
    let level: EnergyLevel
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: level.icon)
                    .font(.title3)
                    .foregroundColor(level.color)
                    .frame(width: 25)
                
                Text(level.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.blue : Color(.systemGray4), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Row para metadados
struct MetadataRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Preview

struct TaskDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TaskDetailView(
                task: Task.sampleTasks[0],
                viewModel: TasksViewModel()
            )
        }
    }
}