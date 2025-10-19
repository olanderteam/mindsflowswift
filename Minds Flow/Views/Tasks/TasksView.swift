//
//  TasksView.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import SwiftUI

/// View principal para gerenciamento de tarefas
struct TasksView: View {
    @StateObject private var viewModel = TasksViewModel()
    @State private var showingAddTask = false
    @State private var showingFilters = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header com estatísticas
                if !viewModel.tasks.isEmpty {
                    headerSection
                        .padding()
                        .background(Color(.systemGray6))
                }
                
                // Lista de tarefas
                tasksList
            }
            .navigationTitle("Tarefas")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Buscar tarefas...")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingFilters = true }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingFilters) {
                TaskFiltersView(viewModel: viewModel)
            }
            .refreshable {
                await viewModel.loadTasks()
            }
            .alert("Erro", isPresented: $viewModel.showError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
        .onAppear {
            _Concurrency.Task {
                await viewModel.loadTasks()
            }
        }
        .onChange(of: searchText) { newValue in
            viewModel.updateSearchText(newValue)
        }
    }
    
    // MARK: - Header com Estatísticas
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Estatísticas principais
            HStack(spacing: 16) {
                StatisticCard(
                    title: "Total",
                    value: "\(viewModel.taskStats.total)",
                    color: .blue
                )
                
                StatisticCard(
                    title: "Concluídas",
                    value: "\(viewModel.taskStats.completed)",
                    color: .green
                )
                
                StatisticCard(
                    title: "Pendentes",
                    value: "\(viewModel.taskStats.pending)",
                    color: .orange
                )
                
                StatisticCard(
                    title: "Taxa",
                    value: "\(Int(viewModel.taskStats.completionPercentage))%",
                    color: .purple
                )
            }
            

        }
    }
    
    private var activeFiltersSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button("Limpar filtros") {
                    viewModel.clearFilters()
                }
                .font(.caption)
                .foregroundColor(.red)
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Lista de Tarefas
    
    private var tasksList: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Carregando tarefas...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.filteredTasks.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(viewModel.filteredTasks) { task in
                        NavigationLink(destination: TaskDetailView(task: task, viewModel: viewModel)) {
                            TaskRowView(task: task) {
                                _Concurrency.Task {
                                    await viewModel.toggleTaskCompletion(task)
                                }
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                    .onDelete(perform: deleteTasks)
                }
                .listStyle(PlainListStyle())
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(viewModel.tasks.isEmpty ? "Nenhuma tarefa ainda" : "Nenhuma tarefa encontrada")
                .font(.title2)
                .fontWeight(.medium)
            
            Text(viewModel.tasks.isEmpty ? "Adicione sua primeira tarefa para começar" : "Tente ajustar os filtros ou busca")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if viewModel.tasks.isEmpty {
                Button("Adicionar Tarefa") {
                    showingAddTask = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Actions
    
    private func deleteTasks(offsets: IndexSet) {
        _Concurrency.Task {
            for index in offsets {
                let task = viewModel.filteredTasks[index]
                await viewModel.deleteTask(task)
            }
        }
    }
}

// MARK: - Supporting Views

/// Card para estatísticas
struct StatisticCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

/// Row individual de tarefa
struct TaskRowView: View {
    let task: Task
    let onToggleCompletion: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Botão de completar
            Button(action: onToggleCompletion) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Conteúdo da tarefa
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                
                if let description = task.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // Metadados
                HStack(spacing: 12) {
                    // Nível de energia
                    HStack(spacing: 2) {
                        Image(systemName: task.energyLevel.icon)
                        Text(task.energyLevel.displayName)
                    }
                    .font(.caption)
                    .foregroundColor(task.energyLevel.color)
                    
                    // Propósito
                    if let purpose = task.purpose, !purpose.isEmpty {
                        Text("• \(purpose)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Data de criação
                    Text(task.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Indicador de status
            if task.isCompleted {
                VStack(spacing: 2) {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    if let completedAt = task.completedAt {
                        Text(completedAt.formatted(date: .omitted, time: .shortened))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

/// Chip para filtros ativos
struct TaskFilterChip: View {
    let text: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.caption)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption2)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.1))
        .foregroundColor(.blue)
        .cornerRadius(12)
    }
}

// MARK: - Preview

struct TasksView_Previews: PreviewProvider {
    static var previews: some View {
        TasksView()
    }
}