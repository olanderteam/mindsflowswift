//
//  AddWisdomView.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import SwiftUI

/// View to add new wisdom entry
struct AddWisdomView: View {
    @ObservedObject var viewModel: WisdomViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var content = ""
    @State private var selectedCategory: WisdomCategory = .insight
    @State private var selectedEmotion: Emotion = .calm
    @State private var tagsText = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Conteúdo
                    contentSection
                    
                    // Categoria
                    categorySection
                    
                    // Emoção
                    emotionSection
                    
                    // Tags
                    tagsSection
                    
                    // Preview
                    if !content.isEmpty {
                        previewSection
                    }
                }
                .padding()
            }
            .navigationTitle("New Wisdom")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveWisdom()
                    }
                    .disabled(!isFormValid || isLoading)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 40))
                .foregroundColor(.yellow)
            
            Text("Capture your insights")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Record reflections, learnings and moments of wisdom")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Conteúdo")
                    .font(.headline)
                Text("*")
                    .foregroundColor(.red)
                Spacer()
                Text("\(content.count) caracteres")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            TextEditor(text: $content)
                .frame(minHeight: 120)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(content.isEmpty ? Color.clear : Color.blue, lineWidth: 1)
                )
            
            if content.count < 10 && !content.isEmpty {
                Text("Mínimo 10 caracteres")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categoria")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(WisdomCategory.allCases, id: \.self) { category in
                    CategoryCard(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
        }
    }
    
    private var emotionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Estado Emocional")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                ForEach(Emotion.allCases, id: \.self) { emotion in
                    WisdomEmotionChip(
                        emotion: emotion,
                        isSelected: selectedEmotion == emotion
                    ) {
                        selectedEmotion = emotion
                    }
                }
            }
        }
    }
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags (opcional)")
                .font(.headline)
            
            TextField("Separe as tags por vírgula", text: $tagsText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Text("Ex: meditação, trabalho, relacionamentos")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Preview das tags
            if !processedTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(processedTags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
        }
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preview")
                .font(.headline)
            
            WisdomPreviewCard(
                content: content,
                category: selectedCategory,
                emotion: selectedEmotion,
                tags: processedTags
            )
        }
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        return viewModel.validateContent(content)
    }
    
    private var processedTags: [String] {
        return viewModel.processTags(tagsText)
    }
    
    // MARK: - Actions
    
    private func saveWisdom() {
        guard isFormValid else {
            showErrorMessage("Conteúdo deve ter pelo menos 10 caracteres")
            return
        }
        
        isLoading = true
        
        _Concurrency.Task {
            await viewModel.createWisdom(
                content: content,
                category: selectedCategory,
                emotion: selectedEmotion,
                tags: processedTags
            )
            
            await MainActor.run {
                isLoading = false
                dismiss()
            }
        }
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
}

// MARK: - Supporting Views

/// Card para seleção de categoria
struct CategoryCard: View {
    let category: WisdomCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : category.color)
                
                Text(category.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(height: 60)
            .frame(maxWidth: .infinity)
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

/// Chip para seleção de emoção
struct WisdomEmotionChip: View {
    let emotion: Emotion
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Text(emotion.icon)
                    .font(.caption)
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

/// Card de preview da wisdom
struct WisdomPreviewCard: View {
    let content: String
    let category: WisdomCategory
    let emotion: Emotion
    let tags: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: category.icon)
                    Text(category.displayName)
                }
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(category.color.opacity(0.2))
                .foregroundColor(category.color)
                .cornerRadius(8)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text(emotion.icon)
                    Text(emotion.displayName)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            // Conteúdo
            Text(content)
                .font(.body)
            
            // Tags
            if !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(.systemGray5))
                                .cornerRadius(6)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Preview

struct AddWisdomView_Previews: PreviewProvider {
    static var previews: some View {
        AddWisdomView(viewModel: WisdomViewModel())
    }
}