//
//  TasksView.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import SwiftUI

/// Main view for task management
struct TasksView: View {
    @StateObject private var viewModel = TasksViewModel()
    @State private var showingAddTask = false
    @State private var showingFilters = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with statistics
                if !viewModel.tasks.isEmpty {
                    headerSection
                        .padding()
                        .background(Color(.systemGray6))
                }
                
                // Tasks list
                tasksList
            }
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search tasks...")
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
            .alert("Error", isPresented: $viewModel.showError) {
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
    
    // MARK: - Header with Statistics
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Main statistics
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
                Button("Clear filters") {
                    viewModel.clearFilters()
                }
                .font(.caption)
                .foregroundColor(.red)
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Tasks List
    
    private var tasksList: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading tasks...")
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
            
            Text(viewModel.tasks.isEmpty ? "No tasks yet" : "No tasks found")
                .font(.title2)
                .fontWeight(.medium)
            
            Text(viewModel.tasks.isEmpty ? "Add your first task to get started" : "Try adjusting filters or search")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if viewModel.tasks.isEmpty {
                Button("Add Task") {
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

/// Card for statistics
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

/// Individual task row
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
            
            // Task content
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
                
                // Metadata
                HStack(spacing: 12) {
                    // Energy level
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

/// Chip for active filters
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