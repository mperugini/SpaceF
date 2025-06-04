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
    
    // Cache para mantener los artículos
    private var articleCache: [Article] = []
    
    init() {
        // Cargar el estado guardado si existe
        if let savedArticles = UserDefaults.standard.data(forKey: "savedArticles"),
           let decodedArticles = try? JSONDecoder().decode([Article].self, from: savedArticles) {
            self.articles = decodedArticles
            self.articleCache = decodedArticles
        }
        
        if let savedSearchText = UserDefaults.standard.string(forKey: "savedSearchText") {
            self.searchText = savedSearchText
        }
    }
    
    func fetchArticles() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await articleService.fetchArticles(searchQuery: searchText.isEmpty ? nil : searchText)
            articles = response.results
            articleCache = response.results
            
            // Guardar el estado
            saveState()
            
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
    
    func searchArticles() {
        guard !searchText.isEmpty else {
            errorMessage = AppError.validation(.invalidInput("Búsqueda")).localizedDescription
            return
        }
        
        Task {
            await fetchArticles()
        }
    }
    
    func retry() {
        Task {
            await fetchArticles()
        }
    }
    
    // Guardar el estado actual
    private func saveState() {
        if let encodedArticles = try? JSONEncoder().encode(articles) {
            UserDefaults.standard.set(encodedArticles, forKey: "savedArticles")
        }
        UserDefaults.standard.set(searchText, forKey: "savedSearchText")
    }
    
    // Restaurar el estado
    func restoreState() {
        if let savedArticles = UserDefaults.standard.data(forKey: "savedArticles"),
           let decodedArticles = try? JSONDecoder().decode([Article].self, from: savedArticles) {
            self.articles = decodedArticles
            self.articleCache = decodedArticles
        }
        
        if let savedSearchText = UserDefaults.standard.string(forKey: "savedSearchText") {
            self.searchText = savedSearchText
        }
    }
} 