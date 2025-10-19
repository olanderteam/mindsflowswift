//
//  ValidationError.swift
//  Minds Flow
//
//  Created by Kiro on 18/10/25.
//

import Foundation

/// Erros de validação para modelos
enum ValidationError: LocalizedError {
    case custom(String)
    case emptyTitle
    case titleTooLong
    case invalidTimeEstimate
    case invalidDueDate
    
    var errorDescription: String? {
        switch self {
        case .custom(let message):
            return message
        case .emptyTitle:
            return "O título não pode estar vazio"
        case .titleTooLong:
            return "O título não pode ter mais de 200 caracteres"
        case .invalidTimeEstimate:
            return "A estimativa de tempo deve estar entre 1 e 1440 minutos (24 horas)"
        case .invalidDueDate:
            return "A data de vencimento não pode ser muito antiga"
        }
    }
}
