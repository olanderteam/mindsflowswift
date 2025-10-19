//
//  UserProfile.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import Foundation

/// Modelo para representar o perfil do usuário no sistema
/// Contém informações pessoais e preferências do usuário
struct UserProfile: Codable, Identifiable {
    
    // MARK: - Properties
    let id: UUID                    // ID do perfil (mesmo que auth.users.id)
    var name: String
    var avatarUrl: String?          // NOVO: URL do avatar
    var theme: AppTheme
    var language: String?           // NOVO: Idioma preferido
    var createdAt: Date
    var updatedAt: Date
    
    // REMOVIDO: email (vem de auth.users)
    // REMOVIDO: currentEnergyLevel (agora em MentalState)
    // REMOVIDO: currentEmotion (agora em MentalState)
    // REMOVIDO: isCollapseMode (preferência local do app)
    // REMOVIDO: userId (id já é o userId)
    
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

/// Temas disponíveis para o aplicativo
enum AppTheme: String, CaseIterable, Codable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    /// Nome para exibição do tema
    var displayName: String {
        switch self {
        case .light:
            return "Claro"
        case .dark:
            return "Escuro"
        case .system:
            return "Sistema"
        }
    }
    
    /// Ícone representativo do tema
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
    
    /// Atualiza o perfil do usuário
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
    
    /// Valida os dados do perfil
    /// - Throws: ValidationError se os dados forem inválidos
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
    
    /// Retorna as iniciais do nome para avatar
    var initials: String {
        let components = name.components(separatedBy: " ")
        let initials = components.prefix(2).compactMap { $0.first }.map { String($0) }
        return initials.joined().uppercased()
    }
}

// MARK: - Validation Error Extension

extension ValidationError {
    static let emptyName = ValidationError.custom("O nome não pode estar vazio")
    static let nameTooShort = ValidationError.custom("O nome deve ter pelo menos 2 caracteres")
    static let nameTooLong = ValidationError.custom("O nome não pode ter mais de 100 caracteres")
    static let invalidAvatarUrl = ValidationError.custom("URL do avatar inválida")
    static let unsupportedLanguage = ValidationError.custom("Idioma não suportado")
}

// MARK: - Timestamped Protocol

extension UserProfile: Timestamped {}

// MARK: - Sample Data

extension UserProfile {
    
    /// Dados de exemplo para desenvolvimento e testes
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