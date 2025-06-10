//
//  RemoteDataSource.swift
//  SpaceF
//
//  Created by Mariano Perugini on 10/06/2025.
//

import Foundation

protocol RemoteDataSourceProtocol {
    func fetchArticles(searchQuery: String?, limit: Int, offset: Int) async throws -> ArticleResponse
    func fetchArticleDetail(id: Int) async throws -> Article
}

class RemoteDataSource: RemoteDataSourceProtocol {
    private let session: URLSession
    private let logger = AppLogger.shared
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true
        config.requestCachePolicy = .returnCacheDataElseLoad
        
        self.session = URLSession(configuration: config)
    }
    
    func fetchArticles(searchQuery: String?, limit: Int, offset: Int) async throws -> ArticleResponse {
        let url = try buildURL(searchQuery: searchQuery, limit: limit, offset: offset)
        
        do {
            let (data, response) = try await session.data(from: url)
            try validateResponse(response)
            
            let decoder = JSONDecoder()
            let articleResponse = try decoder.decode(ArticleResponse.self, from: data)
            
            logger.info("Artículos obtenidos del servidor: \(articleResponse.count)")
            return articleResponse
            
        } catch let error as AppError {
            throw error
        } catch {
            let networkError = AppError.network(.serverError(error.localizedDescription))
            logger.error(networkError)
            throw networkError
        }
    }
    
    func fetchArticleDetail(id: Int) async throws -> Article {
        let urlString = "\(AppConfig.baseURL)/articles/\(id)"
        
        guard let url = URL(string: urlString) else {
            let error = AppError.network(.invalidURL)
            logger.error(error)
            throw error
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            try validateResponse(response)
            
            let decoder = JSONDecoder()
            let article = try decoder.decode(Article.self, from: data)
            
            logger.info("Detalle del artículo obtenido: \(article.id)")
            return article
            
        } catch let error as AppError {
            throw error
        } catch {
            let networkError = AppError.network(.serverError(error.localizedDescription))
            logger.error(networkError)
            throw networkError
        }
    }
    
    // MARK: - Private Methods
    
    private func buildURL(searchQuery: String?, limit: Int, offset: Int) throws -> URL {
        var components = URLComponents(string: "\(AppConfig.baseURL)/articles")
        var queryItems = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset))
        ]
        
        if let query = searchQuery, !query.isEmpty {
            queryItems.append(URLQueryItem(name: "search", value: query))
        }
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            let error = AppError.network(.invalidURL)
            logger.error(error)
            throw error
        }
        
        return url
    }
    
    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            let error = AppError.network(.serverError("Respuesta inválida"))
            logger.error(error)
            throw error
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let error = AppError.network(.serverError("Error del servidor: \(httpResponse.statusCode)"))
            logger.error(error)
            throw error
        }
    }
}
