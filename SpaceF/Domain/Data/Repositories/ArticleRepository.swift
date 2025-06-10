//
//  ArticleRepository.swift
//  SpaceF
//
//  Created by Mariano Perugini on 10/06/2025.
//

import Foundation

class ArticleRepository: ArticleRepositoryProtocol {
    private let remoteDataSource: RemoteDataSourceProtocol
    private let localDataSource: LocalDataSourceProtocol
    private let logger = AppLogger.shared
    
    init(
        remoteDataSource: RemoteDataSourceProtocol = RemoteDataSource(),
        localDataSource: LocalDataSourceProtocol = LocalDataSource()
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }
    
    func fetchArticles(searchQuery: String?, limit: Int, offset: Int) async throws -> ArticleResponse {
        do {
            // Intentar obtener datos remotos
            let response = try await remoteDataSource.fetchArticles(
                searchQuery: searchQuery,
                limit: limit,
                offset: offset
            )
            
            // Guardar en cache local
            await localDataSource.saveArticles(response.results)
            
            logger.info("Artículos obtenidos del servidor: \(response.results.count)")
            return response
            
        } catch {
            // Si falla la red, intentar obtener del cache local
            logger.error(error)
            
            let cachedArticles = await localDataSource.getCachedArticles()
            if !cachedArticles.isEmpty {
                logger.info("Usando artículos del cache: \(cachedArticles.count)")
                return ArticleResponse(
                    count: cachedArticles.count,
                    next: nil,
                    previous: nil,
                    results: cachedArticles
                )
            }
            
            throw error
        }
    }
    
    func fetchArticleDetail(id: Int) async throws -> Article {
        return try await remoteDataSource.fetchArticleDetail(id: id)
    }
    
    func getCachedArticles() async -> [Article] {
        return await localDataSource.getCachedArticles()
    }
    
    func clearCache() async {
        await localDataSource.clearCache()
    }
}
