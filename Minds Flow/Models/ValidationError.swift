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
            return "Title cannot be empty"
        case .titleTooLong:
            return "Title cannot be longer than 200 characters"
        case .invalidTimeEstimate:
            return "Time estimate must be between 1 and 1440 minutes (24 hours)"
        case .invalidDueDate:
            return "Due date cannot be too old"
        }
    }
}
