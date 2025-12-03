//
//  SyncManager.swift
//  Minds Flow
//
//  Created by Kiro on 18/10/25.
//

import Foundation
import Supabase

/// Gerenciador de sincronização para operações offline
/// Enfileira operações quando offline e sincroniza quando voltar online
@MainActor
class SyncManager: ObservableObject {
    
    // MARK: - Properties
    @Published var isSyncing = false
    @Published var pendingOperationsCount = 0
    @Published var lastSyncDate: Date?
    @Published var syncErrors: [SyncError] = []
    
    private let supabase: SupabaseClient
    private var syncQueue: [SyncOperation] = []
    private let queueKey = "sync_queue"
    
    // MARK: - Initialization
    init(supabase: SupabaseClient) {
        self.supabase = supabase
        loadQueue()
    }
    
    // MARK: - Queue Management
    
    /// Adiciona operação à fila de sincronização
    /// - Parameter operation: Operação a ser enfileirada
    func queueOperation(_ operation: SyncOperation) {
        syncQueue.append(operation)
        pendingOperationsCount = syncQueue.count
        saveQueue()
        
        print("📝 Queued operation: \(operation.type.rawValue) on \(operation.table)")
    }
    
    /// Carrega fila de operações do armazenamento persistente
    private func loadQueue() {
        guard let data = UserDefaults.standard.data(forKey: queueKey) else {
            print("ℹ️ No pending operations in queue")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            syncQueue = try decoder.decode([SyncOperation].self, from: data)
            pendingOperationsCount = syncQueue.count
            print("✅ Loaded \(syncQueue.count) pending operations from queue")
        } catch {
            print("❌ Failed to load sync queue: \(error)")
            syncQueue = []
        }
    }
    
    /// Saves fila de operações no armazenamento persistente
    private func saveQueue() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(syncQueue)
            UserDefaults.standard.set(data, forKey: queueKey)
        } catch {
            print("❌ Failed to save sync queue: \(error)")
        }
    }
    
    /// Limpa a fila de sincronização
    func clearQueue() {
        syncQueue.removeAll()
        pendingOperationsCount = 0
        UserDefaults.standard.removeObject(forKey: queueKey)
        print("✅ Sync queue cleared")
    }
    
    // MARK: - Sync Operations
    
    /// Sincroniza todas as operações pendentes
    /// - Returns: Número de operações sincronizadas com sucesso
    @discardableResult
    func syncPendingOperations() async throws -> Int {
        guard !syncQueue.isEmpty else {
            print("ℹ️ No pending operations to sync")
            return 0
        }
        
        isSyncing = true
        syncErrors.removeAll()
        
        var successCount = 0
        var failedOperations: [SyncOperation] = []
        
        print("🔄 Starting sync of \(syncQueue.count) operations...")
        
        for operation in syncQueue {
            do {
                try await executeOperation(operation)
                successCount += 1
                print("✅ Synced: \(operation.type.rawValue) on \(operation.table)")
            } catch {
                print("❌ Failed to sync operation: \(error)")
                failedOperations.append(operation)
                syncErrors.append(SyncError(operation: operation, error: error))
            }
        }
        
        // Keep only failed operations in queue
        syncQueue = failedOperations
        pendingOperationsCount = syncQueue.count
        saveQueue()
        
        lastSyncDate = Date()
        isSyncing = false
        
        print("✅ Sync completed: \(successCount) successful, \(failedOperations.count) failed")
        
        return successCount
    }
    
    /// Executa uma operação específica
    /// - Parameter operation: Operação a ser executada
    private func executeOperation(_ operation: SyncOperation) async throws {
        switch operation.type {
        case .insert:
            try await executeInsert(operation)
        case .update:
            try await executeUpdate(operation)
        case .delete:
            try await executeDelete(operation)
        }
    }
    
    /// Executa operação de inserção
    private func executeInsert(_ operation: SyncOperation) async throws {
        try await supabase
            .from(operation.table)
            .insert(operation.data)
            .execute()
    }
    
    /// Executa operação de atualização
    private func executeUpdate(_ operation: SyncOperation) async throws {
        guard let id = operation.recordId else {
            throw SyncManagerError.missingRecordId
        }
        
        try await supabase
            .from(operation.table)
            .update(operation.data)
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    /// Executa operação de deleção
    private func executeDelete(_ operation: SyncOperation) async throws {
        guard let id = operation.recordId else {
            throw SyncManagerError.missingRecordId
        }
        
        try await supabase
            .from(operation.table)
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    // MARK: - Conflict Resolution
    
    /// Resolve conflito entre dados locais e remotos
    /// - Parameters:
    ///   - local: Dados locais
    ///   - remote: Dados remotos
    ///   - strategy: Estratégia de resolução
    /// - Returns: Dados resolvidos
    func resolveConflict<T: Codable & Timestamped>(
        local: T,
        remote: T,
        strategy: ConflictStrategy
    ) -> T {
        switch strategy {
        case .localWins:
            print("🔀 Conflict resolved: Local wins")
            return local
            
        case .remoteWins:
            print("🔀 Conflict resolved: Remote wins")
            return remote
            
        case .mostRecent:
            let localIsNewer = local.updatedAt > remote.updatedAt
            print("🔀 Conflict resolved: \(localIsNewer ? "Local" : "Remote") is more recent")
            return localIsNewer ? local : remote
            
        case .merge:
            // Para merge, preferir dados mais recentes campo por campo
            // Por simplicidade, usar mostRecent
            print("🔀 Conflict resolved: Using most recent (merge not fully implemented)")
            return local.updatedAt > remote.updatedAt ? local : remote
        }
    }
    
    // MARK: - Retry Logic
    
    /// Tries to sync failed operations again
    func retryFailedOperations() async throws {
        guard !syncErrors.isEmpty else {
            print("ℹ️ No failed operations to retry")
            return
        }
        
        print("🔄 Retrying \(syncErrors.count) failed operations...")
        
        // Add failed operations back to queue
        for error in syncErrors {
            if !syncQueue.contains(where: { $0.id == error.operation.id }) {
                syncQueue.append(error.operation)
            }
        }
        
        syncErrors.removeAll()
        pendingOperationsCount = syncQueue.count
        saveQueue()
        
        // Try to sync again
        try await syncPendingOperations()
    }
}

// MARK: - Supporting Types

/// Operação de sincronização
struct SyncOperation: Codable, Identifiable {
    let id: UUID
    let type: OperationType
    let table: String
    let data: Data
    let recordId: UUID?
    let timestamp: Date
    
    enum OperationType: String, Codable {
        case insert
        case update
        case delete
    }
    
    init(id: UUID = UUID(), type: OperationType, table: String, data: Data, recordId: UUID? = nil, timestamp: Date = Date()) {
        self.id = id
        self.type = type
        self.table = table
        self.data = data
        self.recordId = recordId
        self.timestamp = timestamp
    }
}

/// Estratégia de resolução de conflitos
enum ConflictStrategy {
    case localWins      // Dados locais têm prioridade
    case remoteWins     // Remote data has priority
    case mostRecent     // Most recent data has priority
    case merge          // Try to merge data
}

/// Erro de sincronização
struct SyncError: Identifiable {
    let id = UUID()
    let operation: SyncOperation
    let error: Error
    let timestamp = Date()
    
    var description: String {
        return "\(operation.type.rawValue) on \(operation.table): \(error.localizedDescription)"
    }
}

/// Erro do SyncManager
enum SyncManagerError: LocalizedError {
    case missingRecordId
    case invalidData
    case syncFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .missingRecordId:
            return "Record ID is required for update/delete operations"
        case .invalidData:
            return "Invalid data format"
        case .syncFailed(let message):
            return "Sync failed: \(message)"
        }
    }
}

/// Protocol para objetos com timestamp
protocol Timestamped {
    var updatedAt: Date { get }
}

// MARK: - Helper Extensions

extension SyncManager {
    
    /// Cria operação de inserção
    /// - Parameters:
    ///   - object: Object to be inserted
    ///   - table: Table name
    /// - Returns: SyncOperation
    func createInsertOperation<T: Codable>(_ object: T, in table: String) throws -> SyncOperation {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(object)
        
        return SyncOperation(
            type: .insert,
            table: table,
            data: data
        )
    }
    
    /// Cria operação de atualização
    /// - Parameters:
    ///   - object: Object to be updated
    ///   - table: Table name
    ///   - id: Record ID
    /// - Returns: SyncOperation
    func createUpdateOperation<T: Codable>(_ object: T, in table: String, id: UUID) throws -> SyncOperation {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(object)
        
        return SyncOperation(
            type: .update,
            table: table,
            data: data,
            recordId: id
        )
    }
    
    /// Creates deletion operation
    /// - Parameters:
    ///   - id: ID of record to be deleted
    ///   - table: Table name
    /// - Returns: SyncOperation
    func createDeleteOperation(id: UUID, from table: String) -> SyncOperation {
        return SyncOperation(
            type: .delete,
            table: table,
            data: Data(),
            recordId: id
        )
    }
}
