//
//  FetchArticlesUseCase.swift
//  SpaceF
//
//  Created by Mariano Perugini on 10/06/2025.
//

import Foundation

protocol FetchArticlesUseCaseProtocol {
    func execute(searchQuery: String?, limit: Int, offset: Int) async throws -> ArticleResponse
}

class FetchArticlesUseCase: FetchArticlesUseCaseProtocol {
    private let repository: ArticleRepositoryProtocol
    
    init(repository: ArticleRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(searchQuery: String? = nil, limit: Int = 10, offset: Int = 0) async throws -> ArticleResponse {
        return try await repository.fetchArticles(searchQuery: searchQuery, limit: limit, offset: offset)
    }
}
