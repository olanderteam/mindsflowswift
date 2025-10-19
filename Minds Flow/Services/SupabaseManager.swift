//
//  SupabaseManager.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//  Updated by Kiro on 18/10/25.
//

import Foundation
import SwiftUI
import Supabase

/// Helper para converter AnyJSON para String
extension Dictionary where Key == String, Value == AnyJSON {
    func toStringDictionary() -> [String: String] {
        var result: [String: String] = [:]
        for (key, value) in self {
            if case .string(let stringValue) = value {
                result[key] = stringValue
            }
        }
        return result
    }
}

/// Manager para integração com Supabase
/// Gerencia autenticação e operações de banco de dados
@MainActor
class SupabaseManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = SupabaseManager()
    
    // MARK: - Properties
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isOnline = true
    @Published var connectionStatus: ConnectionStatus = .disconnected
    
    let supabase: SupabaseClient
    
    // MARK: - Connection Status
    enum ConnectionStatus {
        case connected
        case connecting
        case disconnected
        case error(String)
        
        var description: String {
            switch self {
            case .connected:
                return "Conectado"
            case .connecting:
                return "Conectando..."
            case .disconnected:
                return "Desconectado"
            case .error(let message):
                return "Erro: \(message)"
            }
        }
    }
    
    // MARK: - Initialization
    private init() {
        // Validar configuração
        guard SupabaseConfig.validate() else {
            fatalError("Invalid Supabase configuration")
        }
        
        // Inicializar cliente Supabase com credenciais reais
        self.supabase = SupabaseClient(
            supabaseURL: SupabaseConfig.url,
            supabaseKey: SupabaseConfig.key
        )
        
        print("✅ SupabaseManager initialized with project: \(SupabaseConfig.projectURL)")
        
        // Iniciar monitoramento de rede
        _ = NetworkMonitor.shared
        
        // Verificar conexão e status de autenticação
        _Concurrency.Task {
            await checkConnection()
            await checkAuthStatus()
        }
    }
    
    // MARK: - Connection Management
    
    /// Verifica conexão com Supabase
    func checkConnection() async {
        connectionStatus = .connecting
        
        do {
            // Tentar fazer uma query simples para verificar conexão
            struct EmptyResponse: Codable {}
            let _: [EmptyResponse] = try await supabase
                .from("profiles")
                .select()
                .limit(1)
                .execute()
                .value
            
            await MainActor.run {
                self.connectionStatus = .connected
                self.isOnline = true
                print("✅ Connected to Supabase successfully")
            }
        } catch {
            await MainActor.run {
                self.connectionStatus = .error(error.localizedDescription)
                self.isOnline = false
                print("❌ Failed to connect to Supabase: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Authentication
    
    /// Verifica status de autenticação
    func checkAuthStatus() async {
        do {
            // Verificar se há sessão ativa no Supabase
            let session = try await supabase.auth.session
            
            await MainActor.run {
                let user = session.user
                self.currentUser = User(
                    id: user.id,
                    email: user.email,
                    createdAt: user.createdAt,
                    metadata: user.userMetadata.toStringDictionary()
                )
                self.isAuthenticated = true
                print("✅ User authenticated: \(user.email ?? "unknown")")
            }
        } catch {
            await MainActor.run {
                self.currentUser = nil
                self.isAuthenticated = false
                print("ℹ️ No active session: \(error.localizedDescription)")
            }
        }
    }
    
    /// ID do usuário atual (usa AuthManager como fonte de verdade)
    var currentUserId: String? {
        return AuthManager.shared.currentUser?.id.uuidString
    }
    
    /// Usuário atual (usa AuthManager como fonte de verdade)
    var authenticatedUser: User? {
        return AuthManager.shared.currentUser
    }
    
    // MARK: - Generic CRUD Operations
    
    /// Busca dados do banco com query opcional
    /// - Parameters:
    ///   - table: Nome da tabela
    ///   - query: Query opcional para filtros
    /// - Returns: Array de objetos do tipo especificado
    func fetch<T: Codable>(
        from table: String,
        query: SupabaseQuery? = nil
    ) async throws -> [T] {
        guard isOnline else {
            throw SupabaseError.offline
        }
        
        var queryBuilder = supabase.from(table).select()
        
        // Aplicar filtros se houver query
        if let query = query {
            queryBuilder = query.apply(to: queryBuilder)
        }
        
        let response: [T] = try await queryBuilder.execute().value
        
        print("✅ Fetched \(response.count) items from \(table)")
        return response
    }
    
    /// Busca um único registro
    /// - Parameters:
    ///   - table: Nome da tabela
    ///   - id: ID do registro
    /// - Returns: Objeto do tipo especificado
    func fetchSingle<T: Codable>(
        from table: String,
        id: UUID
    ) async throws -> T {
        guard isOnline else {
            throw SupabaseError.offline
        }
        
        let response: T = try await supabase
            .from(table)
            .select()
            .eq("id", value: id.uuidString)
            .single()
            .execute()
            .value
        
        print("✅ Fetched single item from \(table)")
        return response
    }
    
    /// Insere dados no banco
    /// - Parameters:
    ///   - data: Dados a serem inseridos
    ///   - table: Nome da tabela
    /// - Returns: Dados inseridos com ID gerado
    func insert<T: Codable>(_ data: T, into table: String) async throws -> T {
        guard isOnline else {
            throw SupabaseError.offline
        }
        
        let response: T = try await supabase
            .from(table)
            .insert(data)
            .single()
            .execute()
            .value
        
        print("✅ Inserted item into \(table)")
        return response
    }
    
    /// Insere múltiplos registros
    /// - Parameters:
    ///   - data: Array de dados a serem inseridos
    ///   - table: Nome da tabela
    /// - Returns: Array de dados inseridos
    func insertMany<T: Codable>(_ data: [T], into table: String) async throws -> [T] {
        guard isOnline else {
            throw SupabaseError.offline
        }
        
        let response: [T] = try await supabase
            .from(table)
            .insert(data)
            .execute()
            .value
        
        print("✅ Inserted \(response.count) items into \(table)")
        return response
    }
    
    /// Atualiza dados no banco
    /// - Parameters:
    ///   - data: Dados atualizados
    ///   - table: Nome da tabela
    ///   - id: ID do registro
    /// - Returns: Dados atualizados
    func update<T: Codable>(_ data: T, in table: String, id: UUID) async throws -> T {
        guard isOnline else {
            throw SupabaseError.offline
        }
        
        let response: T = try await supabase
            .from(table)
            .update(data)
            .eq("id", value: id.uuidString)
            .single()
            .execute()
            .value
        
        print("✅ Updated item in \(table)")
        return response
    }
    
    /// Deleta dados do banco
    /// - Parameters:
    ///   - table: Nome da tabela
    ///   - id: ID do registro
    func delete(from table: String, id: UUID) async throws {
        guard isOnline else {
            throw SupabaseError.offline
        }
        
        try await supabase
            .from(table)
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
        
        print("✅ Deleted item from \(table)")
    }
    
    /// Deleta múltiplos registros com filtro
    /// - Parameters:
    ///   - table: Nome da tabela
    ///   - query: Query para filtrar registros a deletar
    func deleteMany(from table: String, query: SupabaseQuery) async throws {
        guard isOnline else {
            throw SupabaseError.offline
        }
        
        var queryBuilder = supabase.from(table).delete()
        queryBuilder = query.apply(to: queryBuilder)
        
        try await queryBuilder.execute()
        
        print("✅ Deleted items from \(table)")
    }
    
    /// Conta registros na tabela
    /// - Parameters:
    ///   - table: Nome da tabela
    ///   - query: Query opcional para filtros
    /// - Returns: Número de registros
    func count(in table: String, query: SupabaseQuery? = nil) async throws -> Int {
        guard isOnline else {
            throw SupabaseError.offline
        }
        
        var queryBuilder = supabase.from(table).select(count: .exact)
        
        if let query = query {
            queryBuilder = query.apply(to: queryBuilder)
        }
        
        let response = try await queryBuilder.execute()
        return response.count ?? 0
    }
    
    // MARK: - Realtime Subscriptions
    
    /// Subscreve a mudanças em uma tabela
    /// - Parameters:
    ///   - table: Nome da tabela
    ///   - event: Tipo de evento (insert, update, delete, *)
    ///   - filter: Filtro opcional (ex: "user_id=eq.123")
    ///   - onChange: Callback chamado quando há mudanças
    /// - Returns: Channel do Realtime para gerenciar a subscrição
    func subscribe<T: Codable>(
        to table: String,
        event: RealtimeEvent = .all,
        filter: String? = nil,
        onChange: @escaping ([T]) -> Void
    ) -> RealtimeChannelV2 {
        let channel = supabase.realtimeV2.channel("public:\(table)")
        
        // TODO: Implementar Realtime V2 corretamente
        // A API mudou significativamente na versão 2.36.0
        print("⚠️ Realtime subscription temporarily disabled - needs migration to V2 API")
        
        return channel
    }
    
    /// Cancela subscrição de um channel
    /// - Parameter channel: Channel a ser cancelado
    func unsubscribe(from channel: RealtimeChannelV2) async {
        await channel.unsubscribe()
        print("✅ Unsubscribed from realtime channel")
    }
}

// MARK: - Supabase Query Builder

/// Construtor de queries para Supabase
struct SupabaseQuery {
    private var filters: [(String, String, Any)] = []
    private var orderColumn: String?
    private var orderDescending: Bool = false
    private var limitValue: Int?
    private var rangeStart: Int?
    private var rangeEnd: Int?
    
    /// Adiciona filtro de igualdade
    func eq(_ column: String, value: Any) -> SupabaseQuery {
        var query = self
        query.filters.append((column, "eq", value))
        return query
    }
    
    /// Adiciona filtro de diferença
    func neq(_ column: String, value: Any) -> SupabaseQuery {
        var query = self
        query.filters.append((column, "neq", value))
        return query
    }
    
    /// Adiciona filtro maior que
    func gt(_ column: String, value: Any) -> SupabaseQuery {
        var query = self
        query.filters.append((column, "gt", value))
        return query
    }
    
    /// Adiciona filtro menor que
    func lt(_ column: String, value: Any) -> SupabaseQuery {
        var query = self
        query.filters.append((column, "lt", value))
        return query
    }
    
    /// Adiciona ordenação
    func orderBy(_ column: String, descending: Bool = false) -> SupabaseQuery {
        var query = self
        query.orderColumn = column
        query.orderDescending = descending
        return query
    }
    
    /// Adiciona limite
    func limit(_ value: Int) -> SupabaseQuery {
        var query = self
        query.limitValue = value
        return query
    }
    
    /// Adiciona range (paginação)
    func range(from start: Int, to end: Int) -> SupabaseQuery {
        var query = self
        query.rangeStart = start
        query.rangeEnd = end
        return query
    }
    
    /// Aplica a query ao query builder do Supabase
    func apply<T>(to builder: T) -> T {
        var result = builder
        
        // Aplicar filtros
        for (column, operation, value) in filters {
            // Converter value para String para compatibilidade
            let stringValue = "\(value)"
            switch operation {
            case "eq":
                result = (result as! PostgrestFilterBuilder).eq(column, value: stringValue) as! T
            case "neq":
                result = (result as! PostgrestFilterBuilder).neq(column, value: stringValue) as! T
            case "gt":
                result = (result as! PostgrestFilterBuilder).gt(column, value: stringValue) as! T
            case "lt":
                result = (result as! PostgrestFilterBuilder).lt(column, value: stringValue) as! T
            default:
                break
            }
        }
        
        // Aplicar ordenação
        if let column = orderColumn {
            result = (result as! PostgrestTransformBuilder).order(column, ascending: !orderDescending) as! T
        }
        
        // Aplicar limite
        if let limit = limitValue {
            result = (result as! PostgrestTransformBuilder).limit(limit) as! T
        }
        
        // Aplicar range
        if let start = rangeStart, let end = rangeEnd {
            result = (result as! PostgrestTransformBuilder).range(from: start, to: end) as! T
        }
        
        return result
    }
    
    // MARK: - Convenience Methods
    
    /// Filtro por user_id
    static func userId(_ id: UUID) -> SupabaseQuery {
        return SupabaseQuery().eq("user_id", value: id.uuidString)
    }
    
    /// Filtro por user_id com ordenação por data
    static func userIdOrderedByDate(_ id: UUID, descending: Bool = true) -> SupabaseQuery {
        return SupabaseQuery()
            .eq("user_id", value: id.uuidString)
            .orderBy("created_at", descending: descending)
    }
}

// MARK: - Realtime Event

enum RealtimeEvent {
    case insert
    case update
    case delete
    case all
    
    var postgresEvent: PostgresChangeEvent {
        switch self {
        case .insert:
            return .insert
        case .update:
            return .update
        case .delete:
            return .delete
        case .all:
            return .all
        }
    }
}

// MARK: - Supabase Error

enum SupabaseError: LocalizedError {
    case notAuthenticated
    case networkError(Error)
    case invalidData
    case notFound
    case permissionDenied
    case offline
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Você precisa estar autenticado"
        case .networkError(let error):
            return "Erro de rede: \(error.localizedDescription)"
        case .invalidData:
            return "Dados inválidos"
        case .notFound:
            return "Registro não encontrado"
        case .permissionDenied:
            return "Permissão negada"
        case .offline:
            return "Você está offline. As alterações serão sincronizadas quando voltar online."
        }
    }
}