//
//  ErrorHandler.swift
//  Minds Flow
//
//  Created by Kiro on 03/12/25.
//

import Foundation
import SwiftUI

/// Comprehensive error handling system with user-friendly messages
enum AppError: LocalizedError, Identifiable {
    var id: String { errorDescription ?? "unknown_error" }
    
    // MARK: - Network Errors
    case networkUnavailable
    case connectionTimeout
    case serverUnreachable
    case slowConnection
    
    // MARK: - Authentication Errors
    case authenticationFailed
    case invalidCredentials
    case emailAlreadyExists
    case weakPassword
    case sessionExpired
    case userNotFound
    case emailNotVerified
    
    // MARK: - Data Errors
    case dataCorrupted
    case syncFailed
    case cacheFailed
    case invalidData
    case notFound
    case duplicateEntry
    
    // MARK: - Validation Errors
    case emptyField(String)
    case invalidEmail
    case invalidFormat(String)
    case valueTooShort(String, Int)
    case valueTooLong(String, Int)
    
    // MARK: - Permission Errors
    case permissionDenied
    case unauthorized
    case forbidden
    
    // MARK: - Generic Errors
    case unknown(Error)
    case custom(String, String?)
    
    // MARK: - Error Description
    var errorDescription: String? {
        switch self {
        // Network
        case .networkUnavailable:
            return "No Internet Connection"
        case .connectionTimeout:
            return "Connection Timeout"
        case .serverUnreachable:
            return "Server Unreachable"
        case .slowConnection:
            return "Slow Connection"
            
        // Authentication
        case .authenticationFailed:
            return "Authentication Failed"
        case .invalidCredentials:
            return "Invalid Credentials"
        case .emailAlreadyExists:
            return "Email Already Registered"
        case .weakPassword:
            return "Weak Password"
        case .sessionExpired:
            return "Session Expired"
        case .userNotFound:
            return "User Not Found"
        case .emailNotVerified:
            return "Email Not Verified"
            
        // Data
        case .dataCorrupted:
            return "Data Corrupted"
        case .syncFailed:
            return "Sync Failed"
        case .cacheFailed:
            return "Cache Error"
        case .invalidData:
            return "Invalid Data"
        case .notFound:
            return "Not Found"
        case .duplicateEntry:
            return "Duplicate Entry"
            
        // Validation
        case .emptyField(let field):
            return "\(field) is Required"
        case .invalidEmail:
            return "Invalid Email"
        case .invalidFormat(let field):
            return "Invalid \(field) Format"
        case .valueTooShort(let field, let min):
            return "\(field) Too Short (min: \(min))"
        case .valueTooLong(let field, let max):
            return "\(field) Too Long (max: \(max))"
            
        // Permission
        case .permissionDenied:
            return "Permission Denied"
        case .unauthorized:
            return "Unauthorized"
        case .forbidden:
            return "Access Forbidden"
            
        // Generic
        case .unknown(let error):
            return "Error: \(error.localizedDescription)"
        case .custom(let title, _):
            return title
        }
    }
    
    // MARK: - Detailed Message
    var detailedMessage: String {
        switch self {
        // Network
        case .networkUnavailable:
            return "Please check your internet connection and try again."
        case .connectionTimeout:
            return "The request took too long. Please try again."
        case .serverUnreachable:
            return "Unable to reach the server. Please try again later."
        case .slowConnection:
            return "Your connection is slow. Some features may be limited."
            
        // Authentication
        case .authenticationFailed:
            return "Unable to sign in. Please check your credentials."
        case .invalidCredentials:
            return "The email or password you entered is incorrect."
        case .emailAlreadyExists:
            return "This email is already registered. Try signing in instead."
        case .weakPassword:
            return "Password must be at least 8 characters with letters and numbers."
        case .sessionExpired:
            return "Your session has expired. Please sign in again."
        case .userNotFound:
            return "No account found with this email."
        case .emailNotVerified:
            return "Please verify your email before signing in."
            
        // Data
        case .dataCorrupted:
            return "Data sync issue detected. Your data may be out of sync."
        case .syncFailed:
            return "Failed to sync your data. Changes will sync when online."
        case .cacheFailed:
            return "Unable to cache data locally."
        case .invalidData:
            return "The data format is invalid or corrupted."
        case .notFound:
            return "The requested item could not be found."
        case .duplicateEntry:
            return "This entry already exists."
            
        // Validation
        case .emptyField(let field):
            return "Please enter a \(field.lowercased())."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .invalidFormat(let field):
            return "The \(field.lowercased()) format is invalid."
        case .valueTooShort(let field, let min):
            return "\(field) must be at least \(min) characters."
        case .valueTooLong(let field, let max):
            return "\(field) must be no more than \(max) characters."
            
        // Permission
        case .permissionDenied:
            return "You don't have permission to perform this action."
        case .unauthorized:
            return "Please sign in to continue."
        case .forbidden:
            return "You don't have access to this resource."
            
        // Generic
        case .unknown(let error):
            return error.localizedDescription
        case .custom(_, let message):
            return message ?? "An error occurred."
        }
    }
    
    // MARK: - Recovery Suggestion
    var recoverySuggestion: String? {
        switch self {
        // Network
        case .networkUnavailable:
            return "Connect to Wi-Fi or cellular data"
        case .connectionTimeout:
            return "Check your connection and retry"
        case .serverUnreachable:
            return "Wait a moment and try again"
        case .slowConnection:
            return "Move to a better network area"
            
        // Authentication
        case .authenticationFailed, .invalidCredentials:
            return "Reset password or try again"
        case .emailAlreadyExists:
            return "Sign in with existing account"
        case .weakPassword:
            return "Use a stronger password"
        case .sessionExpired:
            return "Sign in again to continue"
        case .userNotFound:
            return "Create a new account"
        case .emailNotVerified:
            return "Check your email for verification link"
            
        // Data
        case .dataCorrupted:
            return "Clear cache or reinstall app"
        case .syncFailed:
            return "Changes will sync automatically when online"
        case .cacheFailed:
            return "Restart the app"
        case .invalidData:
            return "Contact support if issue persists"
        case .notFound:
            return "Refresh and try again"
        case .duplicateEntry:
            return "Use a different value"
            
        // Validation
        case .emptyField, .invalidEmail, .invalidFormat, .valueTooShort, .valueTooLong:
            return "Correct the input and try again"
            
        // Permission
        case .permissionDenied, .unauthorized, .forbidden:
            return "Contact support for access"
            
        // Generic
        case .unknown, .custom:
            return "Try again or contact support"
        }
    }
    
    // MARK: - Icon
    var icon: String {
        switch self {
        case .networkUnavailable, .connectionTimeout, .serverUnreachable, .slowConnection:
            return "wifi.slash"
        case .authenticationFailed, .invalidCredentials, .sessionExpired, .userNotFound:
            return "person.crop.circle.badge.xmark"
        case .emailAlreadyExists, .duplicateEntry:
            return "exclamationmark.triangle"
        case .weakPassword:
            return "lock.slash"
        case .emailNotVerified:
            return "envelope.badge"
        case .dataCorrupted, .syncFailed, .cacheFailed, .invalidData:
            return "exclamationmark.icloud"
        case .notFound:
            return "magnifyingglass"
        case .emptyField, .invalidEmail, .invalidFormat, .valueTooShort, .valueTooLong:
            return "exclamationmark.circle"
        case .permissionDenied, .unauthorized, .forbidden:
            return "hand.raised"
        case .unknown, .custom:
            return "exclamationmark.triangle"
        }
    }
    
    // MARK: - Color
    var color: Color {
        switch self {
        case .networkUnavailable, .connectionTimeout, .serverUnreachable, .slowConnection:
            return .orange
        case .authenticationFailed, .invalidCredentials, .sessionExpired, .permissionDenied, .unauthorized, .forbidden:
            return .red
        case .emailAlreadyExists, .weakPassword, .duplicateEntry:
            return .yellow
        case .dataCorrupted, .syncFailed:
            return .orange
        case .emptyField, .invalidEmail, .invalidFormat, .valueTooShort, .valueTooLong:
            return .blue
        default:
            return .red
        }
    }
}

// MARK: - Error Handler Service
@MainActor
class ErrorHandler: ObservableObject {
    static let shared = ErrorHandler()
    
    @Published var currentError: AppError?
    @Published var showError = false
    
    private init() {}
    
    /// Handle and display error
    func handle(_ error: Error, context: String? = nil) {
        let appError = mapError(error, context: context)
        currentError = appError
        showError = true
        
        // Log error for debugging
        logError(appError, context: context)
    }
    
    /// Handle and display app error
    func handle(_ error: AppError) {
        currentError = error
        showError = true
        logError(error, context: nil)
    }
    
    /// Map generic error to AppError
    private func mapError(_ error: Error, context: String?) -> AppError {
        let errorString = error.localizedDescription.lowercased()
        
        // Network errors
        if errorString.contains("network") || errorString.contains("internet") {
            return .networkUnavailable
        }
        if errorString.contains("timeout") {
            return .connectionTimeout
        }
        if errorString.contains("unreachable") || errorString.contains("cannot connect") {
            return .serverUnreachable
        }
        
        // Auth errors
        if errorString.contains("invalid credentials") || errorString.contains("wrong password") {
            return .invalidCredentials
        }
        if errorString.contains("email already") || errorString.contains("already registered") {
            return .emailAlreadyExists
        }
        if errorString.contains("weak password") || errorString.contains("password too short") {
            return .weakPassword
        }
        if errorString.contains("session expired") || errorString.contains("token expired") {
            return .sessionExpired
        }
        if errorString.contains("user not found") {
            return .userNotFound
        }
        
        // Data errors
        if errorString.contains("not found") {
            return .notFound
        }
        if errorString.contains("duplicate") {
            return .duplicateEntry
        }
        
        // Permission errors
        if errorString.contains("permission") || errorString.contains("unauthorized") {
            return .permissionDenied
        }
        
        return .unknown(error)
    }
    
    /// Log error for debugging
    private func logError(_ error: AppError, context: String?) {
        #if DEBUG
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("❌ ERROR OCCURRED")
        if let context = context {
            print("📍 Context: \(context)")
        }
        print("🔴 Error: \(error.errorDescription ?? "Unknown")")
        print("📝 Details: \(error.detailedMessage)")
        if let suggestion = error.recoverySuggestion {
            print("💡 Suggestion: \(suggestion)")
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        #endif
    }
    
    /// Clear current error
    func clearError() {
        currentError = nil
        showError = false
    }
}

// MARK: - Error Alert Modifier
struct ErrorAlertModifier: ViewModifier {
    @ObservedObject var errorHandler = ErrorHandler.shared
    
    func body(content: Content) -> some View {
        content
            .alert(
                errorHandler.currentError?.errorDescription ?? "Error",
                isPresented: $errorHandler.showError,
                presenting: errorHandler.currentError
            ) { error in
                Button("OK") {
                    errorHandler.clearError()
                }
            } message: { error in
                VStack(alignment: .leading, spacing: 8) {
                    Text(error.detailedMessage)
                    
                    if let suggestion = error.recoverySuggestion {
                        Text("\n💡 \(suggestion)")
                            .font(.caption)
                    }
                }
            }
    }
}

extension View {
    func errorAlert() -> some View {
        modifier(ErrorAlertModifier())
    }
}
