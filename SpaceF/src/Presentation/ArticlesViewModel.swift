import Foundation
import SwiftUI

@MainActor
class ArticlesViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var searchText = ""
    
    private let service = SpaceFlightService()
    private var currentPage = 1
    private var hasMorePages = true
    
    func loadArticles() async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            let response = try await service.fetchArticles(searchQuery: searchText, page: currentPage)
            articles = response.results
            hasMorePages = response.next != nil
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func loadMoreArticles() async {
        guard !isLoading && hasMorePages else { return }
        
        currentPage += 1
        isLoading = true
        
        do {
            let response = try await service.fetchArticles(searchQuery: searchText, page: currentPage)
            articles.append(contentsOf: response.results)
            hasMorePages = response.next != nil
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func search() async {
        currentPage = 1
        hasMorePages = true
        await loadArticles()
    }
} 