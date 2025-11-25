//
//  CollapseModeViewModel.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import SwiftUI
import Combine

/// ViewModel to manage minimalist collapse mode
@MainActor
class CollapseModeViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var isCollapseMode: Bool = false {
        didSet {
            saveCollapseMode()
            if isCollapseMode {
                applyCollapseModeSettings()
            } else {
                resetCollapseModeSettings()
            }
        }
    }
    
    @Published var hideStatistics: Bool = true {
        didSet { saveCollapseModeSettings() }
    }
    
    @Published var simplifyNavigation: Bool = true {
        didSet { saveCollapseModeSettings() }
    }
    
    @Published var hideSuggestions: Bool = true {
        didSet { saveCollapseModeSettings() }
    }
    
    @Published var forceDarkMode: Bool = false {
        didSet { 
            saveCollapseModeSettings()
            if isCollapseMode {
                applyThemeSettings()
            }
        }
    }
    
    @Published var reduceAnimations: Bool = true {
        didSet { saveCollapseModeSettings() }
    }
    
    // MARK: - Private Properties
    
    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    // UserDefaults keys
    private let collapseModeKey = "collapse_mode_enabled"
    private let hideStatisticsKey = "collapse_hide_statistics"
    private let simplifyNavigationKey = "collapse_simplify_navigation"
    private let hideSuggestionsKey = "collapse_hide_suggestions"
    private let forceDarkModeKey = "collapse_force_dark_mode"
    private let reduceAnimationsKey = "collapse_reduce_animations"
    
    // MARK: - Initialization
    
    init() {
        loadCollapseModeSettings()
        setupNotifications()
    }
    
    // MARK: - Public Methods
    
    /// Ativa o modo colapso com configurações padrão
    func enableCollapseMode() {
        isCollapseMode = true
        hideStatistics = true
        simplifyNavigation = true
        hideSuggestions = true
        forceDarkMode = false
        reduceAnimations = true
    }
    
    /// Desativa o modo colapso
    func disableCollapseMode() {
        isCollapseMode = false
    }
    
    /// Alterna o modo colapso
    func toggleCollapseMode() {
        isCollapseMode.toggle()
    }
    
    /// Applies quick settings based on mental state
    func applyQuickSettings(for energyLevel: EnergyLevel) {
        switch energyLevel {
        case .low:
            // Máxima simplificação para baixa energia
            hideStatistics = true
            simplifyNavigation = true
            hideSuggestions = true
            forceDarkMode = true
            reduceAnimations = true
            
        case .medium:
            // Configuração balanceada
            hideStatistics = false
            simplifyNavigation = true
            hideSuggestions = false
            forceDarkMode = false
            reduceAnimations = true
            
        case .high:
            // Menos restrições para alta energia
            hideStatistics = false
            simplifyNavigation = false
            hideSuggestions = false
            forceDarkMode = false
            reduceAnimations = false
        }
    }
    
    /// Returns configurações de UI baseadas no modo colapso
    func getUIConfiguration() -> UIConfiguration {
        return UIConfiguration(
            isCollapseMode: isCollapseMode,
            hideStatistics: hideStatistics,
            simplifyNavigation: simplifyNavigation,
            hideSuggestions: hideSuggestions,
            forceDarkMode: forceDarkMode,
            reduceAnimations: reduceAnimations
        )
    }
    
    /// Checks if uma feature específica deve ser ocultada
    func shouldHideFeature(_ feature: CollapseFeature) -> Bool {
        guard isCollapseMode else { return false }
        
        switch feature {
        case .statistics:
            return hideStatistics
        case .suggestions:
            return hideSuggestions
        case .navigationLabels:
            return simplifyNavigation
        case .animations:
            return reduceAnimations
        case .colorfulElements:
            return forceDarkMode
        }
    }
    
    // MARK: - Private Methods
    
    private func loadCollapseModeSettings() {
        isCollapseMode = userDefaults.bool(forKey: collapseModeKey)
        hideStatistics = userDefaults.object(forKey: hideStatisticsKey) as? Bool ?? true
        simplifyNavigation = userDefaults.object(forKey: simplifyNavigationKey) as? Bool ?? true
        hideSuggestions = userDefaults.object(forKey: hideSuggestionsKey) as? Bool ?? true
        forceDarkMode = userDefaults.bool(forKey: forceDarkModeKey)
        reduceAnimations = userDefaults.object(forKey: reduceAnimationsKey) as? Bool ?? true
    }
    
    private func saveCollapseMode() {
        userDefaults.set(isCollapseMode, forKey: collapseModeKey)
    }
    
    private func saveCollapseModeSettings() {
        userDefaults.set(hideStatistics, forKey: hideStatisticsKey)
        userDefaults.set(simplifyNavigation, forKey: simplifyNavigationKey)
        userDefaults.set(hideSuggestions, forKey: hideSuggestionsKey)
        userDefaults.set(forceDarkMode, forKey: forceDarkModeKey)
        userDefaults.set(reduceAnimations, forKey: reduceAnimationsKey)
    }
    
    private func applyCollapseModeSettings() {
        // Apply settings when collapse mode is activated
        if forceDarkMode {
            applyThemeSettings()
        }
        
        // Notificar outras partes do app sobre a mudança
        NotificationCenter.default.post(
            name: .collapseModeDidChange,
            object: nil,
            userInfo: ["isEnabled": isCollapseMode]
        )
    }
    
    private func resetCollapseModeSettings() {
        // Resetar configurações quando o modo colapso é desativado
        NotificationCenter.default.post(
            name: .collapseModeDidChange,
            object: nil,
            userInfo: ["isEnabled": isCollapseMode]
        )
    }
    
    private func applyThemeSettings() {
        // TODO: Implementar mudança de tema quando integrado com sistema de temas
        // Por enquanto, apenas salva a preferência
    }
    
    private func setupNotifications() {
        // Observe mental state changes to suggest collapse mode
        NotificationCenter.default.publisher(for: .mentalStateDidUpdate)
            .sink { [weak self] notification in
                self?.handleMentalStateUpdate(notification)
            }
            .store(in: &cancellables)
    }
    
    private func handleMentalStateUpdate(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let energyLevel = userInfo["energyLevel"] as? EnergyLevel else {
            return
        }
        
        // Sugerir modo colapso para baixa energia
        if energyLevel == .low {
            // TODO: Mostrar sugestão para ativar modo colapso
            // Por enquanto, apenas log
            print("Sugerindo modo colapso devido à baixa energia: \(energyLevel)")
        }
    }
}

// MARK: - Supporting Types

/// Configuração de UI baseada no modo colapso
struct UIConfiguration {
    let isCollapseMode: Bool
    let hideStatistics: Bool
    let simplifyNavigation: Bool
    let hideSuggestions: Bool
    let forceDarkMode: Bool
    let reduceAnimations: Bool
    
    /// Duração das animações baseada na configuração
    var animationDuration: Double {
        return reduceAnimations ? 0.1 : 0.3
    }
    
    /// Opacidade para elementos secundários
    var secondaryOpacity: Double {
        return isCollapseMode ? 0.6 : 1.0
    }
    
    /// Espaçamento reduzido para modo colapso
    var spacing: CGFloat {
        return isCollapseMode ? 8 : 16
    }
    
    /// Padding reduzido para modo colapso
    var padding: CGFloat {
        return isCollapseMode ? 12 : 16
    }
}

/// Features que podem ser ocultadas no modo colapso
enum CollapseFeature {
    case statistics
    case suggestions
    case navigationLabels
    case animations
    case colorfulElements
}

// MARK: - Notification Extensions

extension Notification.Name {
    static let collapseModeDidChange = Notification.Name("collapseModeDidChange")
    static let mentalStateDidUpdate = Notification.Name("mentalStateDidUpdate")
}

// MARK: - UserDefaults Extension

extension UserDefaults {
    /// Configuração global do modo colapso
    var isCollapseModeEnabled: Bool {
        get { bool(forKey: "collapse_mode_enabled") }
        set { set(newValue, forKey: "collapse_mode_enabled") }
    }
}