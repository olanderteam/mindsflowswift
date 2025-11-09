//
//  NetworkMonitor.swift
//  Minds Flow
//
//  Created by Kiro on 18/10/25.
//

import Foundation
import Network

/// Network connectivity monitor
/// Detects changes in connection status and notifies observers
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
                return "Cellular"
            case .wired:
                return "Ethernet"
            case .unknown:
                return "Unknown"
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
    
    /// Starts network monitoring
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            _Concurrency.Task { @MainActor in
                guard let self = self else { return }
                
                let wasConnected = self.isConnected
                self.isConnected = path.status == .satisfied
                self.lastStatusChange = Date()
                
                // Determine connection type
                if path.usesInterfaceType(.wifi) {
                    self.connectionType = .wifi
                } else if path.usesInterfaceType(.cellular) {
                    self.connectionType = .cellular
                } else if path.usesInterfaceType(.wiredEthernet) {
                    self.connectionType = .wired
                } else {
                    self.connectionType = .unknown
                }
                
                // Log status changes
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
    
    /// Stops network monitoring
    func stopMonitoring() {
        monitor.cancel()
        print("🛑 Network monitoring stopped")
    }
    
    // MARK: - Connection Handlers
    
    /// Called when connection is restored
    private func handleConnectionRestored() async {
        // Notify SupabaseManager
        SupabaseManager.shared.isOnline = true
        await SupabaseManager.shared.checkConnection()
        
        // Try to sync pending operations
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
    
    /// Called when connection is lost
    private func handleConnectionLost() async {
        // Notify SupabaseManager
        SupabaseManager.shared.isOnline = false
        SupabaseManager.shared.connectionStatus = .disconnected
    }
    
    // MARK: - Helper Methods
    
    /// Checks if there's internet connection
    /// - Returns: true if connected
    func checkConnection() -> Bool {
        return isConnected
    }
    
    /// Returns current status description
    var statusDescription: String {
        if isConnected {
            return "Connected via \(connectionType.description)"
        } else {
            return "No connection"
        }
    }
    
    /// Returns current status icon
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
