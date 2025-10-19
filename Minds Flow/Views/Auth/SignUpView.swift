//
//  SignUpView.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import SwiftUI

/// Tela de cadastro do usuário
/// Permite criação de nova conta com email, senha e nome
struct SignUpView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel = SignUpViewModel()
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    
                    // MARK: - Header
                    headerSection
                    
                    // MARK: - Sign Up Form
                    signUpFormSection
                    
                    // MARK: - Action Buttons
                    actionButtonsSection
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
            }
            .background(
                LinearGradient(
                    colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationTitle("Criar Conta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Erro", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .alert("Sucesso", isPresented: $viewModel.showSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Conta criada com sucesso! Verifique seu email para confirmar.")
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Icon
            Image(systemName: "person.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.purple)
            
            // Title
            Text("Bem-vindo ao Minds Flow")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Subtitle
            Text("Crie sua conta e comece a organizar sua mente")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Sign Up Form Section
    private var signUpFormSection: some View {
        VStack(spacing: 20) {
            
            // Name Field
            CustomTextField(
                title: "Nome Completo",
                text: $viewModel.name,
                placeholder: "Digite seu nome completo"
            )
            
            // Email Field
            CustomTextField(
                title: "Email",
                text: $viewModel.email,
                placeholder: "seu@email.com",
                keyboardType: .emailAddress
            )
            
            // Password Field
            CustomSecureField(
                title: "Senha",
                text: $viewModel.password,
                placeholder: "Mínimo 6 caracteres"
            )
            
            // Confirm Password Field
            CustomSecureField(
                title: "Confirmar Senha",
                text: $viewModel.confirmPassword,
                placeholder: "Digite a senha novamente"
            )
            
            // Password Requirements
            passwordRequirementsSection
        }
    }
    
    // MARK: - Password Requirements Section
    private var passwordRequirementsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Requisitos da senha:")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: viewModel.password.count >= 6 ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(viewModel.password.count >= 6 ? .green : .secondary)
                Text("Mínimo 6 caracteres")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            HStack {
                Image(systemName: viewModel.passwordsMatch ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(viewModel.passwordsMatch ? .green : .secondary)
                Text("Senhas coincidem")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            
            // Sign Up Button
            Button(action: {
                _Concurrency.Task {
                    await viewModel.signUp()
                }
            }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("Criar Conta")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(viewModel.isLoading || !viewModel.isFormValid)
            .opacity(viewModel.isFormValid ? 1.0 : 0.6)
            
            // Terms and Privacy
            Text("Ao criar uma conta, você concorda com nossos Termos de Uso e Política de Privacidade.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

// MARK: - Preview

#Preview {
    SignUpView()
}