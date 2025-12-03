//
//  KeychainManager.swift
//  Minds Flow
//
//  Created by Kiro on 18/10/25.
//

import Foundation
import Security

/// Manager for secure Keychain storage
/// Stores tokens and sensitive data in encrypted form
class KeychainManager {
    
    // MARK: - Singleton
    static let shared = KeychainManager()
    
    // MARK: - Keys
    enum KeychainKey: String {
        case accessToken = "com.mindsflow.accessToken"
        case refreshToken = "com.mindsflow.refreshToken"
        case userSession = "com.mindsflow.userSession"
    }
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Save
    
    /// Saves um valor no Keychain
    /// - Parameters:
    ///   - value: Valor a ser salvo
    ///   - key: Keychain key
    func save(_ value: String, for key: KeychainKey) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.invalidData
        }
        
        // Delete existing value first
        try? delete(for: key)
        
        // Create query to add
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
        
        print("✅ Saved to Keychain: \(key.rawValue)")
    }
    
    // MARK: - Retrieve
    
    /// Retrieves um valor do Keychain
    /// - Parameter key: Keychain key
    /// - Returns: Valor armazenado ou nil
    func retrieve(for key: KeychainKey) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                return nil
            }
            throw KeychainError.retrieveFailed(status)
        }
        
        guard let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }
        
        return value
    }
    
    // MARK: - Delete
    
    /// Deletes a value from Keychain
    /// - Parameter key: Keychain key
    func delete(for key: KeychainKey) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
        
        print("✅ Deleted from Keychain: \(key.rawValue)")
    }
    
    // MARK: - Clear All
    
    /// Clears all Keychain values for the app
    func clearAll() throws {
        for key in KeychainKey.allCases {
            try? delete(for: key)
        }
        print("✅ Cleared all Keychain data")
    }
    
    // MARK: - Check Existence
    
    /// Checks if existe um valor para a chave
    /// - Parameter key: Keychain key
    /// - Returns: true se existe
    func exists(for key: KeychainKey) -> Bool {
        return (try? retrieve(for: key)) != nil
    }
}

// MARK: - Keychain Error

enum KeychainError: LocalizedError {
    case invalidData
    case saveFailed(OSStatus)
    case retrieveFailed(OSStatus)
    case deleteFailed(OSStatus)
    
    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Invalid data for Keychain"
        case .saveFailed(let status):
            return "Failed to save to Keychain (status: \(status))"
        case .retrieveFailed(let status):
            return "Failed to retrieve from Keychain (status: \(status))"
        case .deleteFailed(let status):
            return "Failed to delete from Keychain (status: \(status))"
        }
    }
}

// MARK: - KeychainKey Extension

extension KeychainManager.KeychainKey: CaseIterable {}
