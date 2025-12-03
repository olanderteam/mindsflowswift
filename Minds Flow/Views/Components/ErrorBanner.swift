//
//  ErrorBanner.swift
//  Minds Flow
//
//  Created by Kiro on 03/12/25.
//

import SwiftUI

/// Beautiful error banner with animations and actions
struct ErrorBanner: View {
    let error: AppError
    let onDismiss: () -> Void
    let onRetry: (() -> Void)?
    
    @State private var offset: CGFloat = -200
    @State private var opacity: Double = 0
    
    init(error: AppError, onDismiss: @escaping () -> Void, onRetry: (() -> Void)? = nil) {
        self.error = error
        self.onDismiss = onDismiss
        self.onRetry = onRetry
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Icon
                Image(systemName: error.icon)
                    .font(.title2)
                    .foregroundColor(.white)
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(error.errorDescription ?? "Error")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(error.detailedMessage)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Actions
                HStack(spacing: 8) {
                    if onRetry != nil {
                        Button(action: {
                            onRetry?()
                            withAnimation(.spring()) {
                                onDismiss()
                            }
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.body.weight(.semibold))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            onDismiss()
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.body.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [error.color, error.color.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .shadow(color: error.color.opacity(0.3), radius: 10, x: 0, y: 5)
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .offset(y: offset)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                offset = 0
                opacity = 1
            }
            
            // Auto dismiss after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation(.spring()) {
                    onDismiss()
                }
            }
        }
    }
}

/// Toast-style error message
struct ErrorToast: View {
    let error: AppError
    let onDismiss: () -> Void
    
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 12) {
                Image(systemName: error.icon)
                    .font(.title3)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(error.errorDescription ?? "Error")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                    
                    if let suggestion = error.recoverySuggestion {
                        Text(suggestion)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring()) {
                        onDismiss()
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(error.color)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1
                opacity = 1
            }
            
            // Auto dismiss after 4 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation(.spring()) {
                    onDismiss()
                }
            }
        }
    }
}

/// Inline error message for forms
struct InlineError: View {
    let message: String
    let icon: String
    
    init(_ message: String, icon: String = "exclamationmark.circle.fill") {
        self.message = message
        self.icon = icon
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
            
            Text(message)
                .font(.caption)
            
            Spacer()
        }
        .foregroundColor(.red)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.red.opacity(0.1))
        )
    }
}

// MARK: - View Modifiers
struct ErrorBannerModifier: ViewModifier {
    @ObservedObject var errorHandler = ErrorHandler.shared
    let onRetry: (() -> Void)?
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            
            if errorHandler.showError, let error = errorHandler.currentError {
                ErrorBanner(
                    error: error,
                    onDismiss: {
                        errorHandler.clearError()
                    },
                    onRetry: onRetry
                )
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(999)
            }
        }
    }
}

struct ErrorToastModifier: ViewModifier {
    @ObservedObject var errorHandler = ErrorHandler.shared
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if errorHandler.showError, let error = errorHandler.currentError {
                ErrorToast(
                    error: error,
                    onDismiss: {
                        errorHandler.clearError()
                    }
                )
                .transition(.scale.combined(with: .opacity))
                .zIndex(999)
            }
        }
    }
}

extension View {
    func errorBanner(onRetry: (() -> Void)? = nil) -> some View {
        modifier(ErrorBannerModifier(onRetry: onRetry))
    }
    
    func errorToast() -> some View {
        modifier(ErrorToastModifier())
    }
}

// MARK: - Preview
struct ErrorBanner_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ErrorBanner(
                error: .networkUnavailable,
                onDismiss: {},
                onRetry: {}
            )
            
            ErrorBanner(
                error: .invalidCredentials,
                onDismiss: {},
                onRetry: nil
            )
            
            InlineError("Email is required")
            
            InlineError("Password must be at least 8 characters", icon: "lock.slash")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
