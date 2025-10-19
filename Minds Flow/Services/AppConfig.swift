//
//  AppConfig.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import Foundation

/// Configuração do aplicativo
struct AppConfig {
    static let appVersion = "1.0.0"
    static let appName = "Minds Flow"
    
    /// URL base para API REST (se necessário no futuro)
    static var apiBaseURL: URL? {
        return URL(string: "https://api.example.com")
    }
    
    /// Headers padrão para requisições (se necessário no futuro)
    static var defaultHeaders: [String: String] {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
}

/// Função para inicializar o aplicativo
func initializeApp() {
    print("\(AppConfig.appName) v\(AppConfig.appVersion) inicializado")
}