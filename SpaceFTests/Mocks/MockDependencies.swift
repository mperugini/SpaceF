//
//  MockDependencies.swift
//  SpaceFTests
//
//  Created by Mariano Perugini on 10/06/2025.
//

import Foundation
@testable import SpaceF

// MARK: - Mock Repository
class MockArticleRepository: ArticleRepositoryProtocol {
    var shouldThrowError = false
    var mockResponse: ArticleResponse?
    var mockArticle: Article?
    
    func fetchArticles(searchQuery: String?, limit: Int, offset: Int) async throws -> ArticleResponse {
        if shouldThrowError {
            throw AppError.network(.noData)
        }
        
        return mockResponse ?? ArticleResponse(count: 0, next: nil, previous: nil, results: [])
    }
    
    func fetchArticleDetail(id: Int) async throws -> Article {
        if shouldThrowError {
            throw AppError.network(.noData)
        }
        
        guard let article = mockArticle else {
            throw AppError.network(.noData)
        }
        
        return article
    }
    
    func getCachedArticles() async -> [Article] {
        return mockResponse?.results ?? []
    }
    
    func clearCache() async {
        // Mock implementation
    }
}

// MARK: - Mock Use Cases
class MockFetchArticlesUseCase: FetchArticlesUseCaseProtocol {
    var shouldThrowError = false
    var mockResponse: ArticleResponse?
    
    func execute(searchQuery: String?, limit: Int, offset: Int) async throws -> ArticleResponse {
        if shouldThrowError {
            throw AppError.network(.noData)
        }
        
        return mockResponse ?? ArticleResponse(count: 0, next: nil, previous: nil, results: [])
    }
}

class MockSearchArticlesUseCase: SearchArticlesUseCaseProtocol {
    var shouldThrowError = false
    var mockResponse: ArticleResponse?
    
    func execute(query: String) async throws -> ArticleResponse {
        if shouldThrowError {
            throw AppError.validation(.invalidInput("Test error"))
        }
        
        return mockResponse ?? ArticleResponse(count: 0, next: nil, previous: nil, results: [])
    }
}

// MARK: - Mock Local Data Source
class MockLocalDataSource: LocalDataSourceProtocol {
    private var cachedArticles: [Article] = []
    private var cachedSearchText: String = ""
    
    func saveArticles(_ articles: [Article]) async {
        cachedArticles = articles
    }
    
    func getCachedArticles() async -> [Article] {
        return cachedArticles
    }
    
    func saveSearchText(_ text: String) async {
        cachedSearchText = text
    }
    
    func getCachedSearchText() async -> String {
        return cachedSearchText
    }
    
    func clearCache() async {
        cachedArticles = []
        cachedSearchText = ""
    }
}

// MARK: - Test Data
extension Article {
    static func mockArticle(id: Int = 1) -> Article {
        return Article(
            id: id,
            title: "Test Article \(id)",
            url: "https://test.com/article/\(id)",
            imageUrl: "https://test.com/image/\(id).jpg",
            newsSite: "Test Site",
            summary: "This is a test article summary for article \(id)",
            publishedAt: "2025-06-10T12:00:00Z",
            updatedAt: "2025-06-10T12:00:00Z"
        )
    }
    
    static func mockArticles(count: Int = 3) -> [Article] {
        return (1...count).map { Article.mockArticle(id: $0) }
    }
}

extension ArticleResponse {
    static func mockResponse(articleCount: Int = 3) -> ArticleResponse {
        return ArticleResponse(
            count: articleCount,
            next: nil,
            previous: nil,
            results: Article.mockArticles(count: articleCount)
        )
    }
}
