//
//  LoginView.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import SwiftUI

/// User login screen
/// Allows authentication with email and password
struct LoginView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel = LoginViewModel()
    @State private var showSignUp = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    
                    // MARK: - Header
                    headerSection
                    
                    // MARK: - Login Form
                    loginFormSection
                    
                    // MARK: - Action Buttons
                    actionButtonsSection
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
            }
            .background(
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationBarHidden(true)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Logo/Icon
            Image(systemName: "brain.head.profile")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            // App Name
            Text("Minds Flow")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Subtitle
            Text("Organize your mind, flow with purpose")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Login Form Section
    private var loginFormSection: some View {
        VStack(spacing: 20) {
            
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
                placeholder: "Enter your password"
            )
        }
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            
            // Login Button
            Button(action: {
                _Concurrency.Task {
                    await viewModel.login()
                }
            }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("Sign In")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(viewModel.isLoading || !viewModel.isFormValid)
            .opacity(viewModel.isFormValid ? 1.0 : 0.6)
            
            // Sign Up Button
            Button(action: {
                showSignUp = true
            }) {
                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.secondary)
                    Text("Sign Up")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

// MARK: - Custom Text Field

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

// MARK: - Custom Secure Field

struct CustomSecureField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    @State private var isSecure = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
                
                Button(action: {
                    isSecure.toggle()
                }) {
                    Image(systemName: isSecure ? "eye" : "eye.slash")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Preview

#Preview {
    LoginView()
}