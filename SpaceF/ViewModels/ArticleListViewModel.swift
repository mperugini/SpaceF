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
    
    private let articleService = ArticleService()
    private let logger = AppLogger.shared
    private var currentTask: Task<Void, Never>?
    private var currentOffset = 0
    private let limit = 10
    private var hasMorePages = true
    
    init() {
        // Iniciar la carga de datos inmediatamente
        Task {
            await loadInitialData()
        }
    }
    
    private func loadInitialData() async {
        // Primero intentamos cargar el estado guardado
        if let savedArticles = UserDefaults.standard.data(forKey: "savedArticles"),
           let decodedArticles = try? JSONDecoder().decode([Article].self, from: savedArticles) {
            self.articles = decodedArticles
        }
        
        if let savedSearchText = UserDefaults.standard.string(forKey: "savedSearchText") {
            self.searchText = savedSearchText
        }
        
        // Si no hay artículos guardados o son muy antiguos, hacemos fetch
        if articles.isEmpty {
            await fetchArticles()
        }
    }
    
    func fetchArticles() async {
        // Cancelar cualquier tarea anterior
        currentTask?.cancel()
        
        // Crear nueva tarea
        currentTask = Task {
            isLoading = true
            errorMessage = nil
            
            do {
                let response = try await articleService.fetchArticles(
                    searchQuery: searchText.isEmpty ? nil : searchText,
                    limit: limit,
                    offset: currentOffset
                )
                
                // Verificar si la tarea fue cancelada
                if Task.isCancelled { return }
                
                if currentOffset == 0 {
                    articles = response.results
                } else {
                    articles.append(contentsOf: response.results)
                }
                
                hasMorePages = response.next != nil
                currentOffset += response.results.count
                saveState()
                logger.info("Artículos cargados exitosamente: \(articles.count)")
            } catch let error as AppError {
                if !Task.isCancelled {
                    errorMessage = error.localizedDescription
                    logger.error(error)
                }
            } catch {
                if !Task.isCancelled {
                    let unexpectedError = AppError.unexpected(error.localizedDescription)
                    errorMessage = unexpectedError.localizedDescription
                    logger.error(unexpectedError)
                }
            }
            
            if !Task.isCancelled {
                isLoading = false
            }
        }
    }
    
    func morePagesAbailability() -> Bool {
        return hasMorePages
    }
    
    func loadMoreArticles() async {
        guard !isLoading && hasMorePages else { return }
        await fetchArticles()
    }
    
    func searchArticles() {
        guard !searchText.isEmpty else {
            errorMessage = AppError.validation(.invalidInput("Búsqueda")).localizedDescription
            return
        }
        
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
    
    private func saveState() {
        if let encodedArticles = try? JSONEncoder().encode(articles) {
            UserDefaults.standard.set(encodedArticles, forKey: "savedArticles")
        }
        UserDefaults.standard.set(searchText, forKey: "savedSearchText")
    }
    
    func restoreState() {
        Task {
            await loadInitialData()
        }
    }
}
