//
//  Wisdom.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import Foundation
import SwiftUI

/// Model to represent a wisdom/personal knowledge entry
/// Personal library of reflections, learnings, and insights
struct Wisdom: Codable, Identifiable {
    
    // MARK: - Properties
    let id: UUID
    var title: String?              // NEW: Optional title
    var content: String
    var category: WisdomCategory
    var emotionalTag: Emotion       // Renamed from emotion to emotionalTag
    var tags: [String]
    var createdAt: Date
    var updatedAt: Date
    let userId: UUID                // Changed from String to UUID
    
    // MARK: - Supabase Mapping
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case category
        case emotionalTag = "emotional_tag"
        case tags
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case userId = "user_id"
    }
    
    // MARK: - Custom Decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        category = try container.decode(WisdomCategory.self, forKey: .category)
        emotionalTag = try container.decode(Emotion.self, forKey: .emotionalTag)
        
        // Decode tags which may be absent in database
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        userId = try container.decode(UUID.self, forKey: .userId)
    }
    
    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        title: String? = nil,
        content: String,
        category: WisdomCategory,
        emotionalTag: Emotion,
        tags: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        userId: UUID
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.category = category
        self.emotionalTag = emotionalTag
        self.tags = tags
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.userId = userId
    }
    
    // MARK: - Convenience Initializer (backward compatibility)
    init(
        id: UUID = UUID(),
        title: String? = nil,
        content: String,
        category: WisdomCategory,
        emotion: Emotion,
        tags: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        userId: String
    ) {
        self.init(
            id: id,
            title: title,
            content: content,
            category: category,
            emotionalTag: emotion,
            tags: tags,
            createdAt: createdAt,
            updatedAt: updatedAt,
            userId: UUID(uuidString: userId) ?? UUID()
        )
    }
    
    // MARK: - Computed Property for backward compatibility
    var emotion: Emotion {
        return emotionalTag
    }
}

// MARK: - Wisdom Category Enum

/// Categories to organize different types of wisdom
enum WisdomCategory: String, CaseIterable, Codable {
    case reflection = "reflection"
    case learning = "learning"
    case insight = "insight"
    case quote = "quote"
    case experience = "experience"
    case goal = "goal"
    case gratitude = "gratitude"
    case personalGrowth = "Personal Growth"  // Compatibility with existing data
    
    /// Display name for category
    var displayName: String {
        switch self {
        case .reflection:
            return "Reflection"
        case .learning:
            return "Learning"
        case .insight:
            return "Insight"
        case .quote:
            return "Quote"
        case .experience:
            return "Experience"
        case .goal:
            return "Goal"
        case .gratitude:
            return "Gratitude"
        case .personalGrowth:
            return "Personal Growth"
        }
    }
    
    /// Representative emoji for category
    var emoji: String {
        switch self {
        case .reflection:
            return "🤔"
        case .learning:
            return "📚"
        case .insight:
            return "💡"
        case .quote:
            return "💬"
        case .experience:
            return "🌟"
        case .goal:
            return "🎯"
        case .gratitude:
            return "🙏"
        case .personalGrowth:
            return "🌱"
        }
    }
    
    /// SF Symbols icon for category
    var icon: String {
        switch self {
        case .reflection:
            return "brain.head.profile"
        case .learning:
            return "book.fill"
        case .insight:
            return "lightbulb.fill"
        case .quote:
            return "quote.bubble.fill"
        case .experience:
            return "star.fill"
        case .goal:
            return "target"
        case .gratitude:
            return "heart.fill"
        case .personalGrowth:
            return "chart.line.uptrend.xyaxis"
        }
    }
    
    /// Associated color for category
    var color: Color {
        switch self {
        case .reflection:
            return .blue
        case .learning:
            return .green
        case .insight:
            return .yellow
        case .quote:
            return .purple
        case .experience:
            return .orange
        case .goal:
            return .red
        case .gratitude:
            return .pink
        case .personalGrowth:
            return .teal
        }
    }
}

// MARK: - Emotion Enum

/// Emotional states to contextualize wisdom
enum Emotion: String, CaseIterable, Codable {
    case calm = "calm"
    case anxious = "anxious"
    case creative = "creative"
    case focused = "focused"
    case dispersed = "dispersed"
    case motivated = "motivated"
    case tired = "tired"
    case happy = "happy"
    case sad = "sad"
    case grateful = "grateful"
    case confused = "confused"
    case inspired = "inspired"
    
    // Custom init to accept capitalized values from database
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        // Try with original value
        if let emotion = Emotion(rawValue: rawValue) {
            self = emotion
        }
        // Try with lowercase
        else if let emotion = Emotion(rawValue: rawValue.lowercased()) {
            self = emotion
        }
        // If not found, throw error
        else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot initialize Emotion from invalid String value \(rawValue)"
            )
        }
    }
    
    /// Display name for emotion
    var displayName: String {
        switch self {
        case .calm:
            return "Calm"
        case .anxious:
            return "Anxious"
        case .creative:
            return "Creative"
        case .focused:
            return "Focused"
        case .dispersed:
            return "Dispersed"
        case .motivated:
            return "Motivated"
        case .tired:
            return "Tired"
        case .happy:
            return "Happy"
        case .sad:
            return "Sad"
        case .grateful:
            return "Grateful"
        case .confused:
            return "Confused"
        case .inspired:
            return "Inspired"
        }
    }
    
    /// Representative emoji for emotion
    var emoji: String {
        switch self {
        case .calm:
            return "😌"
        case .anxious:
            return "😰"
        case .creative:
            return "🎨"
        case .focused:
            return "🎯"
        case .dispersed:
            return "🌪️"
        case .motivated:
            return "💪"
        case .tired:
            return "😴"
        case .happy:
            return "😊"
        case .sad:
            return "😢"
        case .grateful:
            return "🙏"
        case .confused:
            return "😕"
        case .inspired:
            return "✨"
        }
    }
    
    /// Associated color for emotion
    var colorName: String {
        switch self {
        case .calm, .grateful:
            return "green"
        case .anxious, .sad, .confused:
            return "red"
        case .creative, .inspired:
            return "purple"
        case .focused, .motivated:
            return "blue"
        case .dispersed, .tired:
            return "gray"
        case .happy:
            return "yellow"
        }
    }
    
    /// SF Symbols icon for emotion
    var icon: String {
        switch self {
        case .calm:
            return "heart.circle"
        case .anxious:
            return "exclamationmark.heart"
        case .creative:
            return "paintbrush"
        case .focused:
            return "scope"
        case .dispersed:
            return "hurricane"
        case .motivated:
            return "flame"
        case .tired:
            return "zzz"
        case .happy:
            return "face.smiling"
        case .sad:
            return "cloud.rain"
        case .grateful:
            return "hands.sparkles"
        case .confused:
            return "questionmark.circle"
        case .inspired:
            return "sparkles"
        }
    }
    
    /// Cor para UI da emoção
    var color: Color {
        switch self {
        case .calm, .grateful:
            return .green
        case .anxious, .sad, .confused:
            return .red
        case .creative, .inspired:
            return .purple
        case .focused, .motivated:
            return .blue
        case .dispersed, .tired:
            return .gray
        case .happy:
            return .yellow
        }
    }
}

// MARK: - Wisdom Extensions

extension Wisdom {
    
    /// Updates the wisdom content
    mutating func update(
        title: String? = nil,
        content: String? = nil,
        category: WisdomCategory? = nil,
        emotion: Emotion? = nil,
        tags: [String]? = nil
    ) {
        if let title = title { self.title = title }
        if let content = content { self.content = content }
        if let category = category { self.category = category }
        if let emotion = emotion { self.emotionalTag = emotion }
        if let tags = tags { self.tags = tags }
        self.updatedAt = Date()
    }
    
    /// Validates the wisdom data
    /// - Throws: WisdomValidationError if data is invalid
    func validate() throws {
        guard !content.isEmpty else {
            throw WisdomValidationError.emptyContent
        }
        
        guard content.count >= 10 else {
            throw WisdomValidationError.contentTooShort
        }
        
        guard content.count <= 5000 else {
            throw WisdomValidationError.contentTooLong
        }
        
        if let title = title {
            guard !title.isEmpty else {
                throw WisdomValidationError.emptyTitle
            }
            
            guard title.count <= 100 else {
                throw WisdomValidationError.titleTooLong
            }
        }
    }
    
    /// Adds a new tag
    mutating func addTag(_ tag: String) {
        let cleanTag = tag.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !cleanTag.isEmpty && !tags.contains(cleanTag) {
            tags.append(cleanTag)
            updatedAt = Date()
        }
    }
    
    /// Removes a tag
    mutating func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
        updatedAt = Date()
    }
    
    /// Checks if the wisdom contains a keyword
    func contains(keyword: String) -> Bool {
        let searchText = keyword.lowercased()
        return content.lowercased().contains(searchText) ||
               tags.contains { $0.contains(searchText) }
    }
    
    /// Checks if the wisdom is appropriate for the current emotional state
    func isAppropriateFor(currentEmotion: Emotion) -> Bool {
        // Logic to suggest wisdom based on emotional state
        switch currentEmotion {
        case .anxious, .sad, .confused:
            return emotion == .calm || emotion == .grateful || category == .gratitude
        case .tired:
            return emotion == .motivated || emotion == .inspired
        case .dispersed:
            return emotion == .focused || category == .goal
        default:
            return true
        }
    }
}

// MARK: - Validation Error for Wisdom

enum WisdomValidationError: LocalizedError {
    case emptyContent
    case contentTooShort
    case contentTooLong
    case emptyTitle
    case titleTooLong
    
    var errorDescription: String? {
        switch self {
        case .emptyContent:
            return "Content cannot be empty"
        case .contentTooShort:
            return "Content must be at least 10 characters"
        case .contentTooLong:
            return "Content cannot be more than 5000 characters"
        case .emptyTitle:
            return "Title cannot be empty"
        case .titleTooLong:
            return "Title cannot be more than 100 characters"
        }
    }
}

// MARK: - Timestamped Protocol

extension Wisdom: Timestamped {}

// MARK: - Sample Data

extension Wisdom {
    
    /// Sample data for development and testing
    static let sampleWisdom: [Wisdom] = [
        Wisdom(
            title: "Reaction vs Event",
            content: "Life is 10% what happens to me and 90% how I react to what happens.",
            category: .quote,
            emotionalTag: .inspired,
            tags: ["life", "attitude", "reaction"],
            userId: UUID()
        ),
        Wisdom(
            title: "Small Steps",
            content: "Today I learned that consistent small steps lead to great transformations. I don't need to do everything at once.",
            category: .learning,
            emotionalTag: .calm,
            tags: ["progress", "consistency", "patience"],
            userId: UUID()
        ),
        Wisdom(
            content: "I'm grateful for having health, family, and the opportunity to grow each day.",
            category: .gratitude,
            emotionalTag: .grateful,
            tags: ["gratitude", "health", "family"],
            userId: UUID()
        ),
        Wisdom(
            title: "Breathing Technique",
            content: "I noticed that when I'm anxious, breathing deeply for 5 minutes helps me regain focus.",
            category: .insight,
            emotionalTag: .focused,
            tags: ["anxiety", "breathing", "focus"],
            userId: UUID()
        )
    ]
}