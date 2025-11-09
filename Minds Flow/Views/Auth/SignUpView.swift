//
//  SignUpView.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import SwiftUI

/// User registration screen
/// Allows creation of new account with email, password and name
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
            .navigationTitle("Create Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .alert("Success", isPresented: $viewModel.showSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Account created successfully! Check your email to confirm.")
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
            Text("Welcome to Minds Flow")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Subtitle
            Text("Create your account and start organizing your mind")
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
                title: "Full Name",
                text: $viewModel.name,
                placeholder: "Enter your full name"
            )
            
            // Email Field
            CustomTextField(
                title: "Email",
                text: $viewModel.email,
                placeholder: "your@email.com",
                keyboardType: .emailAddress
            )
            
            // Password Field
            CustomSecureField(
                title: "Password",
                text: $viewModel.password,
                placeholder: "Minimum 6 characters"
            )
            
            // Confirm Password Field
            CustomSecureField(
                title: "Confirm Password",
                text: $viewModel.confirmPassword,
                placeholder: "Enter password again"
            )
            
            // Password Requirements
            passwordRequirementsSection
        }
    }
    
    // MARK: - Password Requirements Section
    private var passwordRequirementsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Password requirements:")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: viewModel.password.count >= 6 ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(viewModel.password.count >= 6 ? .green : .secondary)
                Text("Minimum 6 characters")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            HStack {
                Image(systemName: viewModel.passwordsMatch ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(viewModel.passwordsMatch ? .green : .secondary)
                Text("Passwords match")
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
                        Text("Create Account")
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
            Text("By creating an account, you agree to our Terms of Use and Privacy Policy.")
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