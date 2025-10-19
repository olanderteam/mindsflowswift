//
//  TasksViewModel.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import Foundation
import SwiftUI
import Supabase

/// ViewModel para gerenciar operações CRUD de tarefas
/// Implementa comunicação com Supabase e lógica de negócio
@MainActor
class TasksViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var tasks: [Task] = []
    @Published var filteredTasks: [Task] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var selectedEnergyFilter: EnergyLevel? = nil
    @Published var searchText = ""
    
    // MARK: - Dependencies
    private let supabase = SupabaseManager.shared
    private let cache = CacheManager.shared
    private let syncManager: SyncManager
    private var realtimeChannel: RealtimeChannelV2?
    
    // MARK: - Initialization
    init() {
        self.syncManager = SyncManager(supabase: supabase.supabase)
        
        _Concurrency.Task {
            // Aguardar autenticação estar completa
            try? await _Concurrency.Task.sleep(nanoseconds: 1_500_000_000) // 1.5 segundos
            
            // Verificar se usuário está autenticado antes de carregar
            if AuthManager.shared.isAuthenticated {
                await loadTasks()
                subscribeToChanges()
            } else {
                print("⚠️ TasksViewModel: User not authenticated yet, skipping initial load")
            }
        }
    }
    
    deinit {
        let channel = realtimeChannel
        let supabaseManager = supabase
        _Concurrency.Task { @MainActor in
            if let channel = channel {
                await supabaseManager.unsubscribe(from: channel)
            }
        }
        print("🗑️ TasksViewModel deallocated")
    }
    
    // MARK: - CRUD Operations
    
    // MARK: - Load Tasks
    func loadTasks() async {
        isLoading = true
        
        do {
            guard let userId = AuthManager.shared.currentUser?.id else {
                throw SupabaseError.notAuthenticated
            }
            
            // Tentar carregar do Supabase
            let query = SupabaseQuery.userIdOrderedByDate(userId, descending: true)
            let fetchedTasks: [Task] = try await supabase.fetch(from: "tasks", query: query)
            
            tasks = fetchedTasks
            applyFilters()
            
            // Atualizar cache
            try? cache.cache(fetchedTasks, for: .tasks)
            
            print("✅ Loaded \(fetchedTasks.count) tasks from Supabase")
            
        } catch {
            print("❌ Failed to load tasks: \(error)")
            
            // Se falhar, carregar do cache
            if let cachedTasks: [Task] = try? cache.getCached(for: .tasks) {
                tasks = cachedTasks
                applyFilters()
                print("✅ Loaded \(cachedTasks.count) tasks from cache")
            }
            
            handleError(error)
        }
        
        isLoading = false
    }
    
    /// Cria uma nova tarefa
    func createTask(
        title: String,
        description: String,
        energyLevel: EnergyLevel,
        purpose: String,
        dueDate: Date? = nil,
        timeEstimate: Int? = nil
    ) async {
        guard let userId = AuthManager.shared.currentUser?.id else {
            showErrorMessage("Usuário não autenticado")
            return
        }
        
        isLoading = true
        
        let newTask = Task(
            title: title,
            description: description,
            energyLevel: energyLevel,
            purpose: purpose,
            dueDate: dueDate,
            timeEstimate: timeEstimate,
            userId: userId
        )
        
        do {
            // Validar tarefa
            try newTask.validate()
            
            if supabase.isOnline {
                // Inserir no Supabase
                let createdTask: Task = try await supabase.insert(newTask, into: "tasks")
                tasks.append(createdTask)
                applyFilters()
                
                // Atualizar cache
                try? cache.cache(tasks, for: .tasks)
                
                print("✅ Task created in Supabase")
            } else {
                // Offline: adicionar localmente e enfileirar
                tasks.append(newTask)
                applyFilters()
                
                let operation = try syncManager.createInsertOperation(newTask, in: "tasks")
                syncManager.queueOperation(operation)
                
                print("⚠️ Task queued for sync (offline)")
            }
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    /// Atualiza uma tarefa existente
    func updateTask(_ task: Task) async {
        isLoading = true
        
        do {
            // Validar tarefa
            try task.validate()
            
            if supabase.isOnline {
                // Atualizar no Supabase
                let updatedTask: Task = try await supabase.update(task, in: "tasks", id: task.id)
                
                if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                    tasks[index] = updatedTask
                    applyFilters()
                }
                
                // Atualizar cache
                try? cache.cache(tasks, for: .tasks)
                
                print("✅ Task updated in Supabase")
            } else {
                // Offline: atualizar localmente e enfileirar
                if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                    tasks[index] = task
                    applyFilters()
                }
                
                let operation = try syncManager.createUpdateOperation(task, in: "tasks", id: task.id)
                syncManager.queueOperation(operation)
                
                print("⚠️ Task update queued for sync (offline)")
            }
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    /// Deleta uma tarefa
    func deleteTask(_ task: Task) async {
        isLoading = true
        
        do {
            if supabase.isOnline {
                // Deletar do Supabase
                try await supabase.delete(from: "tasks", id: task.id)
                tasks.removeAll { $0.id == task.id }
                applyFilters()
                
                // Atualizar cache
                try? cache.cache(tasks, for: .tasks)
                
                print("✅ Task deleted from Supabase")
            } else {
                // Offline: remover localmente e enfileirar
                tasks.removeAll { $0.id == task.id }
                applyFilters()
                
                let operation = syncManager.createDeleteOperation(id: task.id, from: "tasks")
                syncManager.queueOperation(operation)
                
                print("⚠️ Task deletion queued for sync (offline)")
            }
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    /// Marca/desmarca tarefa como concluída
    func toggleTaskCompletion(_ task: Task) async {
        var updatedTask = task
        
        if updatedTask.isCompleted {
            updatedTask.markAsIncomplete()
        } else {
            updatedTask.markAsCompleted()
        }
        
        await updateTask(updatedTask)
    }
    
    // MARK: - Realtime Subscription
    
    /// Subscreve a mudanças em tempo real nas tarefas
    func subscribeToChanges() {
        guard let userId = AuthManager.shared.currentUser?.id else {
            print("⚠️ Cannot subscribe: no user ID")
            return
        }
        
        realtimeChannel = supabase.subscribe(
            to: "tasks",
            event: .all,
            filter: "user_id=eq.\(userId.uuidString)"
        ) { [weak self] (updatedTasks: [Task]) in
            guard let self = self else { return }
            
            _Concurrency.Task { [weak self] in
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.tasks = updatedTasks
                    self.applyFilters()
                    
                    // Atualizar cache
                    try? self.cache.cache(updatedTasks, for: .tasks)
                    
                    print("✅ Tasks updated via Realtime")
                }
            }
        }
    }
    
    /// Cancela subscrição Realtime
    func unsubscribeFromChanges() async {
        if let channel = realtimeChannel {
            await supabase.unsubscribe(from: channel)
            realtimeChannel = nil
            print("✅ Unsubscribed from tasks Realtime")
        }
    }
    
    // MARK: - Filtering and Search
    
    /// Aplica filtros às tarefas
    func applyFilters() {
        var filtered = tasks
        
        // Filtro por nível de energia
        if let energyFilter = selectedEnergyFilter {
            filtered = filtered.filter { $0.energyLevel == energyFilter }
        }
        
        // Filtro por texto de busca
        if !searchText.isEmpty {
            filtered = filtered.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                (task.description?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (task.purpose?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        filteredTasks = filtered.sorted { task1, task2 in
            // Tarefas não concluídas primeiro
            if task1.isCompleted != task2.isCompleted {
                return !task1.isCompleted
            }
            // Depois por data de criação (mais recentes primeiro)
            return task1.createdAt > task2.createdAt
        }
    }
    
    /// Define filtro por nível de energia
    func setEnergyFilter(_ energyLevel: EnergyLevel?) {
        selectedEnergyFilter = energyLevel
        applyFilters()
    }
    
    /// Atualiza texto de busca
    func updateSearchText(_ text: String) {
        searchText = text
        applyFilters()
    }
    
    /// Limpa todos os filtros
    func clearFilters() {
        selectedEnergyFilter = nil
        searchText = ""
        applyFilters()
    }
    
    /// Recarrega dados (útil após login)
    func reload() async {
        await loadTasks()
        subscribeToChanges()
    }
    
    // MARK: - Computed Properties
    
    /// Tarefas pendentes
    var pendingTasks: [Task] {
        return tasks.filter { !$0.isCompleted }
    }
    
    /// Tarefas concluídas
    var completedTasks: [Task] {
        return tasks.filter { $0.isCompleted }
    }
    
    /// Estatísticas das tarefas
    var taskStats: TaskStats {
        return TaskStats(
            total: tasks.count,
            completed: completedTasks.count,
            pending: pendingTasks.count,
            highEnergy: tasks.filter { $0.energyLevel == .high }.count,
            mediumEnergy: tasks.filter { $0.energyLevel == .medium }.count,
            lowEnergy: tasks.filter { $0.energyLevel == .low }.count
        )
    }
    
    /// Tarefas sugeridas baseadas no estado atual do usuário
    func getSuggestedTasks(for energyLevel: EnergyLevel) -> [Task] {
        return pendingTasks
            .filter { $0.isAppropriateFor(currentEnergyLevel: energyLevel) }
            .prefix(3)
            .map { $0 }
    }
    
    // MARK: - Helper Methods
    
    /// Exibe mensagem de erro
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    /// Trata erros
    private func handleError(_ error: Error) {
        let message: String
        
        if error.localizedDescription.contains("Network") {
            message = "Erro de conexão. Verifique sua internet."
        } else {
            message = "Erro ao processar tarefas. Tente novamente."
        }
        
        showErrorMessage(message)
    }
}

// MARK: - Task Stats

/// Estrutura para estatísticas das tarefas
struct TaskStats {
    let total: Int
    let completed: Int
    let pending: Int
    let highEnergy: Int
    let mediumEnergy: Int
    let lowEnergy: Int
    
    /// Percentual de conclusão
    var completionPercentage: Double {
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total) * 100
    }
}