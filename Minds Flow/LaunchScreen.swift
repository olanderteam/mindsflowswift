//
//  LaunchScreen.swift
//  Minds Flow
//
//  Launch screen with app icon and branding
//

import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("LaunchBackground"),
                    Color("LaunchBackground").opacity(0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // App Icon
                Image("LaunchIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .cornerRadius(30)
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                
                // App Name
                Text("Minds Flow")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                // Tagline
                Text("Your Mental Wellness Companion")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
    }
}

#Preview {
    LaunchScreen()
}
