//
//  MentalState.swift
//  Minds Flow
//
//  Created by Kiro on 18/10/25.
//

import Foundation
import SwiftUI

/// Model to represent user's mental state
/// Records energy (1-10) and emotion at a specific moment
struct MentalState: Codable, Identifiable {
    
    // MARK: - Properties
    let id: UUID
    let userId: UUID
    var mood: Emotion               // Current emotion/mood
    var energy: Int                 // Energy level (1-10)
    var notes: String?              // Optional notes
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
        self.energy = min(max(energy, 1), 10) // Ensure between 1-10
        self.notes = notes
        self.createdAt = createdAt
    }
    
    // MARK: - Convenience Initializer (with EnergyLevel)
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
    
    /// Converts energy (int) to EnergyLevel (enum)
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
    
    /// Returns energy level description
    var energyDescription: String {
        return energyLevel.displayName
    }
    
    /// Returns color based on mental state
    var stateColor: Color {
        return mood.color
    }
    
    /// Checks if user needs support
    var needsSupport: Bool {
        let negativeEmotions: [Emotion] = [.anxious, .sad, .confused, .tired]
        return negativeEmotions.contains(mood) || energy <= 3
    }
    
    /// Returns recommendation based on state
    var recommendation: String {
        switch (energyLevel, mood) {
        case (.high, .motivated), (.high, .creative):
            return "Great time for challenging tasks!"
        case (.high, .anxious):
            return "Channel this energy into physical activities."
        case (.medium, .focused):
            return "Ideal state for medium complexity tasks."
        case (.low, .calm):
            return "Perfect for reflections and simple tasks."
        case (.low, .tired):
            return "How about resting or doing something comforting?"
        case (_, .sad), (_, .anxious):
            return "Time for self-care and activities that bring peace."
        default:
            return "Listen to your body and mind to choose the best activity."
        }
    }
    
    // MARK: - Conversion Methods
    
    /// Converts EnergyLevel to Int (1-10)
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
    
    /// Converts Int (1-10) to EnergyLevel
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
    
    /// Updates the mental state
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
    
    /// Validates the mental state data
    /// - Throws: ValidationError if data is invalid
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
    
    /// Returns representative emoji for state
    var stateEmoji: String {
        return "\(mood.emoji) \(energyLevel.emoji)"
    }
    
    /// Returns full description of state
    var fullDescription: String {
        var description = "\(mood.displayName) with \(energyDescription)"
        if let notes = notes, !notes.isEmpty {
            description += " - \(notes)"
        }
        return description
    }
}

// MARK: - Validation Error Extension

extension ValidationError {
    static let invalidEnergyValue = ValidationError.custom("Energy level must be between 1 and 10")
    static let notesTooLong = ValidationError.custom("Notes cannot be more than 500 characters")
}

// MARK: - Timestamped Protocol

extension MentalState: Timestamped {
    var updatedAt: Date {
        return createdAt // MentalState is immutable after creation
    }
}

// MARK: - Sample Data

extension MentalState {
    
    /// Sample data for development and testing
    static let sampleStates: [MentalState] = [
        MentalState(
            userId: UUID(),
            mood: .motivated,
            energy: 9,
            notes: "Woke up feeling great today!",
            createdAt: Date()
        ),
        MentalState(
            userId: UUID(),
            mood: .focused,
            energy: 7,
            notes: "Good focus for work",
            createdAt: Date().addingTimeInterval(-3600)
        ),
        MentalState(
            userId: UUID(),
            mood: .calm,
            energy: 4,
            notes: "Time to relax",
            createdAt: Date().addingTimeInterval(-7200)
        ),
        MentalState(
            userId: UUID(),
            mood: .tired,
            energy: 2,
            notes: "Need to rest",
            createdAt: Date().addingTimeInterval(-10800)
        )
    ]
    
    /// Sample state with high energy
    static let highEnergyState = MentalState(
        userId: UUID(),
        mood: .motivated,
        energyLevel: .high,
        notes: "Ready for big challenges!"
    )
    
    /// Sample state with low energy
    static let lowEnergyState = MentalState(
        userId: UUID(),
        mood: .tired,
        energyLevel: .low,
        notes: "Tiring day"
    )
}
