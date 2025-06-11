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
    @Published var searchState: String = "idle"
    @Published var toastMessage: ToastMessage?
    
    private let fetchArticlesUseCase: FetchArticlesUseCaseProtocol
    private let searchArticlesUseCase: SearchArticlesUseCaseProtocol
    private let localDataSource: LocalDataSourceProtocol
    private let logger = AppLogger.shared
    
    // Pagination state
    private var currentOffset = 0
    private let pageSize = AppConfig.defaultLimit
    private var isSearchMode = false
    
    // Backup articles for search cancellation
    private var originalArticles: [Article] = []
    private var originalOffset = 0
    private var originalHasMorePages = true
    
    init(
        fetchArticlesUseCase: FetchArticlesUseCaseProtocol = DependencyContainer.shared.resolve(),
        searchArticlesUseCase: SearchArticlesUseCaseProtocol = DependencyContainer.shared.resolve(),
        localDataSource: LocalDataSourceProtocol = DependencyContainer.shared.resolve()
    ) {
        self.fetchArticlesUseCase = fetchArticlesUseCase
        self.searchArticlesUseCase = searchArticlesUseCase
        self.localDataSource = localDataSource
        
        Task {
            await fetchArticles()
        }
    }
    
    func fetchArticles() async {
        isLoading = true
        errorMessage = nil
        
        // Update search state
        if !searchText.isEmpty {
            searchState = "searching"
            // Save original state before searching
            if !isSearchMode {
                originalArticles = articles
                originalOffset = currentOffset
                originalHasMorePages = hasMorePages
            }
        }
        
        // Reset pagination for new search
        currentOffset = 0
        hasMorePages = true
        isSearchMode = !searchText.isEmpty
        
        do {
            let response: ArticleResponse
            
            if searchText.isEmpty {
                searchState = "idle"
                // If we have original articles, don't make API call, they'll be restored by handleSearchCancellation
                if !originalArticles.isEmpty && isSearchMode {
                    isLoading = false
                    return
                }
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
            
            // Update search state based on results
            if !searchText.isEmpty {
                if response.results.isEmpty {
                    searchState = "empty"
                    showToast("No se encontraron resultados para '\(searchText)'", type: .info)
                } else {
                    searchState = "found:\(response.results.count)"
                    showToast("Se encontraron \(response.results.count) artículos", type: .success)
                }
            }
            
            // Save state in background
            Task.detached { [weak self] in
                guard let self = self else { return }
                await self.localDataSource.saveArticles(response.results)
                await self.localDataSource.saveSearchText(await self.searchText)
            }
            
            logger.info("Artículos cargados exitosamente: \(articles.count)")
            
        } catch let error as AppError {
            errorMessage = error.localizedDescription
            searchState = "idle"
            showToast("Error al cargar artículos", type: .error)
            logger.error(error)
        } catch {
            let unexpectedError = AppError.unexpected(error.localizedDescription)
            errorMessage = unexpectedError.localizedDescription
            searchState = "idle"
            showToast("Error inesperado", type: .error)
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
        
        if !articles.isEmpty {
            showToast("Artículos actualizados", type: .success)
        }
    }
    
    func clearCache() {
        Task {
            await localDataSource.clearCache()
            showToast("Caché limpiado", type: .info)
        }
    }
    
    func handleSearchCancellation() {
        guard isSearchMode && !originalArticles.isEmpty else { return }
        
        // Restore original state
        articles = originalArticles
        currentOffset = originalOffset
        hasMorePages = originalHasMorePages
        isSearchMode = false
        searchState = "idle"
        errorMessage = nil
        
        // Clear backup
        originalArticles = []
        originalOffset = 0
        originalHasMorePages = true
        
        showToast("Búsqueda cancelada", type: .info)
        logger.info("Búsqueda cancelada, artículos originales restaurados: \(articles.count)")
    }
    
    private func showToast(_ message: String, type: ToastType) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            toastMessage = ToastMessage(message: message, type: type)
        }
        
        // Auto-dismiss after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) {
                self.toastMessage = nil
            }
        }
    }
}

struct ToastMessage: Identifiable {
    let id = UUID()
    let message: String
    let type: ToastType
}

enum ToastType {
    case success, error, info
    
    var color: Color {
        switch self {
        case .success: return .green
        case .error: return .red
        case .info: return .blue
        }
    }
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .info: return "info.circle.fill"
        }
    }
}
