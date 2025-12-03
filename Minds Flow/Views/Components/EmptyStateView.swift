//
//  EmptyStateView.swift
//  Minds Flow
//
//  Created by Kiro on 03/12/25.
//

import SwiftUI

/// Beautiful empty state views with illustrations and CTAs
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: icon)
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            // Text
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // Action Button
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text(actionTitle)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.top, 8)
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Predefined Empty States
extension EmptyStateView {
    static func noTasks(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "checkmark.circle",
            title: "No Tasks Yet",
            message: "Start organizing your day by creating your first task",
            actionTitle: "Create Task",
            action: action
        )
    }
    
    static func noWisdom(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "lightbulb",
            title: "No Wisdom Entries",
            message: "Capture your insights and learnings to build your personal wisdom library",
            actionTitle: "Add Wisdom",
            action: action
        )
    }
    
    static func noHistory() -> EmptyStateView {
        EmptyStateView(
            icon: "chart.line.uptrend.xyaxis",
            title: "No History Yet",
            message: "Your activity history will appear here as you use the app",
            actionTitle: nil,
            action: nil
        )
    }
    
    static func noSearchResults() -> EmptyStateView {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "No Results Found",
            message: "Try adjusting your search or filters to find what you're looking for",
            actionTitle: nil,
            action: nil
        )
    }
    
    static func noMentalStates(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "brain.head.profile",
            title: "Track Your Mental State",
            message: "Start tracking your mental wellness to gain insights over time",
            actionTitle: "Add Entry",
            action: action
        )
    }
    
    static func offline() -> EmptyStateView {
        EmptyStateView(
            icon: "wifi.slash",
            title: "You're Offline",
            message: "Connect to the internet to sync your data and access all features",
            actionTitle: nil,
            action: nil
        )
    }
}

// MARK: - Compact Empty State
struct CompactEmptyState: View {
    let icon: String
    let message: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.secondary)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

// MARK: - List Empty State
struct ListEmptyState: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}

// MARK: - Preview
struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EmptyStateView.noTasks(action: {})
            
            EmptyStateView.noWisdom(action: {})
            
            EmptyStateView.noSearchResults()
            
            CompactEmptyState(
                icon: "tray",
                message: "No items to display"
            )
            
            ListEmptyState(
                icon: "checkmark.circle",
                title: "All caught up!",
                subtitle: "You have no pending tasks"
            )
        }
    }
}
