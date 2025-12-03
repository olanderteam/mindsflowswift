//
//  LoadingView.swift
//  Minds Flow
//
//  Created by Kiro on 03/12/25.
//

import SwiftUI

/// Beautiful loading indicators with animations
struct LoadingView: View {
    let message: String?
    let style: LoadingStyle
    
    enum LoadingStyle {
        case spinner
        case dots
        case pulse
        case skeleton
    }
    
    init(message: String? = nil, style: LoadingStyle = .spinner) {
        self.message = message
        self.style = style
    }
    
    var body: some View {
        VStack(spacing: 16) {
            switch style {
            case .spinner:
                SpinnerView()
            case .dots:
                DotsView()
            case .pulse:
                PulseView()
            case .skeleton:
                SkeletonView()
            }
            
            if let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

// MARK: - Spinner View
struct SpinnerView: View {
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 4, lineCap: .round)
            )
            .frame(width: 50, height: 50)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .animation(
                .linear(duration: 1)
                .repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

// MARK: - Dots View
struct DotsView: View {
    @State private var animatingDot = 0
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.blue)
                    .frame(width: 12, height: 12)
                    .scaleEffect(animatingDot == index ? 1.2 : 0.8)
                    .opacity(animatingDot == index ? 1 : 0.5)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    animatingDot = (animatingDot + 1) % 3
                }
            }
        }
    }
}

// MARK: - Pulse View
struct PulseView: View {
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: 60, height: 60)
                .scaleEffect(isPulsing ? 1.2 : 0.8)
            
            Circle()
                .fill(Color.blue)
                .frame(width: 40, height: 40)
        }
        .animation(
            .easeInOut(duration: 1)
            .repeatForever(autoreverses: true),
            value: isPulsing
        )
        .onAppear {
            isPulsing = true
        }
    }
}

// MARK: - Skeleton View
struct SkeletonView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<3) { _ in
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.gray.opacity(0.3),
                                Color.gray.opacity(0.1),
                                Color.gray.opacity(0.3)
                            ],
                            startPoint: isAnimating ? .leading : .trailing,
                            endPoint: isAnimating ? .trailing : .leading
                        )
                    )
                    .frame(height: 60)
            }
        }
        .animation(
            .linear(duration: 1.5)
            .repeatForever(autoreverses: false),
            value: isAnimating
        )
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Inline Loading
struct InlineLoading: View {
    let message: String
    
    var body: some View {
        HStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - Full Screen Loading
struct FullScreenLoading: View {
    let message: String?
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                SpinnerView()
                
                if let message = message {
                    Text(message)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
        }
    }
}

// MARK: - View Modifiers
struct LoadingModifier: ViewModifier {
    let isLoading: Bool
    let message: String?
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isLoading)
                .blur(radius: isLoading ? 2 : 0)
            
            if isLoading {
                FullScreenLoading(message: message)
                    .transition(.opacity)
            }
        }
    }
}

struct InlineLoadingModifier: ViewModifier {
    let isLoading: Bool
    let message: String
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .opacity(isLoading ? 0.5 : 1)
            
            if isLoading {
                InlineLoading(message: message)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

extension View {
    func loading(_ isLoading: Bool, message: String? = nil) -> some View {
        modifier(LoadingModifier(isLoading: isLoading, message: message))
    }
    
    func inlineLoading(_ isLoading: Bool, message: String = "Loading...") -> some View {
        modifier(InlineLoadingModifier(isLoading: isLoading, message: message))
    }
}

// MARK: - Preview
struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            LoadingView(message: "Loading tasks...", style: .spinner)
            LoadingView(message: "Syncing data...", style: .dots)
            LoadingView(message: "Processing...", style: .pulse)
            
            InlineLoading(message: "Saving changes...")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
