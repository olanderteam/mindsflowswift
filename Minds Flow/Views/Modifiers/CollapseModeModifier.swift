//
//  CollapseModeModifier.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import SwiftUI

/// Modificador de view para aplicar estilos do modo colapso
struct CollapseModeModifier: ViewModifier {
    @ObservedObject var collapseModeViewModel: CollapseModeViewModel
    
    func body(content: Content) -> some View {
        content
            .environment(\.collapseMode, collapseModeViewModel.getUIConfiguration())
            .animation(
                .easeInOut(duration: collapseModeViewModel.getUIConfiguration().animationDuration),
                value: collapseModeViewModel.isCollapseMode
            )
    }
}

/// Environment key for collapse mode configuration
struct CollapseModeEnvironmentKey: EnvironmentKey {
    static let defaultValue = UIConfiguration(
        isCollapseMode: false,
        hideStatistics: false,
        simplifyNavigation: false,
        hideSuggestions: false,
        forceDarkMode: false,
        reduceAnimations: false
    )
}

extension EnvironmentValues {
    var collapseMode: UIConfiguration {
        get { self[CollapseModeEnvironmentKey.self] }
        set { self[CollapseModeEnvironmentKey.self] = newValue }
    }
}

// MARK: - View Extensions

extension View {
    /// Aplica o modificador de modo colapso
    func collapseMode(_ viewModel: CollapseModeViewModel) -> some View {
        self.modifier(CollapseModeModifier(collapseModeViewModel: viewModel))
    }
    
    /// Aplica estilos condicionais baseados no modo colapso
    @ViewBuilder
    func collapsible<Content: View>(
        @ViewBuilder content: @escaping (UIConfiguration) -> Content
    ) -> some View {
        GeometryReader { _ in
            content(UIConfiguration(
                isCollapseMode: UserDefaults.standard.isCollapseModeEnabled,
                hideStatistics: UserDefaults.standard.bool(forKey: "collapse_hide_statistics"),
                simplifyNavigation: UserDefaults.standard.bool(forKey: "collapse_simplify_navigation"),
                hideSuggestions: UserDefaults.standard.bool(forKey: "collapse_hide_suggestions"),
                forceDarkMode: UserDefaults.standard.bool(forKey: "collapse_force_dark_mode"),
                reduceAnimations: UserDefaults.standard.bool(forKey: "collapse_reduce_animations")
            ))
        }
    }
    
    /// Oculta a view se o modo colapso estiver ativo e a feature especificada estiver desabilitada
    @ViewBuilder
    func hideInCollapseMode(_ feature: CollapseFeature) -> some View {
        self.environment(\.collapseMode, UIConfiguration(
            isCollapseMode: UserDefaults.standard.isCollapseModeEnabled,
            hideStatistics: UserDefaults.standard.bool(forKey: "collapse_hide_statistics"),
            simplifyNavigation: UserDefaults.standard.bool(forKey: "collapse_simplify_navigation"),
            hideSuggestions: UserDefaults.standard.bool(forKey: "collapse_hide_suggestions"),
            forceDarkMode: UserDefaults.standard.bool(forKey: "collapse_force_dark_mode"),
            reduceAnimations: UserDefaults.standard.bool(forKey: "collapse_reduce_animations")
        ))
        .opacity(shouldHideFeature(feature) ? 0 : 1)
        .disabled(shouldHideFeature(feature))
    }
    
    /// Aplica padding reduzido no modo colapso
    func collapsePadding(_ edges: Edge.Set = .all) -> some View {
        let config = UIConfiguration(
            isCollapseMode: UserDefaults.standard.isCollapseModeEnabled,
            hideStatistics: false,
            simplifyNavigation: false,
            hideSuggestions: false,
            forceDarkMode: false,
            reduceAnimations: false
        )
        return self.padding(edges, config.padding)
    }
    
    /// Aplica espaçamento reduzido no modo colapso
    func collapseSpacing() -> some View {
        let config = UIConfiguration(
            isCollapseMode: UserDefaults.standard.isCollapseModeEnabled,
            hideStatistics: false,
            simplifyNavigation: false,
            hideSuggestions: false,
            forceDarkMode: false,
            reduceAnimations: false
        )
        
        if let vstack = self as? VStack<AnyView> {
            return AnyView(vstack)
        } else if let hstack = self as? HStack<AnyView> {
            return AnyView(hstack)
        } else {
            return AnyView(self)
        }
    }
    
    /// Aplica opacidade reduzida para elementos secundários no modo colapso
    func collapseSecondary() -> some View {
        let config = UIConfiguration(
            isCollapseMode: UserDefaults.standard.isCollapseModeEnabled,
            hideStatistics: false,
            simplifyNavigation: false,
            hideSuggestions: false,
            forceDarkMode: false,
            reduceAnimations: false
        )
        return self.opacity(config.secondaryOpacity)
    }
    
    // MARK: - Private Helpers
    
    private func shouldHideFeature(_ feature: CollapseFeature) -> Bool {
        guard UserDefaults.standard.isCollapseModeEnabled else { return false }
        
        switch feature {
        case .statistics:
            return UserDefaults.standard.bool(forKey: "collapse_hide_statistics")
        case .suggestions:
            return UserDefaults.standard.bool(forKey: "collapse_hide_suggestions")
        case .navigationLabels:
            return UserDefaults.standard.bool(forKey: "collapse_simplify_navigation")
        case .animations:
            return UserDefaults.standard.bool(forKey: "collapse_reduce_animations")
        case .colorfulElements:
            return UserDefaults.standard.bool(forKey: "collapse_force_dark_mode")
        }
    }
}

// MARK: - Collapse-Aware Components

/// Botão que se adapta ao modo colapso
struct CollapseAwareButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    @Environment(\.collapseMode) private var collapseMode
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: collapseMode.spacing) {
                Image(systemName: icon)
                    .font(collapseMode.isCollapseMode ? .caption : .subheadline)
                
                if !collapseMode.simplifyNavigation {
                    Text(title)
                        .font(collapseMode.isCollapseMode ? .caption : .subheadline)
                        .fontWeight(.medium)
                }
            }
            .padding(.horizontal, collapseMode.padding)
            .padding(.vertical, collapseMode.padding / 2)
            .background(
                RoundedRectangle(cornerRadius: collapseMode.isCollapseMode ? 6 : 8)
                    .fill(Color.blue.opacity(collapseMode.isCollapseMode ? 0.1 : 0.15))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Card que se adapta ao modo colapso
struct CollapseAwareCard<Content: View>: View {
    let content: Content
    
    @Environment(\.collapseMode) private var collapseMode
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(collapseMode.padding)
            .background(
                RoundedRectangle(cornerRadius: collapseMode.isCollapseMode ? 8 : 12)
                    .fill(Color(.systemGray6))
                    .shadow(
                        color: collapseMode.isCollapseMode ? .clear : .black.opacity(0.05),
                        radius: collapseMode.isCollapseMode ? 0 : 2,
                        x: 0,
                        y: 1
                    )
            )
    }
}

/// Texto que se adapta ao modo colapso
struct CollapseAwareText: View {
    let text: String
    let style: TextStyle
    
    @Environment(\.collapseMode) private var collapseMode
    
    enum TextStyle {
        case title
        case headline
        case body
        case caption
    }
    
    var body: some View {
        Text(text)
            .font(fontForStyle)
            .opacity(collapseMode.secondaryOpacity)
    }
    
    private var fontForStyle: Font {
        if collapseMode.isCollapseMode {
            switch style {
            case .title: return .headline
            case .headline: return .subheadline
            case .body: return .caption
            case .caption: return .caption2
            }
        } else {
            switch style {
            case .title: return .title2
            case .headline: return .headline
            case .body: return .body
            case .caption: return .caption
            }
        }
    }
}

/// Spacer que se adapta ao modo colapso
struct CollapseAwareSpacer: View {
    @Environment(\.collapseMode) private var collapseMode
    
    var body: some View {
        Spacer(minLength: collapseMode.spacing)
    }
}