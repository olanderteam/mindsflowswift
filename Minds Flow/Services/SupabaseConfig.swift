//
//  SupabaseConfig.swift
//  Minds Flow
//
//  Created by Kiro on 18/10/25.
//

import Foundation

/// Supabase configuration
/// Reads credentials from Info.plist (populated from Config.xcconfig)
/// SECURE: No hardcoded credentials in source code
struct SupabaseConfig {
    
    // MARK: - Configuration Keys
    private enum ConfigKey: String {
        case supabaseURL = "SUPABASE_URL"
        case supabaseAnonKey = "SUPABASE_ANON_KEY"
    }
    
    // MARK: - Supabase Credentials (from Info.plist)
    static var projectURL: String {
        guard let url = Bundle.main.object(forInfoDictionaryKey: ConfigKey.supabaseURL.rawValue) as? String,
              !url.isEmpty else {
            fatalError("""
                ❌ SUPABASE_URL not found in Info.plist
                
                Setup Instructions:
                1. Copy Config.example.xcconfig to Config.xcconfig
                2. Fill in your Supabase credentials in Config.xcconfig
                3. Make sure Config.xcconfig is added to your target's build settings
                4. Rebuild the project
                
                See README.md for detailed setup instructions.
                """)
        }
        return url
    }
    
    static var anonKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: ConfigKey.supabaseAnonKey.rawValue) as? String,
              !key.isEmpty else {
            fatalError("""
                ❌ SUPABASE_ANON_KEY not found in Info.plist
                
                Setup Instructions:
                1. Copy Config.example.xcconfig to Config.xcconfig
                2. Fill in your Supabase credentials in Config.xcconfig
                3. Make sure Config.xcconfig is added to your target's build settings
                4. Rebuild the project
                
                See README.md for detailed setup instructions.
                """)
        }
        return key
    }
    
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
        print("📍 Using Supabase URL: \(projectURL)")
        return true
    }
    
    // MARK: - Debug Info
    #if DEBUG
    static func printConfiguration() {
        print("""
            
            🔧 Supabase Configuration:
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            URL: \(projectURL)
            Key: \(String(anonKey.prefix(20)))...
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            
            """)
    }
    #endif
}
