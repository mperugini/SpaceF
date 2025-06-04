import Foundation

struct Article: Codable, Identifiable {
    let id: Int
    let title: String
    let url: String
    let imageUrl: String?
    let newsSite: String
    let summary: String
    let publishedAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case url
        case imageUrl = "image_url"
        case newsSite = "news_site"
        case summary
        case publishedAt = "published_at"
        case updatedAt = "updated_at"
    }
}

struct ArticleResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [Article]
} 