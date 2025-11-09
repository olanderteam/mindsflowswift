//
//  AuthManager.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//  Updated by Kiro on 18/10/25.
//

import Foundation
import SwiftUI
import Supabase

/// User model
struct User: Codable, Identifiable {
    let id: UUID
    let email: String?
    let createdAt: Date?
    var metadata: [String: String]?
    
    var name: String? {
        return metadata?["name"]
    }
}

/// Manager to handle authentication with Supabase
/// Responsible for login, signup, session and user profile
@MainActor
class AuthManager: ObservableObject {
    
    // MARK: - Singleton Instance
    static let shared = AuthManager()
    
    // MARK: - Properties
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var userProfile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase: SupabaseClient
    private let keychain = KeychainManager.shared
    
    // MARK: - Initialization
    private init() {
        self.supabase = SupabaseManager.shared.supabase
        
        // Check if there's an active session on initialization
        _Concurrency.Task {
            await checkAuthStatus()
        }
    }
    
    // MARK: - Authentication Methods
    
    /// Checks current authentication status
    func checkAuthStatus() async {
        isLoading = true
        
        do {
            // Check if there's an active session in Supabase
            let session = try await supabase.auth.session
            
            let authUser = session.user
            // Create User from Supabase User
            let user = User(
                id: authUser.id,
                email: authUser.email,
                createdAt: authUser.createdAt,
                metadata: authUser.userMetadata.toStringDictionary()
            )
            
            self.currentUser = user
            self.isAuthenticated = true
            
            // Load user profile
            await loadUserProfile()
            
            print("✅ User authenticated: \(authUser.email ?? "unknown")")
        } catch {
            self.currentUser = nil
            self.userProfile = nil
            self.isAuthenticated = false
            print("ℹ️ No active session: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    /// Performs login with email and password
    /// - Parameters:
    ///   - email: User email
    ///   - password: User password
    func signIn(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            // Autenticar com Supabase
            let session = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            
            // Criar User a partir do Supabase User
            let user = User(
                id: session.user.id,
                email: session.user.email,
                createdAt: session.user.createdAt,
                metadata: session.user.userMetadata.toStringDictionary()
            )
            
            self.currentUser = user
            self.isAuthenticated = true
            
            // Salvar token no Keychain
            let accessToken = session.accessToken
            try? keychain.save(accessToken, for: .accessToken)
            
            // Carregar perfil do usuário
            await loadUserProfile()
            
            print("✅ Sign in successful: \(email)")
            
        } catch {
            errorMessage = "Error logging in: \(error.localizedDescription)"
            print("❌ Sign in failed: \(error)")
            throw error
        }
        
        isLoading = false
    }
    
    /// Performs signup for new user
    /// - Parameters:
    ///   - email: User email
    ///   - password: User password
    ///   - name: User name
    func signUp(email: String, password: String, name: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            // Create account in Supabase
            let response = try await supabase.auth.signUp(
                email: email,
                password: password,
                data: ["name": .string(name)]
            )
            
            // Create User from Supabase User
            let user = User(
                id: response.user.id,
                email: response.user.email,
                createdAt: response.user.createdAt,
                metadata: ["name": name]
            )
            
            self.currentUser = user
            self.isAuthenticated = true
            
            // Save token in Keychain if there's a session
            if let session = response.session {
                let accessToken = session.accessToken
                try? keychain.save(accessToken, for: .accessToken)
            }
            
            // Create user profile
            await createUserProfile(for: user.id, name: name)
            
            print("✅ Sign up successful: \(email)")
            
        } catch {
            errorMessage = "Error creating account: \(error.localizedDescription)"
            print("❌ Sign up failed: \(error)")
            throw error
        }
        
        isLoading = false
    }
    
    /// Performs user logout
    func signOut() async throws {
        print("🔄 Starting sign out process...")
        isLoading = true
        errorMessage = nil
        
        do {
            // Logout from Supabase
            try await supabase.auth.signOut()
            
            // Ensure state update happens on main thread
            await MainActor.run {
                // Clear local data
                self.currentUser = nil
                self.userProfile = nil
                self.isAuthenticated = false
                print("✅ Authentication state cleared: isAuthenticated = \(self.isAuthenticated)")
            }
            
            // Clear token from Keychain
            try? keychain.delete(for: .accessToken)
            
            // Clear cache
            CacheManager.shared.clearAllCache()
            
            print("✅ Sign out successful")
            
        } catch {
            errorMessage = "Error logging out: \(error.localizedDescription)"
            print("❌ Sign out failed: \(error)")
            throw error
        }
        
        isLoading = false
    }
    
    /// Sends password recovery email
    /// - Parameter email: User email
    func resetPassword(email: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabase.auth.resetPasswordForEmail(email)
            print("✅ Password reset email sent to: \(email)")
        } catch {
            errorMessage = "Error sending recovery email: \(error.localizedDescription)"
            print("❌ Password reset failed: \(error)")
            throw error
        }
        
        isLoading = false
    }
    
    /// Updates user password
    /// - Parameter newPassword: New password
    func updatePassword(newPassword: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabase.auth.update(user: UserAttributes(password: newPassword))
            print("✅ Password updated successfully")
        } catch {
            errorMessage = "Error updating password: \(error.localizedDescription)"
            print("❌ Password update failed: \(error)")
            throw error
        }
        
        isLoading = false
    }
    
    // MARK: - Session Management
    
    /// Refreshes user session
    func refreshSession() async throws {
        do {
            let session = try await supabase.auth.session
            
            // Update token in Keychain
            let accessToken = session.accessToken
            try? keychain.save(accessToken, for: .accessToken)
            
            print("✅ Session refreshed successfully")
        } catch {
            print("❌ Session refresh failed: \(error)")
            throw error
        }
    }
    
    // MARK: - Profile Management
    
    /// Loads user profile from Supabase
    func loadUserProfile() async {
        guard let userId = currentUser?.id else {
            print("⚠️ Cannot load profile: no user ID")
            return
        }
        
        do {
            let profiles: [UserProfile] = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: userId.uuidString)
                .execute()
                .value
            
            if let profile = profiles.first {
                self.userProfile = profile
                
                // Cache profile locally
                try? CacheManager.shared.cacheSingle(profile, for: .profile)
                
                print("✅ User profile loaded")
            } else {
                print("⚠️ No profile found for user")
            }
        } catch {
            print("❌ Failed to load profile: \(error)")
            
            // Try loading from cache
            if let cachedProfile: UserProfile = try? CacheManager.shared.getCachedSingle(for: .profile) {
                self.userProfile = cachedProfile
                print("✅ Loaded profile from cache")
            }
        }
    }
    
    /// Updates user profile
    /// - Parameter profile: Updated profile
    func updateUserProfile(_ profile: UserProfile) async throws {
        do {
            let _: UserProfile = try await supabase
                .from("profiles")
                .update(profile)
                .eq("id", value: profile.id.uuidString)
                .single()
                .execute()
                .value
            
            self.userProfile = profile
            
            // Update cache
            try? CacheManager.shared.cacheSingle(profile, for: .profile)
            
            print("✅ Profile updated successfully")
        } catch {
            print("❌ Failed to update profile: \(error)")
            throw error
        }
    }
    
    /// Creates profile for new user
    /// - Parameters:
    ///   - userId: User ID
    ///   - name: User name
    func createUserProfile(for userId: UUID, name: String) async {
        let newProfile = UserProfile(
            id: userId,
            name: name,
            theme: .system,
            language: "pt"
        )
        
        do {
            let _: UserProfile = try await supabase
                .from("profiles")
                .insert(newProfile)
                .single()
                .execute()
                .value
            
            self.userProfile = newProfile
            
            // Cache profile
            try? CacheManager.shared.cacheSingle(newProfile, for: .profile)
            
            print("✅ User profile created")
        } catch {
            print("❌ Failed to create profile: \(error)")
        }
    }
}

// MARK: - Extensions

extension AuthManager {
    
    /// Returns current user ID
    var currentUserId: String? {
        return currentUser?.id.uuidString
    }
    
    /// Returns current user email
    var currentUserEmail: String? {
        return currentUser?.email
    }
}