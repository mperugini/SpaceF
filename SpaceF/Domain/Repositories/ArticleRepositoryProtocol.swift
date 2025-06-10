//
//  ArticleRepositoryProtocol.swift
//  SpaceF
//
//  Created by Mariano Perugini on 10/06/2025.
//

import Foundation

protocol ArticleRepositoryProtocol {
    func fetchArticles(searchQuery: String?, limit: Int, offset: Int) async throws -> ArticleResponse
    func fetchArticleDetail(id: Int) async throws -> Article
    func getCachedArticles() async -> [Article]
    func clearCache() async
}
