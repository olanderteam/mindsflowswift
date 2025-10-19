//
//  Task.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import Foundation
import SwiftUI

/// Modelo para representar uma tarefa no sistema Minds Flow
/// Cada tarefa tem significado e está conectada ao nível de energia do usuário
struct Task: Codable, Identifiable {
    
    // MARK: - Properties
    let id: UUID
    var title: String
    var description: String?        // Opcional - pode ser NULL no banco
    var energyLevel: EnergyLevel
    var purpose: String?            // Opcional - pode ser NULL no banco
    var isCompleted: Bool
    var dueDate: Date?              // NOVO: Data de vencimento
    var timeEstimate: Int?          // NOVO: Estimativa de tempo em minutos
    var createdAt: Date
    var updatedAt: Date
    var completedAt: Date?
    let userId: UUID                // Mudado de String para UUID
    
    // MARK: - Supabase Mapping
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case energyLevel = "energy"
        case purpose
        case isCompleted = "completed"
        case dueDate = "due_date"
        case timeEstimate = "time_estimate"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case completedAt = "completed_at"
        case userId = "user_id"
    }
    
    // MARK: - Custom Decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        energyLevel = try container.decode(EnergyLevel.self, forKey: .energyLevel)
        purpose = try container.decodeIfPresent(String.self, forKey: .purpose)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
        
        // Decodificar time_estimate que pode vir como String ou Int
        if let timeEstimateInt = try? container.decodeIfPresent(Int.self, forKey: .timeEstimate) {
            timeEstimate = timeEstimateInt
        } else if let timeEstimateString = try? container.decodeIfPresent(String.self, forKey: .timeEstimate) {
            timeEstimate = Int(timeEstimateString)
        } else {
            timeEstimate = nil
        }
        
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        completedAt = try container.decodeIfPresent(Date.self, forKey: .completedAt)
        userId = try container.decode(UUID.self, forKey: .userId)
    }
    
    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        energyLevel: EnergyLevel,
        purpose: String? = nil,
        isCompleted: Bool = false,
        dueDate: Date? = nil,
        timeEstimate: Int? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        completedAt: Date? = nil,
        userId: UUID
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.energyLevel = energyLevel
        self.purpose = purpose
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.timeEstimate = timeEstimate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.completedAt = completedAt
        self.userId = userId
    }
    
    // MARK: - Convenience Initializer (backward compatibility)
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        energyLevel: EnergyLevel,
        purpose: String,
        isCompleted: Bool = false,
        dueDate: Date? = nil,
        timeEstimate: Int? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        completedAt: Date? = nil,
        userId: String
    ) {
        self.init(
            id: id,
            title: title,
            description: description,
            energyLevel: energyLevel,
            purpose: purpose,
            isCompleted: isCompleted,
            dueDate: dueDate,
            timeEstimate: timeEstimate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            completedAt: completedAt,
            userId: UUID(uuidString: userId) ?? UUID()
        )
    }
}

// MARK: - Energy Level Enum

/// Níveis de energia para categorizar tarefas
enum EnergyLevel: String, CaseIterable, Codable {
    case high = "high"
    case medium = "medium"
    case low = "low"
    
    /// Descrição legível do nível de energia
    var displayName: String {
        switch self {
        case .high:
            return "Alta Energia"
        case .medium:
            return "Média Energia"
        case .low:
            return "Baixa Energia"
        }
    }
    
    /// Emoji representativo do nível de energia
    var emoji: String {
        switch self {
        case .high:
            return "⚡️"
        case .medium:
            return "🔋"
        case .low:
            return "🪫"
        }
    }
    
    /// Cor associada ao nível de energia
    var colorName: String {
        switch self {
        case .high:
            return "red"
        case .medium:
            return "orange"
        case .low:
            return "green"
        }
    }
    
    /// Ícone do SF Symbols para o nível de energia
    var icon: String {
        switch self {
        case .high:
            return "bolt.fill"
        case .medium:
            return "battery.50percent"
        case .low:
            return "battery.25percent"
        }
    }
    
    /// Cor para UI do nível de energia
    var color: Color {
        switch self {
        case .high:
            return .red
        case .medium:
            return .orange
        case .low:
            return .green
        }
    }
}

// MARK: - Task Extensions

extension Task {
    
    /// Marca a tarefa como concluída
    mutating func markAsCompleted() {
        self.isCompleted = true
        self.completedAt = Date()
        self.updatedAt = Date()
    }
    
    /// Marca a tarefa como não concluída
    mutating func markAsIncomplete() {
        self.isCompleted = false
        self.completedAt = nil
        self.updatedAt = Date()
    }
    
    /// Atualiza os dados da tarefa
    mutating func update(
        title: String? = nil,
        description: String? = nil,
        energyLevel: EnergyLevel? = nil,
        purpose: String? = nil,
        dueDate: Date? = nil,
        timeEstimate: Int? = nil
    ) {
        if let title = title { self.title = title }
        if let description = description { self.description = description }
        if let energyLevel = energyLevel { self.energyLevel = energyLevel }
        if let purpose = purpose { self.purpose = purpose }
        if let dueDate = dueDate { self.dueDate = dueDate }
        if let timeEstimate = timeEstimate { self.timeEstimate = timeEstimate }
        self.updatedAt = Date()
    }
    
    /// Valida os dados da tarefa
    /// - Throws: ValidationError se os dados forem inválidos
    func validate() throws {
        guard !title.isEmpty else {
            throw ValidationError.emptyTitle
        }
        
        guard title.count <= 200 else {
            throw ValidationError.titleTooLong
        }
        
        if let estimate = timeEstimate {
            guard estimate > 0 && estimate <= 1440 else {
                throw ValidationError.invalidTimeEstimate
            }
        }
        
        if let due = dueDate, due < Date().addingTimeInterval(-86400) {
            // Permitir datas até 1 dia no passado (para tarefas atrasadas)
            throw ValidationError.invalidDueDate
        }
    }
    
    /// Verifica se a tarefa está atrasada
    var isOverdue: Bool {
        guard let due = dueDate, !isCompleted else { return false }
        return due < Date()
    }
    
    /// Retorna o tempo estimado formatado
    var formattedTimeEstimate: String? {
        guard let estimate = timeEstimate else { return nil }
        
        if estimate < 60 {
            return "\(estimate) min"
        } else {
            let hours = estimate / 60
            let minutes = estimate % 60
            if minutes == 0 {
                return "\(hours)h"
            } else {
                return "\(hours)h \(minutes)min"
            }
        }
    }
    
    /// Retorna a data de vencimento formatada
    var formattedDueDate: String? {
        guard let due = dueDate else { return nil }
        
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(due) {
            return "Hoje"
        } else if calendar.isDateInTomorrow(due) {
            return "Amanhã"
        } else if calendar.isDateInYesterday(due) {
            return "Ontem"
        } else {
            formatter.dateStyle = .short
            return formatter.string(from: due)
        }
    }
    
    /// Verifica se a tarefa é adequada para o nível de energia atual
    func isAppropriateFor(currentEnergyLevel: EnergyLevel) -> Bool {
        switch currentEnergyLevel {
        case .high:
            return true // Pode fazer qualquer tarefa
        case .medium:
            return self.energyLevel == .medium || self.energyLevel == .low
        case .low:
            return self.energyLevel == .low
        }
    }
}



// MARK: - Timestamped Protocol

extension Task: Timestamped {}

// MARK: - Sample Data

extension Task {
    
    /// Dados de exemplo para desenvolvimento e testes
    static let sampleTasks: [Task] = [
        Task(
            title: "Revisar projeto importante",
            description: "Analisar documentação e preparar apresentação",
            energyLevel: .high,
            purpose: "Crescimento profissional e impacto no trabalho",
            dueDate: Date().addingTimeInterval(86400 * 2), // 2 dias
            timeEstimate: 120, // 2 horas
            userId: UUID()
        ),
        Task(
            title: "Organizar mesa de trabalho",
            description: "Limpar e organizar o espaço de trabalho",
            energyLevel: .medium,
            purpose: "Criar ambiente mais produtivo",
            dueDate: Date().addingTimeInterval(86400), // 1 dia
            timeEstimate: 30, // 30 minutos
            userId: UUID()
        ),
        Task(
            title: "Meditar por 10 minutos",
            description: "Prática de mindfulness para relaxamento",
            energyLevel: .low,
            purpose: "Bem-estar mental e redução do estresse",
            timeEstimate: 10, // 10 minutos
            userId: UUID()
        )
    ]
}