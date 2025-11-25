//
//  WisdomDetailView.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import SwiftUI

/// View to view and edit details de uma entrada de wisdom
struct WisdomDetailView: View {
    let wisdom: Wisdom
    @ObservedObject var viewModel: WisdomViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var isEditing = false
    @State private var editedContent = ""
    @State private var editedCategory: WisdomCategory = .insight
    @State private var editedEmotion: Emotion = .calm
    @State private var editedTagsText = ""
    @State private var showDeleteAlert = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if isEditing {
                        editingView
                    } else {
                        readingView
                    }
                }
                .padding()
            }
            .navigationTitle(isEditing ? "Edit Wisdom" : "Wisdom")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(isEditing ? "Cancelar" : "Fechar") {
                        if isEditing {
                            cancelEditing()
                        } else {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isEditing {
                        Button("Save") {
                            saveChanges()
                        }
                        .disabled(isLoading || !isFormValid)
                        .fontWeight(.semibold)
                    } else {
                        Menu {
                            Button("Edit", systemImage: "pencil") {
                                startEditing()
                            }
                            
                            Button("Share", systemImage: "square.and.arrow.up") {
                                shareWisdom()
                            }
                            
                            Divider()
                            
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                showDeleteAlert = true
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .alert("Delete Wisdom", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteWisdom()
                }
            } message: {
                Text("This action cannot be undone.")
            }
        }
        .onAppear {
            setupInitialValues()
        }
    }
    
    // MARK: - Reading View
    
    private var readingView: some View {
        VStack(spacing: 20) {
            // Header com categoria e emoção
            headerSection
            
            // Conteúdo principal
            contentSection
            
            // Tags
            if !wisdom.tags.isEmpty {
                tagsSection
            }
            
            // Metadata
            metadataSection
            
            // Ações rápidas
            quickActionsSection
        }
    }
    
    // MARK: - Editing View
    
    private var editingView: some View {
        VStack(spacing: 20) {
            // Conteúdo editável
            editContentSection
            
            // Categoria editável
            editCategorySection
            
            // Emoção editável
            editEmotionSection
            
            // Tags editáveis
            editTagsSection
        }
    }
    
    // MARK: - Reading Sections
    
    private var headerSection: some View {
        HStack {
            // Categoria
            HStack(spacing: 6) {
                Image(systemName: wisdom.category.icon)
                    .font(.title3)
                Text(wisdom.category.displayName)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(wisdom.category.color.opacity(0.2))
            .foregroundColor(wisdom.category.color)
            .cornerRadius(12)
            
            Spacer()
            
            // Emoção
            HStack(spacing: 4) {
                Text(wisdom.emotion.icon)
                    .font(.title2)
                Text(wisdom.emotion.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(.secondary)
        }
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Conteúdo")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(wisdom.content)
                .font(.body)
                .lineSpacing(4)
                .padding(16)
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
    }
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tags")
                .font(.headline)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(wisdom.tags, id: \.self) { tag in
                    HStack(spacing: 4) {
                        Image(systemName: "tag")
                            .font(.caption)
                        Text(tag)
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                }
            }
        }
    }
    
    private var metadataSection: some View {
        VStack(spacing: 12) {
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Criado em")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(wisdom.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline)
                }
                
                Spacer()
                
                if wisdom.updatedAt != wisdom.createdAt {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Updated em")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(wisdom.updatedAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.subheadline)
                    }
                }
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            Divider()
            
            HStack(spacing: 16) {
                Button("Share") {
                    shareWisdom()
                }
                .buttonStyle(.bordered)
                
                Button("Edit") {
                    startEditing()
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
        }
    }
    
    // MARK: - Editing Sections
    
    private var editContentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Conteúdo")
                    .font(.headline)
                Text("*")
                    .foregroundColor(.red)
                Spacer()
                Text("\(editedContent.count) caracteres")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            TextEditor(text: $editedContent)
                .frame(minHeight: 120)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(editedContent.isEmpty ? Color.clear : Color.blue, lineWidth: 1)
                )
            
            if editedContent.count < 10 && !editedContent.isEmpty {
                Text("Mínimo 10 caracteres")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    private var editCategorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categoria")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(WisdomCategory.allCases, id: \.self) { category in
                    CategoryCard(
                        category: category,
                        isSelected: editedCategory == category
                    ) {
                        editedCategory = category
                    }
                }
            }
        }
    }
    
    private var editEmotionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Estado Emocional")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                ForEach(Emotion.allCases, id: \.self) { emotion in
                    EmotionChip(
                        emotion: emotion,
                        isSelected: editedEmotion == emotion
                    ) {
                        editedEmotion = emotion
                    }
                }
            }
        }
    }
    
    private var editTagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags")
                .font(.headline)
            
            TextField("Separe as tags por vírgula", text: $editedTagsText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // Preview das tags editadas
            if !processedEditedTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(processedEditedTags, id: \.self) { tag in
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
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        return viewModel.validateContent(editedContent)
    }
    
    private var processedEditedTags: [String] {
        return viewModel.processTags(editedTagsText)
    }
    
    // MARK: - Actions
    
    private func setupInitialValues() {
        editedContent = wisdom.content
        editedCategory = wisdom.category
        editedEmotion = wisdom.emotion
        editedTagsText = wisdom.tags.joined(separator: ", ")
    }
    
    private func startEditing() {
        isEditing = true
    }
    
    private func cancelEditing() {
        setupInitialValues()
        isEditing = false
    }
    
    private func saveChanges() {
        guard isFormValid else { return }
        
        isLoading = true
        
        var updatedWisdom = wisdom
        updatedWisdom.update(
            content: editedContent,
            category: editedCategory,
            emotion: editedEmotion,
            tags: processedEditedTags
        )
        
        _Concurrency.Task {
            await viewModel.updateWisdom(updatedWisdom)
            
            await MainActor.run {
                isLoading = false
                isEditing = false
            }
        }
    }
    
    private func deleteWisdom() {
        _Concurrency.Task {
            await viewModel.deleteWisdom(wisdom)
            
            await MainActor.run {
                dismiss()
            }
        }
    }
    
    private func shareWisdom() {
        let shareText = """
        💡 Wisdom - \(wisdom.category.displayName)
        
        \(wisdom.content)
        
        Estado: \(wisdom.emotion.displayName) \(wisdom.emotion.icon)
        Tags: \(wisdom.tags.map { "#\($0)" }.joined(separator: " "))
        
        Criado em \(wisdom.createdAt.formatted(date: .abbreviated, time: .omitted))
        """
        
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

// MARK: - Preview

struct WisdomDetailView_Previews: PreviewProvider {
    static var previews: some View {
        WisdomDetailView(
            wisdom: Wisdom.sampleWisdom[0],
            viewModel: WisdomViewModel()
        )
    }
}