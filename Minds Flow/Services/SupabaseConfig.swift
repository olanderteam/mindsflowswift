//
//  SupabaseConfig.swift
//  Minds Flow
//
//  Created by Kiro on 18/10/25.
//

import Foundation

/// Configuração do Supabase
/// IMPORTANTE: Este arquivo contém credenciais e não deve ser commitado em produção
struct SupabaseConfig {
    
    // MARK: - Supabase Credentials
    static let projectURL = "https://txlukdftqiqbpdxuuozp.supabase.co"
    
    static let anonKey = """
    eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR4bHVrZGZ0cWlxYnBkeHV1b3pwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAyNzU2NzcsImV4cCI6MjA3NTg1MTY3N30.D4DXTknWbq2zHp3UKA_ecohfmP-11mNGhCkv8hYfMks
    """
    
    // MARK: - Computed Properties
    static var url: URL {
        guard let url = URL(string: projectURL) else {
            fatalError("Invalid Supabase URL: \(projectURL)")
        }
        return url
    }
    
    static var key: String {
        return anonKey.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Validation
    static func validate() -> Bool {
        guard !projectURL.isEmpty else {
            print("❌ Supabase URL is empty")
            return false
        }
        
        guard !anonKey.isEmpty else {
            print("❌ Supabase anon key is empty")
            return false
        }
        
        guard projectURL.hasPrefix("https://") else {
            print("❌ Supabase URL must use HTTPS")
            return false
        }
        
        print("✅ Supabase configuration is valid")
        return true
    }
}
