//
//  ContentView.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import SwiftUI

/// Main view of Minds Flow application
/// Manages authentication flow and main navigation
struct ContentView: View {
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            // Main app content
            AuthView()
                .opacity(showSplash ? 0 : 1)
            
            // Splash screen overlay
            if showSplash {
                LaunchScreen()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onAppear {
            // Show splash for 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
