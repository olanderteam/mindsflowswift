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

/// ViewModel para gerenciar o Dashboard e estado mental do usuário
@MainActor
class DashboardViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentMentalState: MentalState?
    @Published var usageStats: UsageStats?
    @Published var timelineEvents: [TimelineEvent] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    // Sugestões baseadas no estado atual
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
    
    /// Carrega o estado mental atual do usuário
    func loadCurrentState() async {
        isLoading = true
        
        do {
            guard let userId = AuthManager.shared.currentUser?.id else {
                throw SupabaseError.notAuthenticated
            }
            
            // Buscar estado mental mais recente
            let query = SupabaseQuery
                .userId(userId)
                .orderBy("created_at", descending: true)
                .limit(1)
            
            let states: [MentalState] = try await supabase.fetch(from: "mental_states", query: query)
            
            currentMentalState = states.first
            updateSuggestions()
            generateDailyInsight()
            
            // Cachear estado
            if let state = currentMentalState {
                try? cache.cacheSingle(state, for: .mentalStates)
            }
            
            print("✅ Loaded current mental state from Supabase")
            
        } catch {
            print("❌ Failed to load mental state: \(error)")
            
            // Tentar carregar do cache
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
    
    /// Atualiza o estado mental do usuário
    func updateMentalState(energyLevel: EnergyLevel, emotion: Emotion, notes: String? = nil) async {
        guard let userId = AuthManager.shared.currentUser?.id else {
            showErrorMessage("Usuário não autenticado")
            return
        }
        
        isLoading = true
        
        do {
            // Criar novo estado mental
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
                // Offline: salvar localmente
                currentMentalState = newState
                print("⚠️ Mental state saved locally (offline)")
            }
            
            // Atualizar sugestões e insights
            updateSuggestions()
            generateDailyInsight()
            
            // Atualizar estatísticas
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
            
            // Tentar carregar do cache
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
            
            // Tentar carregar do cache
            if let cachedEvents: [TimelineEvent] = try? cache.getCached(for: .timelineEvents) {
                timelineEvents = cachedEvents
                print("✅ Loaded timeline events from cache")
            }
        }
    }
    
    /// Atualiza sugestões baseadas no estado atual
    private func updateSuggestions() {
        // Sugerir tarefas baseadas no nível de energia
        suggestedTasks = getSuggestedTasks(for: currentEnergyLevel)
        
        // Sugerir wisdom baseado na emoção atual
        suggestedWisdom = getSuggestedWisdom(for: currentEmotion)
    }
    
    // MARK: - Suggestions Logic
    
    /// Retorna tarefas sugeridas baseadas no nível de energia
    private func getSuggestedTasks(for energyLevel: EnergyLevel) -> [Task] {
        let allTasks = tasksViewModel.tasks
        
        let filteredTasks = allTasks.filter { task in
            !task.isCompleted && task.isAppropriateFor(currentEnergyLevel: energyLevel)
        }
        
        return Array(filteredTasks.prefix(3))
    }
    
    /// Retorna wisdom sugerido baseado na emoção atual
    private func getSuggestedWisdom(for emotion: Emotion) -> [Wisdom] {
        let allWisdom = wisdomViewModel.wisdomEntries
        
        let filteredWisdom = allWisdom.filter { wisdom in
            wisdom.isAppropriateFor(currentEmotion: emotion)
        }
        
        return Array(filteredWisdom.prefix(2))
    }
    
    /// Gera insight diária baseada no estado atual
    private func generateDailyInsight() {
        let insights = getDailyInsights(for: currentEnergyLevel, emotion: currentEmotion)
        dailyInsight = insights.randomElement() ?? "Hoje é um novo dia cheio de possibilidades."
    }
    
    /// Retorna insights personalizadas baseadas no estado mental
    private func getDailyInsights(for energy: EnergyLevel, emotion: Emotion) -> [String] {
        switch (energy, emotion) {
        case (.high, .motivated):
            return [
                "Sua energia está alta e você está motivado! É o momento perfeito para tackles desafios importantes.",
                "Com essa combinação de energia e motivação, você pode conquistar qualquer objetivo hoje.",
                "Aproveite esse estado mental poderoso para avançar em projetos que exigem foco intenso."
            ]
            
        case (.high, .anxious):
            return [
                "Você tem muita energia, mas está ansioso. Que tal canalizar essa energia em atividades físicas?",
                "Sua energia alta pode ajudar a transformar a ansiedade em ação produtiva.",
                "Considere fazer uma pausa para respirar fundo antes de mergulhar nas tarefas."
            ]
            
        case (.low, .calm):
            return [
                "Você está calmo, mas com pouca energia. É um bom momento para reflexão e planejamento.",
                "Aproveite esse estado tranquilo para organizar pensamentos e definir prioridades.",
                "Tarefas leves e contemplativas podem ser ideais para este momento."
            ]
            
        case (.low, .sad):
            return [
                "Está sendo um dia difícil. Lembre-se de ser gentil consigo mesmo.",
                "Pequenos passos também são progresso. Comece com algo simples e reconfortante.",
                "Que tal revisar algumas wisdom que te inspiram ou conversar com alguém querido?"
            ]
            
        case (.medium, .creative):
            return [
                "Sua criatividade está fluindo! É um ótimo momento para projetos que exigem inovação.",
                "Aproveite esse estado criativo para explorar novas ideias e soluções.",
                "Considere documentar suas ideias criativas para revisitar mais tarde."
            ]
            
        default:
            return [
                "Cada momento é uma oportunidade para crescer e aprender.",
                "Confie no seu processo e seja paciente consigo mesmo.",
                "Pequenas ações consistentes levam a grandes transformações.",
                "Você tem tudo o que precisa para enfrentar os desafios de hoje."
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
    
    /// Ação rápida para adicionar tarefa
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
    
    /// Ação rápida para adicionar wisdom
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
        
        // Remover da lista de sugestões
        suggestedTasks.removeAll { $0.id == task.id }
        
        // Atualizar sugestões
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
            message = "Erro de conexão. Verifique sua internet."
        } else {
            message = "Erro ao atualizar estado mental. Tente novamente."
        }
        
        showErrorMessage(message)
    }
    
    /// Retorna recomendação baseada no estado atual
    var currentRecommendation: String {
        switch (currentEnergyLevel, currentEmotion) {
        case (.high, .motivated):
            return "Momento ideal para tackles grandes desafios!"
        case (.high, .anxious):
            return "Canalize essa energia em atividades físicas."
        case (.low, .calm):
            return "Perfeito para reflexão e planejamento."
        case (.low, .sad):
            return "Seja gentil consigo mesmo hoje."
        case (.medium, .creative):
            return "Sua criatividade está em alta!"
        default:
            return "Confie no seu processo."
        }
    }
    
    /// Retorna cor baseada no estado atual
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