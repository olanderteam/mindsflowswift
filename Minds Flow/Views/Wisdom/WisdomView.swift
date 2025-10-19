//
//  WisdomView.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import SwiftUI

/// View principal do sistema Wisdom - Biblioteca pessoal de conhecimentos
struct WisdomView: View {
    @StateObject private var viewModel = WisdomViewModel()
    @State private var showingAddWisdom = false
    @State private var showingFilters = false
    @State private var selectedWisdom: Wisdom?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header com busca e filtros
                wisdomHeader
                
                // Filtros ativos
                if hasActiveFilters {
                    activeFiltersView
                }
                
                // Lista de wisdom
                wisdomList
            }
            .navigationTitle("Wisdom")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddWisdom = true }) {
                        Image(systemName: "plus")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddWisdom) {
                AddWisdomView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingFilters) {
                WisdomFiltersView(viewModel: viewModel)
            }
            .sheet(item: $selectedWisdom) { wisdom in
                WisdomDetailView(wisdom: wisdom, viewModel: viewModel)
            }
            .alert("Erro", isPresented: $viewModel.showError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
    
    // MARK: - Header
    
    private var wisdomHeader: some View {
        VStack(spacing: 12) {
            // Barra de busca
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Buscar wisdom...", text: $viewModel.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onChange(of: viewModel.searchText) { newValue in
                        viewModel.updateSearchText(newValue)
                    }
                
                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.updateSearchText("")
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // Botões de ação
            HStack {
                Button(action: { showingFilters = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text("Filtros")
                        if hasActiveFilters {
                            Text("(\(activeFiltersCount))")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                // Estatísticas rápidas
                HStack(spacing: 16) {
                    StatView(
                        title: "Total",
                        value: "\(viewModel.wisdomStats.total)",
                        icon: "book"
                    )
                    
                    StatView(
                        title: "Tags",
                        value: "\(viewModel.wisdomStats.totalTags)",
                        icon: "tag"
                    )
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    // MARK: - Filtros Ativos
    
    private var activeFiltersView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Filtro de categoria
                if let category = viewModel.selectedCategory {
                    FilterChip(
                        title: category.displayName,
                        icon: category.icon,
                        onRemove: { viewModel.setCategoryFilter(nil) }
                    )
                }
                
                // Filtro de emoção
                if let emotion = viewModel.selectedEmotion {
                    FilterChip(
                        title: emotion.displayName,
                        icon: emotion.icon,
                        onRemove: { viewModel.setEmotionFilter(nil) }
                    )
                }
                
                // Filtros de tags
                ForEach(Array(viewModel.selectedTags), id: \.self) { tag in
                    FilterChip(
                        title: tag,
                        icon: "tag",
                        onRemove: { viewModel.toggleTagFilter(tag) }
                    )
                }
                
                // Botão limpar filtros
                if hasActiveFilters {
                    Button("Limpar") {
                        viewModel.clearFilters()
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - Lista de Wisdom
    
    private var wisdomList: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Carregando wisdom...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.filteredEntries.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(viewModel.filteredEntries) { wisdom in
                        WisdomRowView(wisdom: wisdom)
                            .onTapGesture {
                                selectedWisdom = wisdom
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Deletar", role: .destructive) {
                                    _Concurrency.Task {
                                        await viewModel.deleteWisdom(wisdom)
                                    }
                                }
                            }
                    }
                }
                .listStyle(PlainListStyle())
                .refreshable {
                    await viewModel.loadWisdomEntries()
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(viewModel.wisdomEntries.isEmpty ? "Sua biblioteca está vazia" : "Nenhum resultado encontrado")
                .font(.title2)
                .fontWeight(.medium)
            
            Text(viewModel.wisdomEntries.isEmpty ? 
                 "Comece adicionando seus primeiros insights e reflexões" :
                 "Tente ajustar os filtros ou buscar por outros termos")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if viewModel.wisdomEntries.isEmpty {
                Button("Adicionar Wisdom") {
                    showingAddWisdom = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Computed Properties
    
    private var hasActiveFilters: Bool {
        viewModel.selectedCategory != nil ||
        viewModel.selectedEmotion != nil ||
        !viewModel.selectedTags.isEmpty
    }
    
    private var activeFiltersCount: Int {
        var count = 0
        if viewModel.selectedCategory != nil { count += 1 }
        if viewModel.selectedEmotion != nil { count += 1 }
        count += viewModel.selectedTags.count
        return count
    }
}

// MARK: - Supporting Views

/// View para estatísticas rápidas
struct StatView: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(value)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.blue)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

/// Chip para filtros ativos
struct FilterChip: View {
    let title: String
    let icon: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(title)
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

/// Row para cada entrada de wisdom
struct WisdomRowView: View {
    let wisdom: Wisdom
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header com categoria e emoção
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: wisdom.category.icon)
                    Text(wisdom.category.displayName)
                }
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(wisdom.category.color.opacity(0.2))
                .foregroundColor(wisdom.category.color)
                .cornerRadius(8)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: wisdom.emotion.icon)
                    Text(wisdom.emotion.displayName)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            // Conteúdo
            Text(wisdom.content)
                .font(.body)
                .lineLimit(3)
            
            // Tags e data
            HStack {
                if !wisdom.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(wisdom.tags.prefix(3), id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(6)
                            }
                            if wisdom.tags.count > 3 {
                                Text("+\(wisdom.tags.count - 3)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Spacer()
                
                Text(wisdom.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

struct WisdomView_Previews: PreviewProvider {
    static var previews: some View {
        WisdomView()
    }
}