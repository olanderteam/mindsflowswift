//
//  UsageStats.swift
//  Minds Flow
//
//  Created by Kiro on 18/10/25.
//

import Foundation

/// Model to represent application usage statistics
/// Aggregates user activity metrics
struct UsageStats: Codable, Identifiable {
    
    // MARK: - Properties
    let id: UUID
    let userId: UUID
    var wisdomEntriesCount: Int?
    var totalTasks: Int?
    var completedTasks: Int?
    var mentalStateEntries: Int?
    var timelineEvents: Int?
    var userSince: Date?
    let createdAt: Date
    let updatedAt: Date
    
    // MARK: - Supabase Mapping
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case wisdomEntriesCount = "wisdom_entries_count"
        case totalTasks = "total_tasks"
        case completedTasks = "completed_tasks"
        case mentalStateEntries = "mental_state_entries"
        case timelineEvents = "timeline_events"
        case userSince = "user_since"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        userId: UUID,
        wisdomEntriesCount: Int? = nil,
        totalTasks: Int? = nil,
        completedTasks: Int? = nil,
        mentalStateEntries: Int? = nil,
        timelineEvents: Int? = nil,
        userSince: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.wisdomEntriesCount = wisdomEntriesCount
        self.totalTasks = totalTasks
        self.completedTasks = completedTasks
        self.mentalStateEntries = mentalStateEntries
        self.timelineEvents = timelineEvents
        self.userSince = userSince
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - UsageStats Extensions

extension UsageStats {
    
    /// Task completion rate (0.0 to 1.0)
    var completionRate: Double {
        guard let total = totalTasks, total > 0,
              let completed = completedTasks else { return 0 }
        return Double(completed) / Double(total)
    }
    
    /// Taxa de conclusão formatada como porcentagem
    var completionRatePercentage: String {
        return "\(Int(completionRate * 100))%"
    }
    
    /// Pending tasks
    var pendingTasks: Int {
        guard let total = totalTasks,
              let completed = completedTasks else { return 0 }
        return max(0, total - completed)
    }
    
    /// Total de atividades registradas
    var totalActivities: Int {
        return (wisdomEntriesCount ?? 0) +
               (totalTasks ?? 0) +
               (mentalStateEntries ?? 0) +
               (timelineEvents ?? 0)
    }
    
    /// Média de atividades por dia
    var averageActivitiesPerDay: Double? {
        guard let since = userSince else { return nil }
        
        let days = Calendar.current.dateComponents([.day], from: since, to: Date()).day ?? 1
        guard days > 0 else { return nil }
        
        return Double(totalActivities) / Double(days)
    }
    
    /// Média formatada de atividades por dia
    var formattedAveragePerDay: String? {
        guard let average = averageActivitiesPerDay else { return nil }
        return String(format: "%.1f", average)
    }
    
    /// Returns how long the user has been in the system
    var membershipDuration: String? {
        guard let since = userSince else { return nil }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year], from: since, to: Date())
        
        if let years = components.year, years > 0 {
            return "\(years) ano\(years > 1 ? "s" : "")"
        } else if let months = components.month, months > 0 {
            return "\(months) mês\(months > 1 ? "es" : "")"
        } else if let days = components.day, days > 0 {
            return "\(days) dia\(days > 1 ? "s" : "")"
        }
        
        return "Hoje"
    }
    
    /// Returns resumo das estatísticas
    var summary: String {
        var parts: [String] = []
        
        if let wisdom = wisdomEntriesCount, wisdom > 0 {
            parts.append("\(wisdom) wisdom")
        }
        
        if let completed = completedTasks, completed > 0 {
            parts.append("\(completed) completed tasks")
        }
        
        if let mental = mentalStateEntries, mental > 0 {
            parts.append("\(mental) mental records")
        }
        
        return parts.isEmpty ? "Sem atividades ainda" : parts.joined(separator: ", ")
    }
}

// MARK: - Timestamped Protocol

extension UsageStats: Timestamped {}

// MARK: - Sample Data

extension UsageStats {
    
    /// Dados de exemplo para desenvolvimento e testes
    static let sampleStats = UsageStats(
        userId: UUID(),
        wisdomEntriesCount: 15,
        totalTasks: 25,
        completedTasks: 18,
        mentalStateEntries: 30,
        timelineEvents: 10,
        userSince: Date().addingTimeInterval(-86400 * 30) // 30 days ago
    )
    
    static let sampleStatsNewUser = UsageStats(
        userId: UUID(),
        wisdomEntriesCount: 2,
        totalTasks: 5,
        completedTasks: 1,
        mentalStateEntries: 3,
        timelineEvents: 1,
        userSince: Date().addingTimeInterval(-86400 * 2) // 2 days ago
    )
}
