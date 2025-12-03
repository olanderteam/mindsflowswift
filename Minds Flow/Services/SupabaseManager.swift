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

/// Manager for Supabase integration
/// Manages authentication and database operations
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
                return "Connected"
            case .connecting:
                return "Connecting..."
            case .disconnected:
                return "Disconnected"
            case .error(let message):
                return "Error: \(message)"
            }
        }
    }
    
    // MARK: - Initialization
    private init() {
        // Validate configuration
        guard SupabaseConfig.validate() else {
            fatalError("Invalid Supabase configuration")
        }
        
        // Initialize Supabase client with real credentials
        self.supabase = SupabaseClient(
            supabaseURL: SupabaseConfig.url,
            supabaseKey: SupabaseConfig.key
        )
        
        print("✅ SupabaseManager initialized with project: \(SupabaseConfig.projectURL)")
        
        // Start network monitoring
        _ = NetworkMonitor.shared
        
        // Check connection and authentication status
        _Concurrency.Task {
            await checkConnection()
            await checkAuthStatus()
        }
    }
    
    // MARK: - Connection Management
    
    /// Checks connection with Supabase
    func checkConnection() async {
        connectionStatus = .connecting
        
        do {
            // Try a simple query to verify connection
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
    
    /// Checks authentication status
    func checkAuthStatus() async {
        do {
            // Check if there's an active session in Supabase
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
    
    /// Current user ID (uses AuthManager as source of truth)
    var currentUserId: String? {
        return AuthManager.shared.currentUser?.id.uuidString
    }
    
    /// Current user (uses AuthManager as source of truth)
    var authenticatedUser: User? {
        return AuthManager.shared.currentUser
    }
    
    // MARK: - Generic CRUD Operations
    
    /// Fetches data from database with optional query
    /// - Parameters:
    ///   - table: Table name
    ///   - query: Optional query for filters
    /// - Returns: Array of objects of specified type
    func fetch<T: Codable>(
        from table: String,
        query: SupabaseQuery? = nil
    ) async throws -> [T] {
        guard isOnline else {
            throw SupabaseError.offline
        }
        
        var queryBuilder = supabase.from(table).select()
        
        // Apply filters if there's a query
        if let query = query {
            queryBuilder = query.apply(to: queryBuilder)
        }
        
        let response: [T] = try await queryBuilder.execute().value
        
        print("✅ Fetched \(response.count) items from \(table)")
        return response
    }
    
    /// Fetches a single record
    /// - Parameters:
    ///   - table: Table name
    ///   - id: Record ID
    /// - Returns: Object of specified type
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
    
    /// Inserts data into database
    /// - Parameters:
    ///   - data: Data to be inserted
    ///   - table: Table name
    /// - Returns: Inserted data with generated ID
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
    
    /// Inserts multiple records
    /// - Parameters:
    ///   - data: Array of data to be inserted
    ///   - table: Table name
    /// - Returns: Array of inserted data
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
    
    /// Updates data in database
    /// - Parameters:
    ///   - data: Updated data
    ///   - table: Table name
    ///   - id: Record ID
    /// - Returns: Updated data
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
    
    /// Deletes data from database
    /// - Parameters:
    ///   - table: Table name
    ///   - id: Record ID
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
    
    /// Deletes multiple records with filter
    /// - Parameters:
    ///   - table: Table name
    ///   - query: Query to filter records to delete
    func deleteMany(from table: String, query: SupabaseQuery) async throws {
        guard isOnline else {
            throw SupabaseError.offline
        }
        
        var queryBuilder = supabase.from(table).delete()
        queryBuilder = query.apply(to: queryBuilder)
        
        try await queryBuilder.execute()
        
        print("✅ Deleted items from \(table)")
    }
    
    /// Counts records in table
    /// - Parameters:
    ///   - table: Table name
    ///   - query: Optional query for filters
    /// - Returns: Number of records
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
    
    /// Subscribes to changes in a table
    /// - Parameters:
    ///   - table: Table name
    ///   - event: Event type (insert, update, delete, *)
    ///   - filter: Optional filter (e.g. "user_id=eq.123")
    ///   - onChange: Callback called when there are changes
    /// - Returns: Realtime channel to manage subscription
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
    
    /// Cancels subscription from a channel
    /// - Parameter channel: Channel to be cancelled
    func unsubscribe(from channel: RealtimeChannelV2) async {
        await channel.unsubscribe()
        print("✅ Unsubscribed from realtime channel")
    }
}

// MARK: - Supabase Query Builder

/// Query builder for Supabase
struct SupabaseQuery {
    private var filters: [(String, String, Any)] = []
    private var orderColumn: String?
    private var orderDescending: Bool = false
    private var limitValue: Int?
    private var rangeStart: Int?
    private var rangeEnd: Int?
    
    /// Adds equality filter
    func eq(_ column: String, value: Any) -> SupabaseQuery {
        var query = self
        query.filters.append((column, "eq", value))
        return query
    }
    
    /// Adds inequality filter
    func neq(_ column: String, value: Any) -> SupabaseQuery {
        var query = self
        query.filters.append((column, "neq", value))
        return query
    }
    
    /// Adds greater than filter
    func gt(_ column: String, value: Any) -> SupabaseQuery {
        var query = self
        query.filters.append((column, "gt", value))
        return query
    }
    
    /// Adds less than filter
    func lt(_ column: String, value: Any) -> SupabaseQuery {
        var query = self
        query.filters.append((column, "lt", value))
        return query
    }
    
    /// Adds ordering
    func orderBy(_ column: String, descending: Bool = false) -> SupabaseQuery {
        var query = self
        query.orderColumn = column
        query.orderDescending = descending
        return query
    }
    
    /// Adds limit
    func limit(_ value: Int) -> SupabaseQuery {
        var query = self
        query.limitValue = value
        return query
    }
    
    /// Adds range (pagination)
    func range(from start: Int, to end: Int) -> SupabaseQuery {
        var query = self
        query.rangeStart = start
        query.rangeEnd = end
        return query
    }
    
    /// Applies query to Supabase query builder
    func apply<T>(to builder: T) -> T {
        var result = builder
        
        // Apply filters
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
        
        // Apply ordering
        if let column = orderColumn {
            result = (result as! PostgrestTransformBuilder).order(column, ascending: !orderDescending) as! T
        }
        
        // Apply limit
        if let limit = limitValue {
            result = (result as! PostgrestTransformBuilder).limit(limit) as! T
        }
        
        // Apply range
        if let start = rangeStart, let end = rangeEnd {
            result = (result as! PostgrestTransformBuilder).range(from: start, to: end) as! T
        }
        
        return result
    }
    
    // MARK: - Convenience Methods
    
    /// Filter by user_id
    static func userId(_ id: UUID) -> SupabaseQuery {
        return SupabaseQuery().eq("user_id", value: id.uuidString)
    }
    
    /// Filter by user_id with date ordering
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
            return "You need to be authenticated"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidData:
            return "Invalid data"
        case .notFound:
            return "Record not found"
        case .permissionDenied:
            return "Permission denied"
        case .offline:
            return "You are offline. Changes will be synced when you're back online."
        }
    }
}