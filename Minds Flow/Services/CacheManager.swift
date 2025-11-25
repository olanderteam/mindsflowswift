//
//  CacheManager.swift
//  Minds Flow
//
//  Created by Kiro on 18/10/25.
//

import Foundation

/// Gerenciador de cache local para modo offline
/// Armazena dados em UserDefaults (pequenos) e FileManager (grandes)
class CacheManager {
    
    // MARK: - Singleton
    static let shared = CacheManager()
    
    // MARK: - Properties
    private let userDefaults = UserDefaults.standard
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    // MARK: - Cache Keys
    enum CacheKey: String {
        case tasks = "cached_tasks"
        case wisdom = "cached_wisdom"
        case mentalStates = "cached_mental_states"
        case profile = "cached_profile"
        case usageStats = "cached_usage_stats"
        case timelineEvents = "cached_timeline_events"
        case subscription = "cached_subscription"
        
        var fileName: String {
            return "\(self.rawValue).json"
        }
    }
    
    // MARK: - Initialization
    private init() {
        // Create cache directory if it doesn't exist
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.cacheDirectory = cachesDirectory.appendingPathComponent("MindsFlowCache", isDirectory: true)
        
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
            print("✅ Cache directory created at: \(cacheDirectory.path)")
        }
    }
    
    // MARK: - Cache Operations
    
    /// Armazena dados no cache
    /// - Parameters:
    ///   - data: Array de objetos Codable para cachear
    ///   - key: Cache key
    func cache<T: Codable>(_ data: [T], for key: CacheKey) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let encodedData = try encoder.encode(data)
        
        // Para dados pequenos (< 100KB), usar UserDefaults
        if encodedData.count < 100_000 {
            userDefaults.set(encodedData, forKey: key.rawValue)
            print("✅ Cached \(data.count) items in UserDefaults for key: \(key.rawValue)")
        } else {
            // Para dados maiores, usar FileManager
            let fileURL = cacheDirectory.appendingPathComponent(key.fileName)
            try encodedData.write(to: fileURL)
            print("✅ Cached \(data.count) items in file: \(key.fileName)")
        }
    }
    
    /// Retrieves dados do cache
    /// - Parameter key: Cache key
    /// - Returns: Array de objetos ou nil se não encontrado
    func getCached<T: Codable>(for key: CacheKey) throws -> [T]? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // Tentar UserDefaults primeiro
        if let data = userDefaults.data(forKey: key.rawValue) {
            let decoded = try decoder.decode([T].self, from: data)
            print("✅ Retrieved \(decoded.count) items from UserDefaults for key: \(key.rawValue)")
            return decoded
        }
        
        // Tentar FileManager
        let fileURL = cacheDirectory.appendingPathComponent(key.fileName)
        if fileManager.fileExists(atPath: fileURL.path) {
            let data = try Data(contentsOf: fileURL)
            let decoded = try decoder.decode([T].self, from: data)
            print("✅ Retrieved \(decoded.count) items from file: \(key.fileName)")
            return decoded
        }
        
        print("ℹ️ No cache found for key: \(key.rawValue)")
        return nil
    }
    
    /// Armazena um único objeto no cache
    /// - Parameters:
    ///   - object: Objeto Codable para cachear
    ///   - key: Cache key
    func cacheSingle<T: Codable>(_ object: T, for key: CacheKey) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let encodedData = try encoder.encode(object)
        userDefaults.set(encodedData, forKey: key.rawValue)
        print("✅ Cached single object for key: \(key.rawValue)")
    }
    
    /// Retrieves um único objeto do cache
    /// - Parameter key: Cache key
    /// - Returns: Objeto ou nil se não encontrado
    func getCachedSingle<T: Codable>(for key: CacheKey) throws -> T? {
        guard let data = userDefaults.data(forKey: key.rawValue) else {
            print("ℹ️ No cache found for key: \(key.rawValue)")
            return nil
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let decoded = try decoder.decode(T.self, from: data)
        print("✅ Retrieved single object from cache for key: \(key.rawValue)")
        return decoded
    }
    
    /// Clears cache para uma chave específica
    /// - Parameter key: Cache key to be cleared
    func clearCache(for key: CacheKey) {
        // Clear UserDefaults
        userDefaults.removeObject(forKey: key.rawValue)
        
        // Clear file if it exists
        let fileURL = cacheDirectory.appendingPathComponent(key.fileName)
        try? fileManager.removeItem(at: fileURL)
        
        print("✅ Cleared cache for key: \(key.rawValue)")
    }
    
    /// Clears all cache
    func clearAllCache() {
        // Clear all UserDefaults
        for key in CacheKey.allCases {
            userDefaults.removeObject(forKey: key.rawValue)
        }
        
        // Clear cache directory
        if fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.removeItem(at: cacheDirectory)
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
        
        print("✅ Cleared all cache")
    }
    
    /// Returns o tamanho do cache em bytes
    /// - Parameter key: Cache key (opcional, se nil retorna tamanho total)
    /// - Returns: Tamanho em bytes
    func getCacheSize(for key: CacheKey? = nil) -> Int64 {
        var totalSize: Int64 = 0
        
        if let key = key {
            // Tamanho de uma chave específica
            if let data = userDefaults.data(forKey: key.rawValue) {
                totalSize += Int64(data.count)
            }
            
            let fileURL = cacheDirectory.appendingPathComponent(key.fileName)
            if let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path),
               let fileSize = attributes[.size] as? Int64 {
                totalSize += fileSize
            }
        } else {
            // Tamanho total do cache
            if let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) {
                for file in files {
                    if let attributes = try? fileManager.attributesOfItem(atPath: file.path),
                       let fileSize = attributes[.size] as? Int64 {
                        totalSize += fileSize
                    }
                }
            }
        }
        
        return totalSize
    }
    
    /// Returns o tamanho do cache formatado
    /// - Parameter key: Cache key (opcional)
    /// - Returns: String formatada (ex: "1.5 MB")
    func getFormattedCacheSize(for key: CacheKey? = nil) -> String {
        let bytes = getCacheSize(for: key)
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    /// Checks if existe cache para uma chave
    /// - Parameter key: Cache key
    /// - Returns: true se existe cache
    func hasCachedData(for key: CacheKey) -> Bool {
        if userDefaults.data(forKey: key.rawValue) != nil {
            return true
        }
        
        let fileURL = cacheDirectory.appendingPathComponent(key.fileName)
        return fileManager.fileExists(atPath: fileURL.path)
    }
    
    /// Returns a data da última modificação do cache
    /// - Parameter key: Cache key
    /// - Returns: Data da última modificação ou nil
    func getCacheLastModified(for key: CacheKey) -> Date? {
        let fileURL = cacheDirectory.appendingPathComponent(key.fileName)
        
        if let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path),
           let modificationDate = attributes[.modificationDate] as? Date {
            return modificationDate
        }
        
        return nil
    }
    
    /// Checks if o cache está expirado
    /// - Parameters:
    ///   - key: Cache key
    ///   - expirationTime: Expiration time in seconds (default: 5 minutos)
    /// - Returns: true se o cache está expirado
    func isCacheExpired(for key: CacheKey, expirationTime: TimeInterval = 300) -> Bool {
        guard let lastModified = getCacheLastModified(for: key) else {
            return true // Se não tem data, considerar expirado
        }
        
        let now = Date()
        let timeSinceModification = now.timeIntervalSince(lastModified)
        
        return timeSinceModification > expirationTime
    }
}

// MARK: - CacheKey Extension

extension CacheManager.CacheKey: CaseIterable {}
