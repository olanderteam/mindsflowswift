//
//  NetworkMonitor.swift
//  Minds Flow
//
//  Created by Kiro on 18/10/25.
//

import Foundation
import Network

/// Monitor de conectividade de rede
/// Detecta mudanças no status da conexão e notifica observers
@MainActor
class NetworkMonitor: ObservableObject {
    
    // MARK: - Singleton
    static let shared = NetworkMonitor()
    
    // MARK: - Properties
    @Published var isConnected = true
    @Published var connectionType: ConnectionType = .unknown
    @Published var lastStatusChange: Date?
    
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    // MARK: - Connection Type
    enum ConnectionType {
        case wifi
        case cellular
        case wired
        case unknown
        
        var description: String {
            switch self {
            case .wifi:
                return "Wi-Fi"
            case .cellular:
                return "Celular"
            case .wired:
                return "Ethernet"
            case .unknown:
                return "Desconhecido"
            }
        }
        
        var icon: String {
            switch self {
            case .wifi:
                return "wifi"
            case .cellular:
                return "antenna.radiowaves.left.and.right"
            case .wired:
                return "cable.connector"
            case .unknown:
                return "network.slash"
            }
        }
    }
    
    // MARK: - Initialization
    private init() {
        monitor = NWPathMonitor()
        startMonitoring()
    }
    
    // MARK: - Monitoring
    
    /// Inicia o monitoramento de rede
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            _Concurrency.Task { @MainActor in
                guard let self = self else { return }
                
                let wasConnected = self.isConnected
                self.isConnected = path.status == .satisfied
                self.lastStatusChange = Date()
                
                // Determinar tipo de conexão
                if path.usesInterfaceType(.wifi) {
                    self.connectionType = .wifi
                } else if path.usesInterfaceType(.cellular) {
                    self.connectionType = .cellular
                } else if path.usesInterfaceType(.wiredEthernet) {
                    self.connectionType = .wired
                } else {
                    self.connectionType = .unknown
                }
                
                // Log mudanças de status
                if wasConnected != self.isConnected {
                    if self.isConnected {
                        print("✅ Network connected via \(self.connectionType.description)")
                        await self.handleConnectionRestored()
                    } else {
                        print("❌ Network disconnected")
                        await self.handleConnectionLost()
                    }
                }
            }
        }
        
        monitor.start(queue: queue)
        print("🔍 Network monitoring started")
    }
    
    /// Para o monitoramento de rede
    func stopMonitoring() {
        monitor.cancel()
        print("🛑 Network monitoring stopped")
    }
    
    // MARK: - Connection Handlers
    
    /// Chamado quando a conexão é restaurada
    private func handleConnectionRestored() async {
        // Notificar SupabaseManager
        SupabaseManager.shared.isOnline = true
        await SupabaseManager.shared.checkConnection()
        
        // Tentar sincronizar operações pendentes
        let syncManager = SyncManager(supabase: SupabaseManager.shared.supabase)
        
        if syncManager.pendingOperationsCount > 0 {
            print("🔄 Attempting to sync \(syncManager.pendingOperationsCount) pending operations...")
            
            do {
                let synced = try await syncManager.syncPendingOperations()
                print("✅ Successfully synced \(synced) operations")
            } catch {
                print("❌ Failed to sync operations: \(error)")
            }
        }
    }
    
    /// Chamado quando a conexão é perdida
    private func handleConnectionLost() async {
        // Notificar SupabaseManager
        SupabaseManager.shared.isOnline = false
        SupabaseManager.shared.connectionStatus = .disconnected
    }
    
    // MARK: - Helper Methods
    
    /// Verifica se há conexão com a internet
    /// - Returns: true se conectado
    func checkConnection() -> Bool {
        return isConnected
    }
    
    /// Retorna descrição do status atual
    var statusDescription: String {
        if isConnected {
            return "Conectado via \(connectionType.description)"
        } else {
            return "Sem conexão"
        }
    }
    
    /// Retorna ícone do status atual
    var statusIcon: String {
        if isConnected {
            return connectionType.icon
        } else {
            return "wifi.slash"
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let networkStatusChanged = Notification.Name("networkStatusChanged")
    static let networkConnected = Notification.Name("networkConnected")
    static let networkDisconnected = Notification.Name("networkDisconnected")
}
