//
//  LocalDataSource.swift
//  SpaceF
//
//  Created by Mariano Perugini on 10/06/2025.
//

import Foundation

protocol LocalDataSourceProtocol {
    func saveArticles(_ articles: [Article]) async
    func getCachedArticles() async -> [Article]
    func saveSearchText(_ text: String) async
    func getCachedSearchText() async -> String
    func clearCache() async
}

actor LocalDataSource: LocalDataSourceProtocol {
    private let userDefaults = UserDefaults.standard
    private let logger = AppLogger.shared
    
    // Cache keys
    private let articlesKey = "cached_articles"
    private let searchTextKey = "cached_search_text"
    private let timestampKey = "cache_timestamp"
    
    // Cache expiration time (1 hour)
    private let cacheExpirationTime: TimeInterval = 3600
    
    func saveArticles(_ articles: [Article]) async {
        do {
            let data = try JSONEncoder().encode(articles)
            userDefaults.set(data, forKey: articlesKey)
            userDefaults.set(Date().timeIntervalSince1970, forKey: timestampKey)
            
            logger.info("Artículos guardados en cache: \(articles.count)")
        } catch {
            logger.error(AppError.data(.saveFailed))
        }
    }
    
    func getCachedArticles() async -> [Article] {
        // Check if cache is expired
        let timestamp = userDefaults.double(forKey: timestampKey)
        let currentTime = Date().timeIntervalSince1970
        
        if currentTime - timestamp > cacheExpirationTime {
            logger.info("Cache expirado, limpiando datos")
            await clearCache()
            return []
        }
        
        guard let data = userDefaults.data(forKey: articlesKey) else {
            return []
        }
        
        do {
            let articles = try JSONDecoder().decode([Article].self, from: data)
            logger.info("Artículos obtenidos del cache: \(articles.count)")
            return articles
        } catch {
            logger.error(AppError.data(.loadFailed))
            await clearCache() // Clear corrupted cache
            return []
        }
    }
    
    func saveSearchText(_ text: String) async {
        userDefaults.set(text, forKey: searchTextKey)
        logger.debug("Texto de búsqueda guardado: \(text)")
    }
    
    func getCachedSearchText() async -> String {
        return userDefaults.string(forKey: searchTextKey) ?? ""
    }
    
    func clearCache() async {
        userDefaults.removeObject(forKey: articlesKey)
        userDefaults.removeObject(forKey: searchTextKey)
        userDefaults.removeObject(forKey: timestampKey)
        
        logger.info("Cache limpiado completamente")
    }
}
