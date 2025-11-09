//
//  TimelineEvent.swift
//  Minds Flow
//
//  Created by Kiro on 18/10/25.
//

import Foundation

/// Model to represent user timeline events
/// Aggregates statistics and activities over time
struct TimelineEvent: Codable, Identifiable {
    
    // MARK: - Properties
    let id: UUID
    let userId: UUID
    var actionActivityCount: Int?
    var tasksCompleted: Int?
    var mentalStatusCount: Int?
    var timelineEventCount: Int?
    var userSince: Date?
    let createdAt: Date
    let updatedAt: Date
    
    // MARK: - Supabase Mapping
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case actionActivityCount = "action_activity_count"
        case tasksCompleted = "tasks_completed"
        case mentalStatusCount = "mental_status_count"
        case timelineEventCount = "timeline_event_count"
        case userSince = "user_since"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        userId: UUID,
        actionActivityCount: Int? = nil,
        tasksCompleted: Int? = nil,
        mentalStatusCount: Int? = nil,
        timelineEventCount: Int? = nil,
        userSince: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.actionActivityCount = actionActivityCount
        self.tasksCompleted = tasksCompleted
        self.mentalStatusCount = mentalStatusCount
        self.timelineEventCount = timelineEventCount
        self.userSince = userSince
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - TimelineEvent Extensions

extension TimelineEvent {
    
    /// Returns o total de atividades
    var totalActivities: Int {
        return (actionActivityCount ?? 0) +
               (tasksCompleted ?? 0) +
               (mentalStatusCount ?? 0)
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
    
    /// Returns descrição formatada do evento
    var description: String {
        var parts: [String] = []
        
        if let tasks = tasksCompleted, tasks > 0 {
            parts.append("\(tasks) task\(tasks > 1 ? "s" : "") completed")
        }
        
        if let mental = mentalStatusCount, mental > 0 {
            parts.append("\(mental) mental state record\(mental > 1 ? "s" : "")")
        }
        
        if let activities = actionActivityCount, activities > 0 {
            parts.append("\(activities) atividade\(activities > 1 ? "s" : "")")
        }
        
        return parts.isEmpty ? "Nenhuma atividade" : parts.joined(separator: ", ")
    }
}

// MARK: - Timestamped Protocol

extension TimelineEvent: Timestamped {}

// MARK: - Sample Data

extension TimelineEvent {
    
    /// Dados de exemplo para desenvolvimento e testes
    static let sampleEvents: [TimelineEvent] = [
        TimelineEvent(
            userId: UUID(),
            actionActivityCount: 5,
            tasksCompleted: 3,
            mentalStatusCount: 2,
            timelineEventCount: 10,
            userSince: Date().addingTimeInterval(-86400 * 30), // 30 dias atrás
            createdAt: Date()
        ),
        TimelineEvent(
            userId: UUID(),
            actionActivityCount: 2,
            tasksCompleted: 1,
            mentalStatusCount: 1,
            timelineEventCount: 4,
            userSince: Date().addingTimeInterval(-86400 * 7), // 7 dias atrás
            createdAt: Date().addingTimeInterval(-86400)
        )
    ]
}
