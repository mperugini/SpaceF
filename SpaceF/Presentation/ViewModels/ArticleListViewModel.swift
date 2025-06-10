//
//  ArticleListViewModel.swift
//  SpaceF
//
//  Created by Mariano Perugini on 04/06/2025.
//

import Foundation
import SwiftUI

@MainActor
class ArticleListViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var hasMorePages = true
    
    private let fetchArticlesUseCase: FetchArticlesUseCaseProtocol
    private let searchArticlesUseCase: SearchArticlesUseCaseProtocol
    private let localDataSource: LocalDataSourceProtocol
    private let logger = AppLogger.shared
    
    // Pagination state
    private var currentOffset = 0
    private let pageSize = AppConfig.defaultLimit
    private var isSearchMode = false
    
    init(
        fetchArticlesUseCase: FetchArticlesUseCaseProtocol = DependencyContainer.shared.resolve(),
        searchArticlesUseCase: SearchArticlesUseCaseProtocol = DependencyContainer.shared.resolve(),
        localDataSource: LocalDataSourceProtocol = DependencyContainer.shared.resolve()
    ) {
        self.fetchArticlesUseCase = fetchArticlesUseCase
        self.searchArticlesUseCase = searchArticlesUseCase
        self.localDataSource = localDataSource
        
        Task {
            await loadInitialState()
        }
    }
    
    func fetchArticles() async {
        isLoading = true
        errorMessage = nil
        
        // Reset pagination for new search
        currentOffset = 0
        hasMorePages = true
        isSearchMode = !searchText.isEmpty
        
        do {
            let response: ArticleResponse
            
            if searchText.isEmpty {
                response = try await fetchArticlesUseCase.execute(
                    searchQuery: nil,
                    limit: pageSize,
                    offset: currentOffset
                )
            } else {
                response = try await searchArticlesUseCase.execute(query: searchText)
            }
            
            articles = response.results
            currentOffset = response.results.count
            hasMorePages = response.next != nil
            
            // Save state in background
            Task.detached { [weak self] in
                guard let self = self else { return }
                await self.localDataSource.saveArticles(response.results)
                await self.localDataSource.saveSearchText(await self.searchText)
            }
            
            logger.info("Artículos cargados exitosamente: \(articles.count)")
            
        } catch let error as AppError {
            errorMessage = error.localizedDescription
            logger.error(error)
        } catch {
            let unexpectedError = AppError.unexpected(error.localizedDescription)
            errorMessage = unexpectedError.localizedDescription
            logger.error(unexpectedError)
        }
        
        isLoading = false
    }
    
    func loadMoreArticles() async {
        // No cargar mas si estamos en modo busqueda, ya cargando, o no hay mas paginas
        guard !isSearchMode && !isLoading && hasMorePages else { return }
        
        isLoading = true
        
        do {
            let response = try await fetchArticlesUseCase.execute(
                searchQuery: nil,
                limit: pageSize,
                offset: currentOffset
            )
            
            // Append new articles to existing ones
            articles.append(contentsOf: response.results)
            currentOffset += response.results.count
            hasMorePages = response.next != nil
            
            logger.info("Más artículos cargados: \(response.results.count). Total: \(articles.count)")
            
        } catch let error as AppError {
            errorMessage = error.localizedDescription
            logger.error(error)
        } catch {
            let unexpectedError = AppError.unexpected(error.localizedDescription)
            errorMessage = unexpectedError.localizedDescription
            logger.error(unexpectedError)
        }
        
        isLoading = false
    }
    
    func searchArticles() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = AppError.validation(.invalidInput("Búsqueda")).localizedDescription
            return
        }
        
        // Reset pagination for search
        currentOffset = 0
        hasMorePages = true
        
        Task {
            await fetchArticles()
        }
    }
    
    func retry() {
        Task {
            await fetchArticles()
        }
    }
    
    func refreshArticles() async {
        // Reset pagination and fetch fresh data
        currentOffset = 0
        hasMorePages = true
        await fetchArticles()
    }
    
    func clearCache() {
        Task {
            await localDataSource.clearCache()
        }
    }
    
    // MARK: - Private Methods
    
    private func loadInitialState() async {
        let cachedArticles = await localDataSource.getCachedArticles()
        let cachedSearchText = await localDataSource.getCachedSearchText()
        
        articles = cachedArticles
        searchText = cachedSearchText
        
        // If no cached articles, fetch from network
        if cachedArticles.isEmpty {
            await fetchArticles()
        }
    }
}
