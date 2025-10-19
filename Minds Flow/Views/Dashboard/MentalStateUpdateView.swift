//
//  MentalStateUpdateView.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import SwiftUI

/// View para atualizar o estado mental do usuário
struct MentalStateUpdateView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedEnergyLevel: EnergyLevel
    @State private var selectedEmotion: Emotion
    @State private var notes: String = ""
    @State private var isUpdating = false
    
    init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
        self._selectedEnergyLevel = State(initialValue: viewModel.currentEnergyLevel)
        self._selectedEmotion = State(initialValue: viewModel.currentEmotion)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Seleção de energia
                    energySelectionSection
                    
                    // Seleção de emoção
                    emotionSelectionSection
                    
                    // Notas opcionais
                    notesSection
                    
                    // Recomendação baseada na seleção
                    recommendationSection
                }
                .padding()
            }
            .navigationTitle("Estado Mental")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salvar") {
                        updateMentalState()
                    }
                    .disabled(isUpdating)
                }
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Como você está se sentindo agora?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("Compartilhe seu estado atual para receber sugestões personalizadas")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Seleção de Energia
    
    private var energySelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.yellow)
                Text("Nível de Energia")
                    .font(.headline)
            }
            
            VStack(spacing: 12) {
                ForEach(EnergyLevel.allCases, id: \.self) { level in
                    EnergyLevelCard(
                        level: level,
                        isSelected: selectedEnergyLevel == level
                    ) {
                        selectedEnergyLevel = level
                    }
                }
            }
        }
    }
    
    // MARK: - Seleção de Emoção
    
    private var emotionSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                Text("Estado Emocional")
                    .font(.headline)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(Emotion.allCases, id: \.self) { emotion in
                    EmotionChip(
                        emotion: emotion,
                        isSelected: selectedEmotion == emotion
                    ) {
                        selectedEmotion = emotion
                    }
                }
            }
        }
    }
    
    // MARK: - Notas
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "note.text")
                    .foregroundColor(.blue)
                Text("Notas (Opcional)")
                    .font(.headline)
            }
            
            TextField("Como você está se sentindo? O que está acontecendo?", text: $notes, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(3...6)
        }
    }
    
    // MARK: - Recomendação
    
    private var recommendationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Recomendação")
                    .font(.headline)
            }
            
            Text(getRecommendationText())
                .font(.body)
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
    
    // MARK: - Actions
    
    private func updateMentalState() {
        isUpdating = true
        
        _Concurrency.Task {
            await viewModel.updateMentalState(
                energyLevel: selectedEnergyLevel,
                emotion: selectedEmotion,
                notes: notes.isEmpty ? nil : notes
            )
            
            await MainActor.run {
                isUpdating = false
                dismiss()
            }
        }
    }
    
    private func getRecommendationText() -> String {
        switch (selectedEnergyLevel, selectedEmotion) {
        case (.high, .creative):
            return "Ótimo momento para trabalhar em projetos criativos! Considere tarefas que exijam inovação."
        case (.high, .focused):
            return "Aproveite esse foco para tarefas complexas que requerem concentração profunda."
        case (.high, .motivated):
            return "Canalize essa energia em atividades produtivas e colaborativas."
        case (.medium, .calm):
            return "Momento ideal para organização e planejamento. Considere revisar suas metas."
        case (.medium, .calm):
            return "Perfeito para reflexão e aprendizado. Que tal adicionar uma nova wisdom?"
        case (.low, .tired):
            return "Descanse um pouco. Considere tarefas leves ou atividades de autocuidado."
        case (.low, .anxious):
            return "Respire fundo. Foque em uma tarefa simples por vez e pratique mindfulness."
        case (.low, .sad):
            return "Seja gentil consigo mesmo. Considere atividades que tragam conforto e bem-estar."
        default:
            return "Baseado no seu estado atual, vou sugerir atividades adequadas para você."
        }
    }
}

// MARK: - Supporting Views

/// Card para seleção de nível de energia
struct EnergyLevelCard: View {
    let level: EnergyLevel
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: level.icon)
                    .font(.title2)
                    .foregroundColor(level.color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(level.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(level.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Chip para seleção de emoção
struct EmotionChip: View {
    let emotion: Emotion
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Text(emotion.icon)
                    .font(.title2)
                
                Text(emotion.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.2) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
            .foregroundColor(isSelected ? .blue : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Extensions

extension EnergyLevel {
    var description: String {
        switch self {
        case .high:
            return "Cheio de energia e motivação"
        case .medium:
            return "Energia moderada e estável"
        case .low:
            return "Pouca energia, precisa de descanso"
        }
    }
}

// MARK: - Preview

struct MentalStateUpdateView_Previews: PreviewProvider {
    static var previews: some View {
        MentalStateUpdateView(viewModel: DashboardViewModel())
    }
}