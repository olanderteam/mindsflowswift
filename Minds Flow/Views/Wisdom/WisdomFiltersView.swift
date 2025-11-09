//
//  WisdomFiltersView.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import SwiftUI

/// View to advanced filters do sistema Wisdom
struct WisdomFiltersView: View {
    @ObservedObject var viewModel: WisdomViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempSelectedCategory: WisdomCategory?
    @State private var tempSelectedEmotion: Emotion?
    @State private var tempSelectedTags: Set<String> = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Filter by category
                    categoryFilterSection
                    
                    // Filter by emotion
                    emotionFilterSection
                    
                    // Filter by tags
                    tagsFilterSection
                    
                    // Filter statistics
                    filterStatsSection
                }
                .padding()
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        applyFilters()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                loadCurrentFilters()
            }
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            Text("Filter Wisdom")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Encontre exatamente o que você procura")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var categoryFilterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Category")
                    .font(.headline)
                
                Spacer()
                
                if tempSelectedCategory != nil {
                    Button("Clear") {
                        tempSelectedCategory = nil
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(WisdomCategory.allCases, id: \.self) { category in
                    FilterCategoryCard(
                        category: category,
                        isSelected: tempSelectedCategory == category,
                        count: viewModel.wisdomStats.byCategory[category] ?? 0
                    ) {
                        if tempSelectedCategory == category {
                            tempSelectedCategory = nil
                        } else {
                            tempSelectedCategory = category
                        }
                    }
                }
            }
        }
    }
    
    private var emotionFilterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Estado Emocional")
                    .font(.headline)
                
                Spacer()
                
                if tempSelectedEmotion != nil {
                    Button("Clear") {
                        tempSelectedEmotion = nil
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                ForEach(Emotion.allCases, id: \.self) { emotion in
                    FilterEmotionChip(
                        emotion: emotion,
                        isSelected: tempSelectedEmotion == emotion,
                        count: viewModel.wisdomStats.byEmotion[emotion] ?? 0
                    ) {
                        if tempSelectedEmotion == emotion {
                            tempSelectedEmotion = nil
                        } else {
                            tempSelectedEmotion = emotion
                        }
                    }
                }
            }
        }
    }
    
    private var tagsFilterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Tags")
                    .font(.headline)
                
                Spacer()
                
                if !tempSelectedTags.isEmpty {
                    Button("Clear") {
                        tempSelectedTags.removeAll()
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
            }
            
            if viewModel.availableTags.isEmpty {
                Text("No tags available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    ForEach(viewModel.availableTags, id: \.self) { tag in
                        FilterTagChip(
                            tag: tag,
                            isSelected: tempSelectedTags.contains(tag)
                        ) {
                            if tempSelectedTags.contains(tag) {
                                tempSelectedTags.remove(tag)
                            } else {
                                tempSelectedTags.insert(tag)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var filterStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Resultado dos Filtros")
                .font(.headline)
            
            HStack(spacing: 16) {
                FilterStatCard(
                    title: "Total de Entradas",
                    value: "\(viewModel.wisdomStats.total)",
                    icon: "book",
                    color: .blue
                )
                
                FilterStatCard(
                    title: "Resultado Estimado",
                    value: "\(estimatedResults)",
                    icon: "magnifyingglass",
                    color: .green
                )
            }
            
            // Ações rápidas
            VStack(spacing: 8) {
                Button("Clear All Filters") {
                    clearAllFilters()
                }
                .foregroundColor(.red)
                
                Button("Apply Suggested Filters") {
                    applySuggestedFilters()
                }
                .foregroundColor(.blue)
            }
            .font(.subheadline)
        }
    }
    
    // MARK: - Computed Properties
    
    private var estimatedResults: Int {
        // Simulação simples do resultado dos filtros
        var filtered = viewModel.wisdomEntries
        
        if let category = tempSelectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        if let emotion = tempSelectedEmotion {
            filtered = filtered.filter { $0.emotion == emotion }
        }
        
        if !tempSelectedTags.isEmpty {
            filtered = filtered.filter { wisdom in
                tempSelectedTags.allSatisfy { selectedTag in
                    wisdom.tags.contains { tag in
                        tag.contains(selectedTag.lowercased())
                    }
                }
            }
        }
        
        return filtered.count
    }
    
    // MARK: - Actions
    
    private func loadCurrentFilters() {
        tempSelectedCategory = viewModel.selectedCategory
        tempSelectedEmotion = viewModel.selectedEmotion
        tempSelectedTags = viewModel.selectedTags
    }
    
    private func applyFilters() {
        viewModel.setCategoryFilter(tempSelectedCategory)
        viewModel.setEmotionFilter(tempSelectedEmotion)
        
        // Apply selected tags
        viewModel.selectedTags = tempSelectedTags
        viewModel.applyFilters()
        
        dismiss()
    }
    
    private func clearAllFilters() {
        tempSelectedCategory = nil
        tempSelectedEmotion = nil
        tempSelectedTags.removeAll()
    }
    
    private func applySuggestedFilters() {
        // Suggest filters based on statistics
        if let mostUsedCategory = viewModel.wisdomStats.mostUsedCategory {
            tempSelectedCategory = mostUsedCategory
        }
        
        if let mostRegisteredEmotion = viewModel.wisdomStats.mostRegisteredEmotion {
            tempSelectedEmotion = mostRegisteredEmotion
        }
    }
}

// MARK: - Supporting Views

/// Card for category filter
struct FilterCategoryCard: View {
    let category: WisdomCategory
    let isSelected: Bool
    let count: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: category.icon)
                        .font(.title3)
                        .foregroundColor(isSelected ? .white : category.color)
                    
                    Spacer()
                    
                    Text("\(count)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(isSelected ? .white : .secondary)
                }
                
                Text(category.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? category.color : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(category.color, lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Chip para filtro de emoção
struct FilterEmotionChip: View {
    let emotion: Emotion
    let isSelected: Bool
    let count: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                HStack(spacing: 2) {
                    Text(emotion.icon)
                        .font(.caption)
                    Text("\(count)")
                        .font(.caption2)
                        .fontWeight(.semibold)
                }
                
                Text(emotion.displayName)
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.blue : Color(.systemGray6))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Chip para filtro de tag
struct FilterTagChip: View {
    let tag: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Image(systemName: "tag")
                    .font(.caption2)
                Text(tag)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue : Color(.systemGray6))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Card for filter statistics
struct FilterStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Preview

struct WisdomFiltersView_Previews: PreviewProvider {
    static var previews: some View {
        WisdomFiltersView(viewModel: WisdomViewModel())
    }
}