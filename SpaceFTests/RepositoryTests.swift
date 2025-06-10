//
//  RepositoryTests.swift
//  SpaceFTests
//
//  Created by Mariano Perugini on 10/06/2025.
//

import XCTest
@testable import SpaceF

final class RepositoryTests: XCTestCase {
    var repository: ArticleRepository!
    var mockRemoteDataSource: MockRemoteDataSource!
    var mockLocalDataSource: MockLocalDataSource!
    
    override func setUpWithError() throws {
        mockRemoteDataSource = MockRemoteDataSource()
        mockLocalDataSource = MockLocalDataSource()
        repository = ArticleRepository(
            remoteDataSource: mockRemoteDataSource,
            localDataSource: mockLocalDataSource
        )
    }
    
    override func tearDownWithError() throws {
        repository = nil
        mockRemoteDataSource = nil
        mockLocalDataSource = nil
    }
    
    func testFetchArticlesFromRemoteSuccess() async throws {
        // Given
        let mockResponse = ArticleResponse.mockResponse(articleCount: 3)
        mockRemoteDataSource.mockResponse = mockResponse
        
        // When
        let result = try await repository.fetchArticles(searchQuery: nil, limit: 10, offset: 0)
        
        // Then
        XCTAssertEqual(result.results.count, 3)
        
        // Verify articles are cached locally
        let cachedArticles = await mockLocalDataSource.getCachedArticles()
        XCTAssertEqual(cachedArticles.count, 3)
    }
    
    func testFetchArticlesRemoteFailureFallbackToCache() async throws {
        // Given
        let cachedArticles = Article.mockArticles(count: 2)
        await mockLocalDataSource.saveArticles(cachedArticles)
        mockRemoteDataSource.shouldThrowError = true
        
        // When
        let result = try await repository.fetchArticles(searchQuery: nil, limit: 10, offset: 0)
        
        // Then
        XCTAssertEqual(result.results.count, 2)
        XCTAssertEqual(result.results.first?.id, cachedArticles.first?.id)
    }
    
    func testFetchArticlesRemoteFailureNoCache() async throws {
        // Given
        mockRemoteDataSource.shouldThrowError = true
        // No cached articles
        
        // When & Then
        do {
            _ = try await repository.fetchArticles(searchQuery: nil, limit: 10, offset: 0)
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }
    
    func testFetchArticleDetail() async throws {
        // Given
        let mockArticle = Article.mockArticle(id: 123)
        mockRemoteDataSource.mockArticle = mockArticle
        
        // When
        let result = try await repository.fetchArticleDetail(id: 123)
        
        // Then
        XCTAssertEqual(result.id, 123)
        XCTAssertEqual(result.title, mockArticle.title)
    }
}

// MARK: - Mock Remote Data Source for Testing
class MockRemoteDataSource: RemoteDataSourceProtocol {
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
}
