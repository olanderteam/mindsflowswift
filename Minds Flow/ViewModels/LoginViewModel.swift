//
//  LoginViewModel.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import Foundation
import SwiftUI

/// ViewModel para gerenciar a lógica de login
/// Implementa o padrão MVVM para separar lógica de negócio da UI
@MainActor
class LoginViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    // MARK: - Dependencies
    private let authManager = AuthManager.shared
    
    // MARK: - Computed Properties
    
    /// Verifica se o formulário é válido
    var isFormValid: Bool {
        return isValidEmail(email) && password.count >= 6
    }
    
    // MARK: - Authentication Methods
    
    /// Realiza o login do usuário
    func login() async {
        guard isFormValid else {
            errorMessage = "Por favor, preencha todos os campos corretamente."
            showError = true
            return
        }
        
        isLoading = true
        
        do {
            try await authManager.signIn(email: email, password: password)
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            showError = true
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
    
    /// Trata erros de autenticação
    private func handleAuthError(_ error: Error) {
        let message: String
        
        // Aqui você pode personalizar as mensagens baseadas no tipo de erro do Supabase
        if error.localizedDescription.contains("Invalid login credentials") {
            message = "Email ou senha incorretos."
        } else if error.localizedDescription.contains("Email not confirmed") {
            message = "Por favor, confirme seu email antes de fazer login."
        } else if error.localizedDescription.contains("Too many requests") {
            message = "Muitas tentativas. Tente novamente em alguns minutos."
        } else if error.localizedDescription.contains("Network") {
            message = "Erro de conexão. Verifique sua internet."
        } else {
            message = "Erro ao fazer login. Tente novamente."
        }
        
        showErrorMessage(message)
    }
    
    /// Limpa os campos do formulário
    func clearForm() {
        email = ""
        password = ""
        errorMessage = ""
        showError = false
    }
}

// MARK: - Extensions

extension LoginViewModel {
    
    /// Dados de exemplo para desenvolvimento
    func fillWithSampleData() {
        email = "teste@exemplo.com"
        password = "123456"
    }
}