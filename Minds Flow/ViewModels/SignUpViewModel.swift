//
//  SignUpViewModel.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import Foundation
import SwiftUI

/// ViewModel to manage signup logic
/// Implements validations and communication with authentication system
@MainActor
class SignUpViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var showSuccess = false
    @Published var errorMessage = ""
    
    // MARK: - Dependencies
    private let authManager = AuthManager.shared
    
    // MARK: - Computed Properties
    
    /// Checks if as senhas coincidem
    var passwordsMatch: Bool {
        return !password.isEmpty && !confirmPassword.isEmpty && password == confirmPassword
    }
    
    /// Checks if o formulário é válido
    var isFormValid: Bool {
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               isValidEmail(email) &&
               password.count >= 6 &&
               passwordsMatch
    }
    
    // MARK: - Authentication Methods
    
    /// Realiza o cadastro do usuário
    func signUp() async {
        guard isFormValid else {
            errorMessage = "Por favor, preencha todos os campos corretamente."
            showError = true
            return
        }
        
        isLoading = true
        
        do {
            let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            try await authManager.signUp(
                email: email.lowercased(),
                password: password,
                name: trimmedName
            )
            
            isLoading = false
            showSuccess = true
            clearForm()
            
        } catch {
            isLoading = false
            handleSignUpError(error)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Valida se o email tem formato correto
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    /// Exibe mensagem de erro
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    /// Trata erros de cadastro
    private func handleSignUpError(_ error: Error) {
        // Mostrar mensagem de erro genérica
        errorMessage = "Erro no cadastro: \(error.localizedDescription)"
        showError = true
    }
    
    /// Limpa os campos do formulário
    private func clearForm() {
        name = ""
        email = ""
        password = ""
        confirmPassword = ""
        errorMessage = ""
        showError = false
    }
    
    /// Valida a força da senha
    func getPasswordStrength() -> PasswordStrength {
        let password = self.password
        
        if password.isEmpty {
            return .none
        } else if password.count < 6 {
            return .weak
        } else if password.count >= 6 && password.count < 8 {
            return .medium
        } else if password.count >= 8 && containsSpecialCharacters(password) {
            return .strong
        } else {
            return .medium
        }
    }
    
    /// Checks if a senha contém caracteres especiais
    private func containsSpecialCharacters(_ password: String) -> Bool {
        let hasUppercase = password.rangeOfCharacter(from: .uppercaseLetters) != nil
        let hasLowercase = password.rangeOfCharacter(from: .lowercaseLetters) != nil
        let hasNumbers = password.rangeOfCharacter(from: .decimalDigits) != nil
        let hasSpecialChars = password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")) != nil
        
        return hasUppercase && hasLowercase && hasNumbers && hasSpecialChars
    }
}

// MARK: - Password Strength Enum

enum PasswordStrength {
    case none
    case weak
    case medium
    case strong
    
    var description: String {
        switch self {
        case .none:
            return ""
        case .weak:
            return "Fraca"
        case .medium:
            return "Média"
        case .strong:
            return "Forte"
        }
    }
    
    var color: Color {
        switch self {
        case .none:
            return .clear
        case .weak:
            return .red
        case .medium:
            return .orange
        case .strong:
            return .green
        }
    }
}

// MARK: - Extensions

extension SignUpViewModel {
    
    /// Dados de exemplo para desenvolvimento
    func fillWithSampleData() {
        name = "João Silva"
        email = "joao@exemplo.com"
        password = "123456"
        confirmPassword = "123456"
    }
}