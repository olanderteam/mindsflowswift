//
//  DashboardViewModel.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import Foundation
import SwiftUI

// Alias para evitar conflito com o modelo Task
typealias AsyncTask = _Concurrency.Task

/// ViewModel to manage Dashboard and user's mental state
@MainActor
class DashboardViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentMentalState: MentalState?
    @Published var usageStats: UsageStats?
    @Published var timelineEvents: [TimelineEvent] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    // Suggestions based on current state
    @Published var suggestedTasks: [Task] = []
    @Published var suggestedWisdom: [Wisdom] = []
    @Published var dailyInsight: String = ""
    
    // Estatísticas do dia
    @Published var todayStats: DailyStats = DailyStats()
    
    // MARK: - Dependencies
    private let supabase = SupabaseManager.shared
    private let cache = CacheManager.shared
    private let tasksViewModel = TasksViewModel()
    private let wisdomViewModel = WisdomViewModel()
    
    // MARK: - Computed Properties
    var currentEnergyLevel: EnergyLevel {
        return currentMentalState?.energyLevel ?? .medium
    }
    
    var currentEmotion: Emotion {
        return currentMentalState?.mood ?? .calm
    }
    
    var lastUpdated: Date {
        return currentMentalState?.createdAt ?? Date()
    }
    
    // MARK: - Initialization
    init() {
        AsyncTask {
            await loadCurrentState()
            await loadUsageStats()
            await loadTimelineEvents()
            generateDailyInsight()
        }
    }
    
    // MARK: - State Management
    
    /// Loads user's current mental state
    func loadCurrentState() async {
        isLoading = true
        
        do {
            guard let userId = AuthManager.shared.currentUser?.id else {
                throw SupabaseError.notAuthenticated
            }
            
            // Fetch most recent mental state
            let query = SupabaseQuery
                .userId(userId)
                .orderBy("created_at", descending: true)
                .limit(1)
            
            let states: [MentalState] = try await supabase.fetch(from: "mental_states", query: query)
            
            currentMentalState = states.first
            updateSuggestions()
            generateDailyInsight()
            
            // Cache state
            if let state = currentMentalState {
                try? cache.cacheSingle(state, for: .mentalStates)
            }
            
            print("✅ Loaded current mental state from Supabase")
            
        } catch {
            print("❌ Failed to load mental state: \(error)")
            
            // Try to load from cache
            if let cachedState: MentalState = try? cache.getCachedSingle(for: .mentalStates) {
                currentMentalState = cachedState
                updateSuggestions()
                generateDailyInsight()
                print("✅ Loaded mental state from cache")
            }
            
            handleError(error)
        }
        
        isLoading = false
    }
    
    /// Updates user's mental state
    func updateMentalState(energyLevel: EnergyLevel, emotion: Emotion, notes: String? = nil) async {
        guard let userId = AuthManager.shared.currentUser?.id else {
            showErrorMessage("Usuário não autenticado")
            return
        }
        
        isLoading = true
        
        do {
            // Create new mental state
            let newState = MentalState(
                userId: userId,
                mood: emotion,
                energyLevel: energyLevel,
                notes: notes
            )
            
            // Validar
            try newState.validate()
            
            if supabase.isOnline {
                // Inserir no Supabase
                let createdState: MentalState = try await supabase.insert(newState, into: "mental_states")
                currentMentalState = createdState
                
                // Cachear
                try? cache.cacheSingle(createdState, for: .mentalStates)
                
                print("✅ Mental state updated in Supabase")
            } else {
                // Offline: save locally
                currentMentalState = newState
                print("⚠️ Mental state saved locally (offline)")
            }
            
            // Update suggestions and insights
            updateSuggestions()
            generateDailyInsight()
            
            // Update statistics
            updateStats(action: .energyCheckin)
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    /// Carrega estatísticas de uso
    func loadUsageStats() async {
        guard let userId = AuthManager.shared.currentUser?.id else { return }
        
        do {
            let query = SupabaseQuery.userId(userId)
            let stats: [UsageStats] = try await supabase.fetch(from: "usage_stats", query: query)
            
            usageStats = stats.first
            
            // Cachear
            if let stats = usageStats {
                try? cache.cacheSingle(stats, for: .usageStats)
            }
            
            print("✅ Loaded usage stats from Supabase")
            
        } catch {
            print("❌ Failed to load usage stats: \(error)")
            
            // Try to load from cache
            if let cachedStats: UsageStats = try? cache.getCachedSingle(for: .usageStats) {
                usageStats = cachedStats
                print("✅ Loaded usage stats from cache")
            }
        }
    }
    
    /// Carrega eventos da timeline
    func loadTimelineEvents() async {
        guard let userId = AuthManager.shared.currentUser?.id else { return }
        
        do {
            let query = SupabaseQuery
                .userId(userId)
                .orderBy("created_at", descending: true)
                .limit(10)
            
            let events: [TimelineEvent] = try await supabase.fetch(from: "timeline_events", query: query)
            
            timelineEvents = events
            
            // Cachear
            try? cache.cache(events, for: .timelineEvents)
            
            print("✅ Loaded timeline events from Supabase")
            
        } catch {
            print("❌ Failed to load timeline events: \(error)")
            
            // Try to load from cache
            if let cachedEvents: [TimelineEvent] = try? cache.getCached(for: .timelineEvents) {
                timelineEvents = cachedEvents
                print("✅ Loaded timeline events from cache")
            }
        }
    }
    
    /// Updates suggestions based on current state
    private func updateSuggestions() {
        // Suggest tasks based on energy level
        suggestedTasks = getSuggestedTasks(for: currentEnergyLevel)
        
        // Sugerir wisdom baseado na emoção atual
        suggestedWisdom = getSuggestedWisdom(for: currentEmotion)
    }
    
    // MARK: - Suggestions Logic
    
    /// Returns suggested tasks based on energy level
    private func getSuggestedTasks(for energyLevel: EnergyLevel) -> [Task] {
        let allTasks = tasksViewModel.tasks
        
        let filteredTasks = allTasks.filter { task in
            !task.isCompleted && task.isAppropriateFor(currentEnergyLevel: energyLevel)
        }
        
        return Array(filteredTasks.prefix(3))
    }
    
    /// Returns wisdom sugerido baseado na emoção atual
    private func getSuggestedWisdom(for emotion: Emotion) -> [Wisdom] {
        let allWisdom = wisdomViewModel.wisdomEntries
        
        let filteredWisdom = allWisdom.filter { wisdom in
            wisdom.isAppropriateFor(currentEmotion: emotion)
        }
        
        return Array(filteredWisdom.prefix(2))
    }
    
    /// Generates daily insight based on current state
    private func generateDailyInsight() {
        let insights = getDailyInsights(for: currentEnergyLevel, emotion: currentEmotion)
        dailyInsight = insights.randomElement() ?? "Hoje é um novo dia cheio de possibilidades."
    }
    
    /// Returns personalized insights based on mental state
    private func getDailyInsights(for energy: EnergyLevel, emotion: Emotion) -> [String] {
        switch (energy, emotion) {
        case (.high, .motivated):
            return [
                "Your energy is high and you're motivated! This is the perfect moment to tackle important challenges.",
                "With this combination of energy and motivation, you can achieve any goal today.",
                "Take advantage of this powerful mental state to advance on projects that require intense focus."
            ]
            
        case (.high, .anxious):
            return [
                "You have a lot of energy, but you're anxious. How about channeling this energy into physical activities?",
                "Your high energy can help transform anxiety into productive action.",
                "Consider taking a break to breathe deeply before diving into tasks."
            ]
            
        case (.low, .calm):
            return [
                "You're calm, but with low energy. This is a good moment for reflection and planning.",
                "Take advantage of this tranquil state to organize thoughts and define priorities.",
                "Light and contemplative tasks may be ideal for this moment."
            ]
            
        case (.low, .sad):
            return [
                "It's being a difficult day. Remember to be kind to yourself.",
                "Small steps are also progress. Start with something simple and comforting.",
                "How about reviewing some wisdom that inspires you or talking to someone dear?"
            ]
            
        case (.medium, .creative):
            return [
                "Your creativity is flowing! This is a great moment for projects that require innovation.",
                "Take advantage of this creative state to explore new ideas and solutions.",
                "Consider documenting your creative ideas to revisit later."
            ]
            
        default:
            return [
                "Cada momento é uma oportunidade para crescer e aprender.",
                "Trust your process and be patient with yourself.",
                "Small consistent actions lead to great transformations.",
                "You have everything you need to face today's challenges."
            ]
        }
    }
    
    // MARK: - Daily Stats
    
    /// Carrega estatísticas do dia atual
    private func loadTodayStats() {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        // TODO: Implementar queries reais do Supabase
        // Por enquanto, usar dados simulados
        todayStats = DailyStats(
            completedTasks: 3,
            totalTasks: 8,
            wisdomAdded: 1,
            energyCheckins: 2,
            currentStreak: 5
        )
    }
    
    /// Atualiza estatísticas após uma ação
    func updateStats(action: StatsAction) {
        switch action {
        case .taskCompleted:
            todayStats.completedTasks += 1
        case .taskAdded:
            todayStats.totalTasks += 1
        case .wisdomAdded:
            todayStats.wisdomAdded += 1
        case .energyCheckin:
            todayStats.energyCheckins += 1
        }
    }
    
    // MARK: - Quick Actions
    
    /// Quick action to add task
    func quickAddTask(title: String, energyLevel: EnergyLevel, description: String = "", purpose: String = "") async {
        await tasksViewModel.createTask(
            title: title,
            description: description,
            energyLevel: energyLevel,
            purpose: purpose
        )
        updateStats(action: .taskAdded)
        updateSuggestions()
    }
    
    /// Quick action to add wisdom
    func quickAddWisdom(content: String, category: WisdomCategory = .insight, emotion: Emotion) async {
        await wisdomViewModel.createWisdom(
            content: content,
            category: category,
            emotion: emotion
        )
        updateStats(action: .wisdomAdded)
    }
    
    /// Ação rápida para marcar tarefa como concluída
    func quickCompleteTask(_ task: Task) async {
        await tasksViewModel.toggleTaskCompletion(task)
        updateStats(action: .taskCompleted)
        
        // Remove from suggestions list
        suggestedTasks.removeAll { $0.id == task.id }
        
        // Update suggestions
        updateSuggestions()
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
            message = "Connection error. Check your internet."
        } else {
            message = "Error updating mental state. Please try again."
        }
        
        showErrorMessage(message)
    }
    
    /// Returns recomendação baseada no estado atual
    var currentRecommendation: String {
        switch (currentEnergyLevel, currentEmotion) {
        case (.high, .motivated):
            return "Momento ideal para tackles grandes desafios!"
        case (.high, .anxious):
            return "Canalize essa energia em atividades físicas."
        case (.low, .calm):
            return "Perfeito para reflexão e planejamento."
        case (.low, .sad):
            return "Be kind to yourself today."
        case (.medium, .creative):
            return "Your creativity is high!"
        default:
            return "Trust your process."
        }
    }
    
    /// Returns cor baseada no estado atual
    var currentStateColor: Color {
        switch currentEmotion {
        case .happy, .grateful, .motivated:
            return .green
        case .calm, .focused, .creative:
            return .blue
        case .anxious, .dispersed:
            return .orange
        case .sad, .confused:
            return .red
        case .tired:
            return .gray
        @unknown default:
            return .gray
        }
    }
}

// MARK: - Supporting Types

/// Estatísticas diárias do usuário
struct DailyStats {
    var completedTasks: Int = 0
    var totalTasks: Int = 0
    var wisdomAdded: Int = 0
    var energyCheckins: Int = 0
    var currentStreak: Int = 0
    
    /// Porcentagem de tarefas concluídas
    var completionRate: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedTasks) / Double(totalTasks)
    }
    
    /// Texto da porcentagem formatado
    var completionRateText: String {
        return "\(Int(completionRate * 100))%"
    }
}

/// Ações que afetam as estatísticas
enum StatsAction {
    case taskCompleted
    case taskAdded
    case wisdomAdded
    case energyCheckin
}