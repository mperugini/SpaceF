//
//  SearchArticlesUseCase.swift
//  SpaceF
//
//  Created by Mariano Perugini on 10/06/2025.
//

import Foundation

protocol SearchArticlesUseCaseProtocol {
    func execute(query: String) async throws -> ArticleResponse
}

class SearchArticlesUseCase: SearchArticlesUseCaseProtocol {
    private let repository: ArticleRepositoryProtocol
    private let logger = AppLogger.shared
    
    init(repository: ArticleRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(query: String) async throws -> ArticleResponse {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            let error = AppError.validation(.invalidInput("Query de search"))
            logger.error(error)
            throw error
        }
        
        guard query.count >= 3 else {
            let error = AppError.validation(.invalidInput("Query debe tener al menos 3 caracteres"))
            logger.error(error)
            throw error
        }
        
        return try await repository.fetchArticles(searchQuery: query, limit: 20, offset: 0)
    }
}
