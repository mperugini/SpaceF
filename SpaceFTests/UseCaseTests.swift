//
//  UseCaseTests.swift
//  SpaceFTests
//
//  Created by Mariano Perugini on 10/06/2025.
//

import XCTest
@testable import SpaceF

final class UseCaseTests: XCTestCase {
    var mockRepository: MockArticleRepository!
    
    override func setUpWithError() throws {
        mockRepository = MockArticleRepository()
    }
    
    override func tearDownWithError() throws {
        mockRepository = nil
    }
    
    // MARK: - FetchArticlesUseCase Tests
    
    func testFetchArticlesUseCaseSuccess() async throws {
        // Given
        let useCase = FetchArticlesUseCase(repository: mockRepository)
        let mockResponse = ArticleResponse.mockResponse(articleCount: 5)
        mockRepository.mockResponse = mockResponse
        
        // When
        let result = try await useCase.execute(searchQuery: nil, limit: 10, offset: 0)
        
        // Then
        XCTAssertEqual(result.results.count, 5)
        XCTAssertEqual(result.count, 5)
    }
    
    func testFetchArticlesUseCaseFailure() async throws {
        // Given
        let useCase = FetchArticlesUseCase(repository: mockRepository)
        mockRepository.shouldThrowError = true
        
        // When & Then
        do {
            _ = try await useCase.execute()
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }
    
    // MARK: - SearchArticlesUseCase Tests
    
    func testSearchArticlesUseCaseSuccess() async throws {
        // Given
        let useCase = SearchArticlesUseCase(repository: mockRepository)
        let mockResponse = ArticleResponse.mockResponse(articleCount: 3)
        mockRepository.mockResponse = mockResponse
        
        // When
        let result = try await useCase.execute(query: "space exploration")
        
        // Then
        XCTAssertEqual(result.results.count, 3)
    }
    
    func testSearchArticlesUseCaseEmptyQuery() async throws {
        // Given
        let useCase = SearchArticlesUseCase(repository: mockRepository)
        
        // When & Then
        do {
            _ = try await useCase.execute(query: "")
            XCTFail("Should have thrown a validation error")
        } catch let error as AppError {
            switch error {
            case .validation:
                XCTAssertTrue(true) // Expected validation error
            default:
                XCTFail("Should have thrown a validation error")
            }
        }
    }
    
    func testSearchArticlesUseCaseShortQuery() async throws {
        // Given
        let useCase = SearchArticlesUseCase(repository: mockRepository)
        
        // When & Then
        do {
            _ = try await useCase.execute(query: "a") // Only 1 character
            XCTFail("Should have thrown a validation error")
        } catch let error as AppError {
            switch error {
            case .validation:
                XCTAssertTrue(true) // Expected validation error
            default:
                XCTFail("Should have thrown a validation error")
            }
        }
    }
    
    func testSearchArticlesUseCaseWithWhitespace() async throws {
        // Given
        let useCase = SearchArticlesUseCase(repository: mockRepository)
        
        // When & Then
        do {
            _ = try await useCase.execute(query: "   ") // Only whitespace
            XCTFail("Should have thrown a validation error")
        } catch let error as AppError {
            switch error {
            case .validation:
                XCTAssertTrue(true) // Expected validation error
            default:
                XCTFail("Should have thrown a validation error")
            }
        }
    }
}
