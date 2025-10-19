//
//  WisdomViewModel.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import Foundation
import SwiftUI
import Supabase

/// ViewModel para gerenciar operações CRUD do sistema Wisdom
/// Biblioteca pessoal de conhecimentos e reflexões
@MainActor
class WisdomViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var wisdomEntries: [Wisdom] = []
    @Published var filteredEntries: [Wisdom] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var selectedCategory: WisdomCategory? = nil
    @Published var selectedEmotion: Emotion? = nil
    @Published var searchText = ""
    @Published var selectedTags: Set<String> = []
    
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
                await loadWisdomEntries()
                subscribeToChanges()
            } else {
                print("⚠️ WisdomViewModel: User not authenticated yet, skipping initial load")
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
        print("🗑️ WisdomViewModel deallocated")
    }
    
    // MARK: - CRUD Operations
    
    // MARK: - Load Wisdom Entries
    func loadWisdomEntries() async {
        isLoading = true
        
        do {
            guard let userId = AuthManager.shared.currentUser?.id else {
                throw SupabaseError.notAuthenticated
            }
            
            // Tentar carregar do Supabase
            let query = SupabaseQuery.userIdOrderedByDate(userId, descending: true)
            let fetchedEntries: [Wisdom] = try await supabase.fetch(from: "wisdom_entries", query: query)
            
            wisdomEntries = fetchedEntries
            applyFilters()
            
            // Atualizar cache
            try? cache.cache(fetchedEntries, for: .wisdom)
            
            print("✅ Loaded \(fetchedEntries.count) wisdom entries from Supabase")
            
        } catch {
            print("❌ Failed to load wisdom entries: \(error)")
            
            // Se falhar, carregar do cache
            if let cachedEntries: [Wisdom] = try? cache.getCached(for: .wisdom) {
                wisdomEntries = cachedEntries
                applyFilters()
                print("✅ Loaded \(cachedEntries.count) wisdom entries from cache")
            }
            
            handleError(error)
        }
        
        isLoading = false
    }
    
    /// Cria uma nova entrada de wisdom
    func createWisdom(
        title: String? = nil,
        content: String,
        category: WisdomCategory,
        emotion: Emotion,
        tags: [String] = []
    ) async {
        guard let userId = AuthManager.shared.currentUser?.id else {
            showErrorMessage("Usuário não autenticado")
            return
        }
        
        isLoading = true
        
        let cleanTags = tags.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }
        
        let newWisdom = Wisdom(
            title: title,
            content: content,
            category: category,
            emotionalTag: emotion,
            tags: cleanTags,
            userId: userId
        )
        
        do {
            // Validar wisdom
            try newWisdom.validate()
            
            if supabase.isOnline {
                // Inserir no Supabase
                let createdWisdom: Wisdom = try await supabase.insert(newWisdom, into: "wisdom_entries")
                wisdomEntries.append(createdWisdom)
                applyFilters()
                
                // Atualizar cache
                try? cache.cache(wisdomEntries, for: .wisdom)
                
                print("✅ Wisdom entry created in Supabase")
            } else {
                // Offline: adicionar localmente e enfileirar
                wisdomEntries.append(newWisdom)
                applyFilters()
                
                let operation = try syncManager.createInsertOperation(newWisdom, in: "wisdom_entries")
                syncManager.queueOperation(operation)
                
                print("⚠️ Wisdom entry queued for sync (offline)")
            }
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    /// Atualiza uma entrada de wisdom existente
    func updateWisdom(_ wisdom: Wisdom) async {
        isLoading = true
        
        do {
            // Validar wisdom
            try wisdom.validate()
            
            if supabase.isOnline {
                // Atualizar no Supabase
                let updatedWisdom: Wisdom = try await supabase.update(wisdom, in: "wisdom_entries", id: wisdom.id)
                
                if let index = wisdomEntries.firstIndex(where: { $0.id == wisdom.id }) {
                    wisdomEntries[index] = updatedWisdom
                    applyFilters()
                }
                
                // Atualizar cache
                try? cache.cache(wisdomEntries, for: .wisdom)
                
                print("✅ Wisdom entry updated in Supabase")
            } else {
                // Offline: atualizar localmente e enfileirar
                if let index = wisdomEntries.firstIndex(where: { $0.id == wisdom.id }) {
                    wisdomEntries[index] = wisdom
                    applyFilters()
                }
                
                let operation = try syncManager.createUpdateOperation(wisdom, in: "wisdom_entries", id: wisdom.id)
                syncManager.queueOperation(operation)
                
                print("⚠️ Wisdom entry update queued for sync (offline)")
            }
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    /// Deleta uma entrada de wisdom
    func deleteWisdom(_ wisdom: Wisdom) async {
        isLoading = true
        
        do {
            if supabase.isOnline {
                // Deletar do Supabase
                try await supabase.delete(from: "wisdom_entries", id: wisdom.id)
                wisdomEntries.removeAll { $0.id == wisdom.id }
                applyFilters()
                
                // Atualizar cache
                try? cache.cache(wisdomEntries, for: .wisdom)
                
                print("✅ Wisdom entry deleted from Supabase")
            } else {
                // Offline: remover localmente e enfileirar
                wisdomEntries.removeAll { $0.id == wisdom.id }
                applyFilters()
                
                let operation = syncManager.createDeleteOperation(id: wisdom.id, from: "wisdom_entries")
                syncManager.queueOperation(operation)
                
                print("⚠️ Wisdom entry deletion queued for sync (offline)")
            }
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    // MARK: - Realtime Subscription
    
    /// Subscreve a mudanças em tempo real nas wisdom entries
    func subscribeToChanges() {
        guard let userId = AuthManager.shared.currentUser?.id else {
            print("⚠️ Cannot subscribe: no user ID")
            return
        }
        
        realtimeChannel = supabase.subscribe(
            to: "wisdom_entries",
            event: .all,
            filter: "user_id=eq.\(userId.uuidString)"
        ) { [weak self] (updatedEntries: [Wisdom]) in
            guard let self = self else { return }
            
            _Concurrency.Task { [weak self] in
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.wisdomEntries = updatedEntries
                    self.applyFilters()
                    
                    // Atualizar cache
                    try? self.cache.cache(updatedEntries, for: .wisdom)
                    
                    print("✅ Wisdom entries updated via Realtime")
                }
            }
        }
    }
    
    /// Cancela subscrição Realtime
    func unsubscribeFromChanges() async {
        if let channel = realtimeChannel {
            await supabase.unsubscribe(from: channel)
            realtimeChannel = nil
            print("✅ Unsubscribed from wisdom entries Realtime")
        }
    }
    
    // MARK: - Filtering and Search
    
    /// Aplica filtros às entradas de wisdom
    func applyFilters() {
        var filtered = wisdomEntries
        
        // Filtro por categoria
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Filtro por emoção
        if let emotion = selectedEmotion {
            filtered = filtered.filter { $0.emotion == emotion }
        }
        
        // Filtro por tags selecionadas
        if !selectedTags.isEmpty {
            filtered = filtered.filter { wisdom in
                selectedTags.allSatisfy { selectedTag in
                    wisdom.tags.contains { tag in
                        tag.contains(selectedTag.lowercased())
                    }
                }
            }
        }
        
        // Filtro por texto de busca
        if !searchText.isEmpty {
            filtered = filtered.filter { wisdom in
                wisdom.contains(keyword: searchText)
            }
        }
        
        filteredEntries = filtered.sorted { wisdom1, wisdom2 in
            // Ordenar por data de criação (mais recentes primeiro)
            return wisdom1.createdAt > wisdom2.createdAt
        }
    }
    
    /// Define filtro por categoria
    func setCategoryFilter(_ category: WisdomCategory?) {
        selectedCategory = category
        applyFilters()
    }
    
    /// Define filtro por emoção
    func setEmotionFilter(_ emotion: Emotion?) {
        selectedEmotion = emotion
        applyFilters()
    }
    
    /// Atualiza texto de busca
    func updateSearchText(_ text: String) {
        searchText = text
        applyFilters()
    }
    
    /// Adiciona/remove tag do filtro
    func toggleTagFilter(_ tag: String) {
        let cleanTag = tag.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if selectedTags.contains(cleanTag) {
            selectedTags.remove(cleanTag)
        } else {
            selectedTags.insert(cleanTag)
        }
        applyFilters()
    }
    
    /// Limpa todos os filtros
    func clearFilters() {
        selectedCategory = nil
        selectedEmotion = nil
        selectedTags.removeAll()
        searchText = ""
        applyFilters()
    }
    
    /// Recarrega dados (útil após login)
    func reload() async {
        await loadWisdomEntries()
        subscribeToChanges()
    }
    
    // MARK: - Computed Properties
    
    /// Todas as tags únicas disponíveis
    var availableTags: [String] {
        let allTags = wisdomEntries.flatMap { $0.tags }
        return Array(Set(allTags)).sorted()
    }
    
    /// Estatísticas das entradas de wisdom
    var wisdomStats: WisdomStats {
        return WisdomStats(
            total: wisdomEntries.count,
            byCategory: Dictionary(grouping: wisdomEntries, by: { $0.category })
                .mapValues { $0.count },
            byEmotion: Dictionary(grouping: wisdomEntries, by: { $0.emotion })
                .mapValues { $0.count },
            totalTags: availableTags.count
        )
    }
    
    /// Entradas sugeridas baseadas no estado emocional atual
    func getSuggestedWisdom(for emotion: Emotion) -> [Wisdom] {
        return wisdomEntries
            .filter { $0.isAppropriateFor(currentEmotion: emotion) }
            .prefix(3)
            .map { $0 }
    }
    
    /// Busca entradas por palavra-chave
    func searchWisdom(keyword: String) -> [Wisdom] {
        guard !keyword.isEmpty else { return wisdomEntries }
        
        return wisdomEntries.filter { wisdom in
            wisdom.contains(keyword: keyword)
        }
    }
    
    /// Entradas recentes (últimos 7 dias)
    var recentEntries: [Wisdom] {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return wisdomEntries
            .filter { $0.createdAt >= sevenDaysAgo }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    /// Entradas favoritas (baseado em categoria de gratidão e insights)
    var favoriteEntries: [Wisdom] {
        return wisdomEntries
            .filter { $0.category == .gratitude || $0.category == .insight }
            .sorted { $0.createdAt > $1.createdAt }
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
            message = "Erro ao processar wisdom. Tente novamente."
        }
        
        showErrorMessage(message)
    }
    
    /// Valida conteúdo antes de salvar
    func validateContent(_ content: String) -> Bool {
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedContent.count >= 10 // Mínimo 10 caracteres
    }
    
    /// Processa tags de entrada
    func processTags(_ tagsString: String) -> [String] {
        return tagsString
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }
    }
}

// MARK: - Wisdom Stats

/// Estrutura para estatísticas das entradas de wisdom
struct WisdomStats {
    let total: Int
    let byCategory: [WisdomCategory: Int]
    let byEmotion: [Emotion: Int]
    let totalTags: Int
    
    /// Categoria mais usada
    var mostUsedCategory: WisdomCategory? {
        return byCategory.max(by: { $0.value < $1.value })?.key
    }
    
    /// Emoção mais registrada
    var mostRegisteredEmotion: Emotion? {
        return byEmotion.max(by: { $0.value < $1.value })?.key
    }
}