//
//  QuickAddWisdomView.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import SwiftUI

/// View to quickly add wisdom do Dashboard
struct QuickAddWisdomView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var content: String = ""
    @State private var selectedCategory: WisdomCategory = .reflection
    @State private var selectedEmotion: Emotion = .calm
    @State private var tags: String = ""
    @State private var isCreating = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Formulário
                    formSection
                    
                    // Sugestão baseada no estado atual
                    suggestionSection
                    
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
                        createWisdom()
                    }
                    .disabled(content.isEmpty || isCreating)
                }
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Capture Wisdom")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Record a learning, reflection or important insight")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Formulário
    
    private var formSection: some View {
        VStack(spacing: 16) {
            // Conteúdo
            VStack(alignment: .leading, spacing: 8) {
                Text("Content *")
                    .font(.headline)
                
                TextField("Compartilhe seu aprendizado, reflexão ou insight...", text: $content, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...8)
            }
            
            // Categoria
            VStack(alignment: .leading, spacing: 12) {
                Text("Categoria")
                    .font(.headline)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    ForEach(WisdomCategory.allCases, id: \.self) { category in
                        CategoryButton(
                            category: category,
                            isSelected: selectedCategory == category
                        ) {
                            selectedCategory = category
                        }
                    }
                }
            }
            
            // Emoção
            VStack(alignment: .leading, spacing: 12) {
                Text("Estado Emocional")
                    .font(.headline)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                    ForEach(Emotion.allCases, id: \.self) { emotion in
                        EmotionButton(
                            emotion: emotion,
                            isSelected: selectedEmotion == emotion
                        ) {
                            selectedEmotion = emotion
                        }
                    }
                }
            }
            
            // Tags
            VStack(alignment: .leading, spacing: 8) {
                Text("Tags")
                    .font(.headline)
                
                TextField("Ex: trabalho, relacionamentos, crescimento...", text: $tags)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Text("Separate tags with commas")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Sugestão
    
    private var suggestionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Suggestion")
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(getSuggestionText())
                    .font(.body)
                
                if let prompt = getSuggestedPrompt() {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Prompt sugerido:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Button(prompt) {
                            content = prompt
                            selectedCategory = getSuggestedCategory()
                            selectedEmotion = viewModel.currentEmotion
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.leading)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.yellow.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Preview
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preview")
                .font(.headline)
            
            WisdomPreviewCard(
                content: content,
                category: selectedCategory,
                emotion: selectedEmotion,
                tags: parseTags()
            )
        }
    }
    
    // MARK: - Actions
    
    private func createWisdom() {
        isCreating = true
        
        _Concurrency.Task {
            await viewModel.quickAddWisdom(
                content: content,
                category: selectedCategory,
                emotion: selectedEmotion
            )
            
            await MainActor.run {
                isCreating = false
                dismiss()
            }
        }
    }
    
    private func parseTags() -> [String] {
        return tags
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    private func getSuggestionText() -> String {
        switch (viewModel.currentEnergyLevel, viewModel.currentEmotion) {
        case (.high, .creative):
            return "Your creativity is high! How about capturing an innovative idea or creative insight?"
        case (.medium, .calm):
            return "Perfect moment for deep reflection. Consider recording an important learning."
        case (.low, .sad):
            return "Sometimes difficult moments bring the greatest learnings. What lesson can you extract?"
        case (_, .grateful):
            return "Gratitude opens doors to wisdom. Record something you're grateful for today."
        default:
            return "Based on your current state, this is a good time to capture insights and learnings."
        }
    }
    
    private func getSuggestedPrompt() -> String? {
        switch (viewModel.currentEnergyLevel, viewModel.currentEmotion) {
        case (.high, .creative):
            return "Today I had an interesting idea about..."
        case (.medium, .calm):
            return "Reflecting on the day, I realized that..."
        case (.low, .sad):
            return "Mesmo nos momentos difíceis, aprendi que..."
        case (_, .grateful):
            return "Sou grato por... porque isso me ensinou que..."
        case (_, .focused):
            return "Durante meu trabalho hoje, descobri que..."
        default:
            return "Uma coisa importante que aprendi recentemente é..."
        }
    }
    
    private func getSuggestedCategory() -> WisdomCategory {
        switch viewModel.currentEmotion {
        case .creative:
            return .insight
        case .calm:
            return .reflection
        case .grateful:
            return .gratitude
        case .focused:
            return .learning
        default:
            return .reflection
        }
    }
}

// MARK: - Supporting Views

/// Botão para seleção de categoria
struct CategoryButton: View {
    let category: WisdomCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : category.color)
                
                Text(category.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? category.color : category.color.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Botão para seleção de emoção
struct EmotionButton: View {
    let emotion: Emotion
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text(emotion.icon)
                    .font(.title3)
                
                Text(emotion.displayName)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.2) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
                    )
            )
            .foregroundColor(isSelected ? .blue : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Card de preview da wisdom
struct QuickWisdomPreviewCard: View {
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
                .padding(.vertical, 4)
                .background(category.color.opacity(0.2))
                .foregroundColor(category.color)
                .cornerRadius(6)
                
                Spacer()
                
                Text(emotion.icon)
                    .font(.caption)
            }
            
            // Conteúdo
            Text(content)
                .font(.body)
                .lineSpacing(2)
            
            // Tags
            if !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Preview

struct QuickAddWisdomView_Previews: PreviewProvider {
    static var previews: some View {
        QuickAddWisdomView(viewModel: DashboardViewModel())
    }
}