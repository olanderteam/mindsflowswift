//
//  Task.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import Foundation
import SwiftUI

/// Model to represent a task in the Minds Flow system
/// Each task has meaning and is connected to the user's energy level
struct Task: Codable, Identifiable {
    
    // MARK: - Properties
    let id: UUID
    var title: String
    var description: String?        // Optional - can be NULL in database
    var energyLevel: EnergyLevel
    var purpose: String?            // Optional - can be NULL in database
    var isCompleted: Bool
    var dueDate: Date?              // NEW: Due date
    var timeEstimate: Int?          // NEW: Time estimate in minutes
    var createdAt: Date
    var updatedAt: Date
    var completedAt: Date?
    let userId: UUID                // Changed from String to UUID
    
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
        
        // Decode time_estimate which can come as String or Int
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

/// Energy levels to categorize tasks
enum EnergyLevel: String, CaseIterable, Codable {
    case high = "high"
    case medium = "medium"
    case low = "low"
    
    /// Readable description of energy level
    var displayName: String {
        switch self {
        case .high:
            return "High Energy"
        case .medium:
            return "Medium Energy"
        case .low:
            return "Low Energy"
        }
    }
    
    /// Representative emoji for energy level
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
    
    /// Associated color for energy level
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
    
    /// SF Symbols icon for energy level
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
    
    /// UI color for energy level
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
    
    /// Marks the task as completed
    mutating func markAsCompleted() {
        self.isCompleted = true
        self.completedAt = Date()
        self.updatedAt = Date()
    }
    
    /// Marks the task as incomplete
    mutating func markAsIncomplete() {
        self.isCompleted = false
        self.completedAt = nil
        self.updatedAt = Date()
    }
    
    /// Updates the task data
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
    
    /// Validates the task data
    /// - Throws: ValidationError if data is invalid
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
            // Allow dates up to 1 day in the past (for overdue tasks)
            throw ValidationError.invalidDueDate
        }
    }
    
    /// Checks if the task is overdue
    var isOverdue: Bool {
        guard let due = dueDate, !isCompleted else { return false }
        return due < Date()
    }
    
    /// Returns the formatted time estimate
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
    
    /// Returns the formatted due date
    var formattedDueDate: String? {
        guard let due = dueDate else { return nil }
        
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(due) {
            return "Today"
        } else if calendar.isDateInTomorrow(due) {
            return "Tomorrow"
        } else if calendar.isDateInYesterday(due) {
            return "Yesterday"
        } else {
            formatter.dateStyle = .short
            return formatter.string(from: due)
        }
    }
    
    /// Checks if the task is appropriate for the current energy level
    func isAppropriateFor(currentEnergyLevel: EnergyLevel) -> Bool {
        switch currentEnergyLevel {
        case .high:
            return true // Can do any task
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
    
    /// Sample data for development and testing
    static let sampleTasks: [Task] = [
        Task(
            title: "Review important project",
            description: "Analyze documentation and prepare presentation",
            energyLevel: .high,
            purpose: "Professional growth and work impact",
            dueDate: Date().addingTimeInterval(86400 * 2), // 2 days
            timeEstimate: 120, // 2 hours
            userId: UUID()
        ),
        Task(
            title: "Organize work desk",
            description: "Clean and organize workspace",
            energyLevel: .medium,
            purpose: "Create more productive environment",
            dueDate: Date().addingTimeInterval(86400), // 1 day
            timeEstimate: 30, // 30 minutes
            userId: UUID()
        ),
        Task(
            title: "Meditate for 10 minutes",
            description: "Mindfulness practice for relaxation",
            energyLevel: .low,
            purpose: "Mental well-being and stress reduction",
            timeEstimate: 10, // 10 minutes
            userId: UUID()
        )
    ]
}