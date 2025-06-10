//
//  ViewModelTests.swift
//  SpaceFTests
//
//  Created by Mariano Perugini on 10/06/2025.
//

import XCTest
@testable import SpaceF

final class ArticleListViewModelTests: XCTestCase {
    var viewModel: ArticleListViewModel!
    var mockFetchUseCase: MockFetchArticlesUseCase!
    var mockSearchUseCase: MockSearchArticlesUseCase!
    var mockLocalDataSource: MockLocalDataSource!
    
    @MainActor
    override func setUpWithError() throws {
        mockFetchUseCase = MockFetchArticlesUseCase()
        mockSearchUseCase = MockSearchArticlesUseCase()
        mockLocalDataSource = MockLocalDataSource()
        
        viewModel = ArticleListViewModel(
            fetchArticlesUseCase: mockFetchUseCase,
            searchArticlesUseCase: mockSearchUseCase,
            localDataSource: mockLocalDataSource
        )
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        mockFetchUseCase = nil
        mockSearchUseCase = nil
        mockLocalDataSource = nil
    }
    
    @MainActor
    func testFetchArticlesSuccess() async throws {
        // Given
        let mockResponse = ArticleResponse.mockResponse(articleCount: 3)
        mockFetchUseCase.mockResponse = mockResponse
        
        // When
        await viewModel.fetchArticles()
        
        // Then
        XCTAssertEqual(viewModel.articles.count, 3)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    @MainActor
    func testFetchArticlesFailure() async throws {
        // Given
        mockFetchUseCase.shouldThrowError = true
        
        // When
        await viewModel.fetchArticles()
        
        // Then
        XCTAssertTrue(viewModel.articles.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    @MainActor
    func testSearchArticlesSuccess() async throws {
        // Given
        let mockResponse = ArticleResponse.mockResponse(articleCount: 2)
        mockSearchUseCase.mockResponse = mockResponse
        viewModel.searchText = "test query"
        
        // When
        await viewModel.fetchArticles()
        
        // Then
        XCTAssertEqual(viewModel.articles.count, 2)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    @MainActor
    func testSearchArticlesWithEmptyQuery() async throws {
        // Given
        viewModel.searchText = ""
        
        // When
        viewModel.searchArticles()
        
        // Then
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    @MainActor
    func testLoadingStateWithoutTimming() async throws {
        XCTAssertFalse(viewModel.isLoading) // Initial state
        await viewModel.fetchArticles()
        XCTAssertFalse(viewModel.isLoading) // Final state
    }
    
    @MainActor
    func testCacheInteraction() async throws {
        // Given
        let mockArticles = Article.mockArticles(count: 2)
        await mockLocalDataSource.saveArticles(mockArticles)
        
        // When - Create new ViewModel (simulates app restart)
        let newViewModel = ArticleListViewModel(
            fetchArticlesUseCase: mockFetchUseCase,
            searchArticlesUseCase: mockSearchUseCase,
            localDataSource: mockLocalDataSource
        )
        
        // Wait a bit for async initialization
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        XCTAssertEqual(newViewModel.articles.count, 2)
    }
}
