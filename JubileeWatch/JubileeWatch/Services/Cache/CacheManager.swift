import Foundation

class CacheManager {
    static let shared = CacheManager()
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = urls[0].appendingPathComponent("JubileeWatch")
        
        createCacheDirectoryIfNeeded()
    }
    
    func store<T: Codable>(_ object: T, key: String, expirationTime: TimeInterval = 3600) throws {
        let expirationDate = Date().addingTimeInterval(expirationTime)
        let cachedData = CachedData(data: object, timestamp: Date(), expiresAt: expirationDate)
        
        let url = cacheDirectory.appendingPathComponent("\(key).cache")
        let data = try JSONEncoder().encode(cachedData)
        try data.write(to: url)
    }
    
    func fetch<T: Codable>(_ type: T.Type, key: String) throws -> T? {
        let url = cacheDirectory.appendingPathComponent("\(key).cache")
        
        guard fileManager.fileExists(atPath: url.path) else {
            return nil
        }
        
        let data = try Data(contentsOf: url)
        let cachedData = try JSONDecoder().decode(CachedData<T>.self, from: data)
        
        // Check if data is expired
        if cachedData.isExpired {
            try removeCache(for: key)
            return nil
        }
        
        return cachedData.data
    }
    
    func removeCache(for key: String) throws {
        let url = cacheDirectory.appendingPathComponent("\(key).cache")
        
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }
    
    func clearAllCache() throws {
        let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, 
                                                          includingPropertiesForKeys: nil)
        
        for url in contents {
            try fileManager.removeItem(at: url)
        }
    }
    
    func getCacheSize() -> Int64 {
        guard let contents = try? fileManager.contentsOfDirectory(at: cacheDirectory,
                                                                 includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        
        return contents.reduce(0) { total, url in
            let size = (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
            return total + Int64(size)
        }
    }
    
    func cleanExpiredCache() throws {
        let contents = try fileManager.contentsOfDirectory(at: cacheDirectory,
                                                          includingPropertiesForKeys: nil)
        
        for url in contents {
            do {
                let data = try Data(contentsOf: url)
                
                // Try to decode as a generic cached data to check expiration
                if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let expiresAtString = jsonObject["expiresAt"] as? String {
                    
                    let formatter = ISO8601DateFormatter()
                    if let expiresAt = formatter.date(from: expiresAtString),
                       Date() > expiresAt {
                        try fileManager.removeItem(at: url)
                    }
                }
            } catch {
                // If we can't decode, remove the file
                try fileManager.removeItem(at: url)
            }
        }
    }
    
    private func createCacheDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory,
                                           withIntermediateDirectories: true)
        }
    }
}

enum CacheError: Error, LocalizedError {
    case encodingFailed
    case decodingFailed
    case fileNotFound
    case directoryCreationFailed
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode data for caching"
        case .decodingFailed:
            return "Failed to decode cached data"
        case .fileNotFound:
            return "Cache file not found"
        case .directoryCreationFailed:
            return "Failed to create cache directory"
        }
    }
}