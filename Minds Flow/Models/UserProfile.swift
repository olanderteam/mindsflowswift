//
//  UserProfile.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import Foundation

/// Model to represent user profile in the system
/// Contains personal information and user preferences
struct UserProfile: Codable, Identifiable {
    
    // MARK: - Properties
    let id: UUID                    // Profile ID (same as auth.users.id)
    var name: String
    var avatarUrl: String?          // NEW: Avatar URL
    var theme: AppTheme
    var language: String?           // NEW: Preferred language
    var createdAt: Date
    var updatedAt: Date
    
    // REMOVED: email (comes from auth.users)
    // REMOVED: currentEnergyLevel (now in MentalState)
    // REMOVED: currentEmotion (now in MentalState)
    // REMOVED: isCollapseMode (local app preference)
    // REMOVED: userId (id is already the userId)
    
    // MARK: - Supabase Mapping
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case avatarUrl = "avatar_url"
        case theme
        case language
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        name: String,
        avatarUrl: String? = nil,
        theme: AppTheme = .system,
        language: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.avatarUrl = avatarUrl
        self.theme = theme
        self.language = language
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - App Theme Enum

/// Available themes for the application
enum AppTheme: String, CaseIterable, Codable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    /// Display name for theme
    var displayName: String {
        switch self {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        case .system:
            return "System"
        }
    }
    
    /// Representative icon for theme
    var iconName: String {
        switch self {
        case .light:
            return "sun.max"
        case .dark:
            return "moon"
        case .system:
            return "gear"
        }
    }
}

// MARK: - Mental State (moved to separate file - will be updated in Task 8)

// MARK: - UserProfile Extensions

extension UserProfile {
    
    /// Updates the user profile
    mutating func update(
        name: String? = nil,
        avatarUrl: String? = nil,
        theme: AppTheme? = nil,
        language: String? = nil
    ) {
        if let name = name { self.name = name }
        if let avatarUrl = avatarUrl { self.avatarUrl = avatarUrl }
        if let theme = theme { self.theme = theme }
        if let language = language { self.language = language }
        self.updatedAt = Date()
    }
    
    /// Validates the profile data
    /// - Throws: ValidationError if data is invalid
    func validate() throws {
        guard !name.isEmpty else {
            throw ValidationError.emptyName
        }
        
        guard name.count >= 2 else {
            throw ValidationError.nameTooShort
        }
        
        guard name.count <= 100 else {
            throw ValidationError.nameTooLong
        }
        
        if let url = avatarUrl {
            guard URL(string: url) != nil else {
                throw ValidationError.invalidAvatarUrl
            }
        }
        
        if let lang = language {
            guard ["pt", "en", "es", "fr", "de"].contains(lang) else {
                throw ValidationError.unsupportedLanguage
            }
        }
    }
    
    /// Returns the name initials for avatar
    var initials: String {
        let components = name.components(separatedBy: " ")
        let initials = components.prefix(2).compactMap { $0.first }.map { String($0) }
        return initials.joined().uppercased()
    }
}

// MARK: - Validation Error Extension

extension ValidationError {
    static let emptyName = ValidationError.custom("Name cannot be empty")
    static let nameTooShort = ValidationError.custom("Name must be at least 2 characters")
    static let nameTooLong = ValidationError.custom("Name cannot be more than 100 characters")
    static let invalidAvatarUrl = ValidationError.custom("Invalid avatar URL")
    static let unsupportedLanguage = ValidationError.custom("Unsupported language")
}

// MARK: - Timestamped Protocol

extension UserProfile: Timestamped {}

// MARK: - Sample Data

extension UserProfile {
    
    /// Sample data for development and testing
    static let sampleProfile = UserProfile(
        id: UUID(),
        name: "Gabriel Santos",
        avatarUrl: nil,
        theme: .system,
        language: "pt"
    )
    
    static let sampleProfileWithAvatar = UserProfile(
        id: UUID(),
        name: "Maria Silva",
        avatarUrl: "https://example.com/avatar.jpg",
        theme: .dark,
        language: "en"
    )
}