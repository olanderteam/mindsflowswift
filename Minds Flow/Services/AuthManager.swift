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

/// Modelo de usuário
struct User: Codable, Identifiable {
    let id: UUID
    let email: String?
    let createdAt: Date?
    var metadata: [String: String]?
    
    var name: String? {
        return metadata?["name"]
    }
}

/// Manager para gerenciar autenticação com Supabase
/// Responsável por login, cadastro, sessão e perfil do usuário
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
        
        // Verificar se há sessão ativa ao inicializar
        _Concurrency.Task {
            await checkAuthStatus()
        }
    }
    
    // MARK: - Authentication Methods
    
    /// Verifica o status de autenticação atual
    func checkAuthStatus() async {
        isLoading = true
        
        do {
            // Verificar se há sessão ativa no Supabase
            let session = try await supabase.auth.session
            
            let authUser = session.user
            // Criar User a partir do Supabase User
            let user = User(
                id: authUser.id,
                email: authUser.email,
                createdAt: authUser.createdAt,
                metadata: authUser.userMetadata.toStringDictionary()
            )
            
            self.currentUser = user
            self.isAuthenticated = true
            
            // Carregar perfil do usuário
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
    
    /// Realiza login com email e senha
    /// - Parameters:
    ///   - email: Email do usuário
    ///   - password: Senha do usuário
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
            errorMessage = "Erro ao fazer login: \(error.localizedDescription)"
            print("❌ Sign in failed: \(error)")
            throw error
        }
        
        isLoading = false
    }
    
    /// Realiza cadastro de novo usuário
    /// - Parameters:
    ///   - email: Email do usuário
    ///   - password: Senha do usuário
    ///   - name: Nome do usuário
    func signUp(email: String, password: String, name: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            // Criar conta no Supabase
            let response = try await supabase.auth.signUp(
                email: email,
                password: password,
                data: ["name": .string(name)]
            )
            
            // Criar User a partir do Supabase User
            let user = User(
                id: response.user.id,
                email: response.user.email,
                createdAt: response.user.createdAt,
                metadata: ["name": name]
            )
            
            self.currentUser = user
            self.isAuthenticated = true
            
            // Salvar token no Keychain se houver sessão
            if let session = response.session {
                let accessToken = session.accessToken
                try? keychain.save(accessToken, for: .accessToken)
            }
            
            // Criar perfil do usuário
            await createUserProfile(for: user.id, name: name)
            
            print("✅ Sign up successful: \(email)")
            
        } catch {
            errorMessage = "Erro ao criar conta: \(error.localizedDescription)"
            print("❌ Sign up failed: \(error)")
            throw error
        }
        
        isLoading = false
    }
    
    /// Realiza logout do usuário
    func signOut() async throws {
        print("🔄 Starting sign out process...")
        isLoading = true
        errorMessage = nil
        
        do {
            // Fazer logout no Supabase
            try await supabase.auth.signOut()
            
            // Garantir que a atualização do estado aconteça na main thread
            await MainActor.run {
                // Limpar dados locais
                self.currentUser = nil
                self.userProfile = nil
                self.isAuthenticated = false
                print("✅ Authentication state cleared: isAuthenticated = \(self.isAuthenticated)")
            }
            
            // Limpar token do Keychain
            try? keychain.delete(for: .accessToken)
            
            // Limpar cache
            CacheManager.shared.clearAllCache()
            
            print("✅ Sign out successful")
            
        } catch {
            errorMessage = "Erro ao fazer logout: \(error.localizedDescription)"
            print("❌ Sign out failed: \(error)")
            throw error
        }
        
        isLoading = false
    }
    
    /// Envia email de recuperação de senha
    /// - Parameter email: Email do usuário
    func resetPassword(email: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabase.auth.resetPasswordForEmail(email)
            print("✅ Password reset email sent to: \(email)")
        } catch {
            errorMessage = "Erro ao enviar email de recuperação: \(error.localizedDescription)"
            print("❌ Password reset failed: \(error)")
            throw error
        }
        
        isLoading = false
    }
    
    /// Atualiza a senha do usuário
    /// - Parameter newPassword: Nova senha
    func updatePassword(newPassword: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabase.auth.update(user: UserAttributes(password: newPassword))
            print("✅ Password updated successfully")
        } catch {
            errorMessage = "Erro ao atualizar senha: \(error.localizedDescription)"
            print("❌ Password update failed: \(error)")
            throw error
        }
        
        isLoading = false
    }
    
    // MARK: - Session Management
    
    /// Renova a sessão do usuário
    func refreshSession() async throws {
        do {
            let session = try await supabase.auth.session
            
            // Atualizar token no Keychain
            let accessToken = session.accessToken
            try? keychain.save(accessToken, for: .accessToken)
            
            print("✅ Session refreshed successfully")
        } catch {
            print("❌ Session refresh failed: \(error)")
            throw error
        }
    }
    
    // MARK: - Profile Management
    
    /// Carrega o perfil do usuário do Supabase
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
                
                // Cachear perfil localmente
                try? CacheManager.shared.cacheSingle(profile, for: .profile)
                
                print("✅ User profile loaded")
            } else {
                print("⚠️ No profile found for user")
            }
        } catch {
            print("❌ Failed to load profile: \(error)")
            
            // Tentar carregar do cache
            if let cachedProfile: UserProfile = try? CacheManager.shared.getCachedSingle(for: .profile) {
                self.userProfile = cachedProfile
                print("✅ Loaded profile from cache")
            }
        }
    }
    
    /// Atualiza o perfil do usuário
    /// - Parameter profile: Perfil atualizado
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
            
            // Atualizar cache
            try? CacheManager.shared.cacheSingle(profile, for: .profile)
            
            print("✅ Profile updated successfully")
        } catch {
            print("❌ Failed to update profile: \(error)")
            throw error
        }
    }
    
    /// Cria perfil para novo usuário
    /// - Parameters:
    ///   - userId: ID do usuário
    ///   - name: Nome do usuário
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
            
            // Cachear perfil
            try? CacheManager.shared.cacheSingle(newProfile, for: .profile)
            
            print("✅ User profile created")
        } catch {
            print("❌ Failed to create profile: \(error)")
        }
    }
}

// MARK: - Extensions

extension AuthManager {
    
    /// Retorna o ID do usuário atual
    var currentUserId: String? {
        return currentUser?.id.uuidString
    }
    
    /// Retorna o email do usuário atual
    var currentUserEmail: String? {
        return currentUser?.email
    }
}