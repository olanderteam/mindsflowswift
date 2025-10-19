//
//  MentalState.swift
//  Minds Flow
//
//  Created by Kiro on 18/10/25.
//

import Foundation
import SwiftUI

/// Modelo para representar o estado mental do usuário
/// Registra energia (1-10) e emoção em um momento específico
struct MentalState: Codable, Identifiable {
    
    // MARK: - Properties
    let id: UUID
    let userId: UUID
    var mood: Emotion               // Emoção/humor atual
    var energy: Int                 // Nível de energia (1-10)
    var notes: String?              // Notas opcionais
    let createdAt: Date
    
    // MARK: - Supabase Mapping
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case mood
        case energy
        case notes
        case createdAt = "created_at"
    }
    
    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        userId: UUID,
        mood: Emotion,
        energy: Int,
        notes: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.mood = mood
        self.energy = min(max(energy, 1), 10) // Garantir entre 1-10
        self.notes = notes
        self.createdAt = createdAt
    }
    
    // MARK: - Convenience Initializer (com EnergyLevel)
    init(
        id: UUID = UUID(),
        userId: UUID,
        mood: Emotion,
        energyLevel: EnergyLevel,
        notes: String? = nil,
        createdAt: Date = Date()
    ) {
        self.init(
            id: id,
            userId: userId,
            mood: mood,
            energy: MentalState.energyToInt(energyLevel),
            notes: notes,
            createdAt: createdAt
        )
    }
    
    // MARK: - Computed Properties
    
    /// Converte energy (int) para EnergyLevel (enum)
    var energyLevel: EnergyLevel {
        switch energy {
        case 1...3:
            return .low
        case 4...7:
            return .medium
        case 8...10:
            return .high
        default:
            return .medium
        }
    }
    
    /// Retorna descrição do nível de energia
    var energyDescription: String {
        return energyLevel.displayName
    }
    
    /// Retorna cor baseada no estado mental
    var stateColor: Color {
        return mood.color
    }
    
    /// Verifica se o usuário precisa de suporte
    var needsSupport: Bool {
        let negativeEmotions: [Emotion] = [.anxious, .sad, .confused, .tired]
        return negativeEmotions.contains(mood) || energy <= 3
    }
    
    /// Retorna recomendação baseada no estado
    var recommendation: String {
        switch (energyLevel, mood) {
        case (.high, .motivated), (.high, .creative):
            return "Ótimo momento para tarefas desafiadoras!"
        case (.high, .anxious):
            return "Canalize essa energia em atividades físicas."
        case (.medium, .focused):
            return "Estado ideal para tarefas de média complexidade."
        case (.low, .calm):
            return "Perfeito para reflexões e tarefas simples."
        case (.low, .tired):
            return "Que tal descansar ou fazer algo reconfortante?"
        case (_, .sad), (_, .anxious):
            return "Momento para autocuidado e atividades que trazem paz."
        default:
            return "Escute seu corpo e mente para escolher a melhor atividade."
        }
    }
    
    // MARK: - Conversion Methods
    
    /// Converte EnergyLevel para Int (1-10)
    static func energyToInt(_ level: EnergyLevel) -> Int {
        switch level {
        case .low:
            return 2
        case .medium:
            return 5
        case .high:
            return 9
        }
    }
    
    /// Converte Int (1-10) para EnergyLevel
    static func intToEnergyLevel(_ value: Int) -> EnergyLevel {
        switch value {
        case 1...3:
            return .low
        case 4...7:
            return .medium
        case 8...10:
            return .high
        default:
            return .medium
        }
    }
}

// MARK: - MentalState Extensions

extension MentalState {
    
    /// Atualiza o estado mental
    mutating func update(
        mood: Emotion? = nil,
        energy: Int? = nil,
        notes: String? = nil
    ) {
        if let mood = mood { self.mood = mood }
        if let energy = energy {
            self.energy = min(max(energy, 1), 10)
        }
        if let notes = notes { self.notes = notes }
    }
    
    /// Valida os dados do estado mental
    /// - Throws: ValidationError se os dados forem inválidos
    func validate() throws {
        guard energy >= 1 && energy <= 10 else {
            throw ValidationError.invalidEnergyValue
        }
        
        if let notes = notes {
            guard notes.count <= 500 else {
                throw ValidationError.notesTooLong
            }
        }
    }
    
    /// Retorna emoji representativo do estado
    var stateEmoji: String {
        return "\(mood.emoji) \(energyLevel.emoji)"
    }
    
    /// Retorna descrição completa do estado
    var fullDescription: String {
        var description = "\(mood.displayName) com \(energyDescription)"
        if let notes = notes, !notes.isEmpty {
            description += " - \(notes)"
        }
        return description
    }
}

// MARK: - Validation Error Extension

extension ValidationError {
    static let invalidEnergyValue = ValidationError.custom("O nível de energia deve estar entre 1 e 10")
    static let notesTooLong = ValidationError.custom("As notas não podem ter mais de 500 caracteres")
}

// MARK: - Timestamped Protocol

extension MentalState: Timestamped {
    var updatedAt: Date {
        return createdAt // MentalState é imutável após criação
    }
}

// MARK: - Sample Data

extension MentalState {
    
    /// Dados de exemplo para desenvolvimento e testes
    static let sampleStates: [MentalState] = [
        MentalState(
            userId: UUID(),
            mood: .motivated,
            energy: 9,
            notes: "Acordei muito bem disposto hoje!",
            createdAt: Date()
        ),
        MentalState(
            userId: UUID(),
            mood: .focused,
            energy: 7,
            notes: "Bom foco para trabalhar",
            createdAt: Date().addingTimeInterval(-3600)
        ),
        MentalState(
            userId: UUID(),
            mood: .calm,
            energy: 4,
            notes: "Momento de relaxar",
            createdAt: Date().addingTimeInterval(-7200)
        ),
        MentalState(
            userId: UUID(),
            mood: .tired,
            energy: 2,
            notes: "Preciso descansar",
            createdAt: Date().addingTimeInterval(-10800)
        )
    ]
    
    /// Estado de exemplo com energia alta
    static let highEnergyState = MentalState(
        userId: UUID(),
        mood: .motivated,
        energyLevel: .high,
        notes: "Pronto para grandes desafios!"
    )
    
    /// Estado de exemplo com energia baixa
    static let lowEnergyState = MentalState(
        userId: UUID(),
        mood: .tired,
        energyLevel: .low,
        notes: "Dia cansativo"
    )
}
