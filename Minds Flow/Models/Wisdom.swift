//
//  Wisdom.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import Foundation
import SwiftUI

/// Modelo para representar uma entrada de sabedoria/conhecimento pessoal
/// Biblioteca pessoal de reflexões, aprendizados e insights
struct Wisdom: Codable, Identifiable {
    
    // MARK: - Properties
    let id: UUID
    var title: String?              // NOVO: Título opcional
    var content: String
    var category: WisdomCategory
    var emotionalTag: Emotion       // Renomeado de emotion para emotionalTag
    var tags: [String]
    var createdAt: Date
    var updatedAt: Date
    let userId: UUID                // Mudado de String para UUID
    
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
        
        // Decodificar tags que pode estar ausente no banco
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

/// Categorias para organizar diferentes tipos de sabedoria
enum WisdomCategory: String, CaseIterable, Codable {
    case reflection = "reflection"
    case learning = "learning"
    case insight = "insight"
    case quote = "quote"
    case experience = "experience"
    case goal = "goal"
    case gratitude = "gratitude"
    case personalGrowth = "Personal Growth"  // Compatibilidade com dados existentes
    
    /// Nome para exibição da categoria
    var displayName: String {
        switch self {
        case .reflection:
            return "Reflexão"
        case .learning:
            return "Aprendizado"
        case .insight:
            return "Insight"
        case .quote:
            return "Citação"
        case .experience:
            return "Experiência"
        case .goal:
            return "Meta"
        case .gratitude:
            return "Gratidão"
        case .personalGrowth:
            return "Crescimento Pessoal"
        }
    }
    
    /// Emoji representativo da categoria
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
    
    /// Ícone SF Symbols da categoria
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
    
    /// Cor associada à categoria
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

/// Estados emocionais para contextualizar a sabedoria
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
    
    // Init customizado para aceitar valores capitalizados do banco
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        // Tentar com o valor original
        if let emotion = Emotion(rawValue: rawValue) {
            self = emotion
        }
        // Tentar com lowercase
        else if let emotion = Emotion(rawValue: rawValue.lowercased()) {
            self = emotion
        }
        // Se não encontrar, lançar erro
        else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot initialize Emotion from invalid String value \(rawValue)"
            )
        }
    }
    
    /// Nome para exibição da emoção
    var displayName: String {
        switch self {
        case .calm:
            return "Calmo"
        case .anxious:
            return "Ansioso"
        case .creative:
            return "Criativo"
        case .focused:
            return "Focado"
        case .dispersed:
            return "Disperso"
        case .motivated:
            return "Motivado"
        case .tired:
            return "Cansado"
        case .happy:
            return "Feliz"
        case .sad:
            return "Triste"
        case .grateful:
            return "Grato"
        case .confused:
            return "Confuso"
        case .inspired:
            return "Inspirado"
        }
    }
    
    /// Emoji representativo da emoção
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
    
    /// Cor associada à emoção
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
    
    /// Ícone do SF Symbols para a emoção
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
    
    /// Atualiza o conteúdo da sabedoria
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
    
    /// Valida os dados da wisdom
    /// - Throws: WisdomValidationError se os dados forem inválidos
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
    
    /// Adiciona uma nova tag
    mutating func addTag(_ tag: String) {
        let cleanTag = tag.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !cleanTag.isEmpty && !tags.contains(cleanTag) {
            tags.append(cleanTag)
            updatedAt = Date()
        }
    }
    
    /// Remove uma tag
    mutating func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
        updatedAt = Date()
    }
    
    /// Verifica se a sabedoria contém uma palavra-chave
    func contains(keyword: String) -> Bool {
        let searchText = keyword.lowercased()
        return content.lowercased().contains(searchText) ||
               tags.contains { $0.contains(searchText) }
    }
    
    /// Verifica se a sabedoria é adequada para o estado emocional atual
    func isAppropriateFor(currentEmotion: Emotion) -> Bool {
        // Lógica para sugerir sabedoria baseada no estado emocional
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
            return "O conteúdo não pode estar vazio"
        case .contentTooShort:
            return "O conteúdo deve ter pelo menos 10 caracteres"
        case .contentTooLong:
            return "O conteúdo não pode ter mais de 5000 caracteres"
        case .emptyTitle:
            return "O título não pode estar vazio"
        case .titleTooLong:
            return "O título não pode ter mais de 100 caracteres"
        }
    }
}

// MARK: - Timestamped Protocol

extension Wisdom: Timestamped {}

// MARK: - Sample Data

extension Wisdom {
    
    /// Dados de exemplo para desenvolvimento e testes
    static let sampleWisdom: [Wisdom] = [
        Wisdom(
            title: "Reação vs Acontecimento",
            content: "A vida é 10% do que acontece comigo e 90% de como eu reajo ao que acontece.",
            category: .quote,
            emotionalTag: .inspired,
            tags: ["vida", "atitude", "reação"],
            userId: UUID()
        ),
        Wisdom(
            title: "Pequenos Passos",
            content: "Hoje aprendi que pequenos passos consistentes levam a grandes transformações. Não preciso fazer tudo de uma vez.",
            category: .learning,
            emotionalTag: .calm,
            tags: ["progresso", "consistência", "paciência"],
            userId: UUID()
        ),
        Wisdom(
            content: "Sou grato por ter saúde, família e a oportunidade de crescer a cada dia.",
            category: .gratitude,
            emotionalTag: .grateful,
            tags: ["gratidão", "saúde", "família"],
            userId: UUID()
        ),
        Wisdom(
            title: "Técnica de Respiração",
            content: "Percebi que quando estou ansioso, respirar profundamente por 5 minutos me ajuda a recuperar o foco.",
            category: .insight,
            emotionalTag: .focused,
            tags: ["ansiedade", "respiração", "foco"],
            userId: UUID()
        )
    ]
}