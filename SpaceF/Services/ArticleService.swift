import Foundation

class ArticleService {
    private let baseURL = "https://api.spaceflightnewsapi.net/v4"
    private let logger = AppLogger.shared
    
    func fetchArticles(searchQuery: String? = nil) async throws -> ArticleResponse {
        var urlString = "\(baseURL)/articles"
        if let query = searchQuery, !query.isEmpty {
            urlString += "?search=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }
        
        guard let url = URL(string: urlString) else {
            let error = AppError.network(.invalidURL)
            logger.error(error)
            throw error
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = AppError.network(.serverError("Respuesta inválida del servidor"))
                logger.error(error)
                throw error
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let error = AppError.network(.serverError("Error del servidor: \(httpResponse.statusCode)"))
                logger.error(error)
                throw error
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(ArticleResponse.self, from: data)
                logger.info("Artículos obtenidos exitosamente: \(response.count)")
                return response
            } catch {
                let decodingError = AppError.network(.decodingError)
                logger.error(decodingError)
                throw decodingError
            }
        } catch let error as AppError {
            throw error
        } catch {
            let unexpectedError = AppError.unexpected(error.localizedDescription)
            logger.error(unexpectedError)
            throw unexpectedError
        }
    }
    
    func fetchArticleDetail(id: Int) async throws -> Article {
        let urlString = "\(baseURL)/articles/\(id)"
        
        guard let url = URL(string: urlString) else {
            let error = AppError.network(.invalidURL)
            logger.error(error)
            throw error
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = AppError.network(.serverError("Respuesta inválida del servidor"))
                logger.error(error)
                throw error
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let error = AppError.network(.serverError("Error del servidor: \(httpResponse.statusCode)"))
                logger.error(error)
                throw error
            }
            
            do {
                let decoder = JSONDecoder()
                let article = try decoder.decode(Article.self, from: data)
                logger.info("Detalle del artículo obtenido exitosamente: \(article.id)")
                return article
            } catch {
                let decodingError = AppError.network(.decodingError)
                logger.error(decodingError)
                throw decodingError
            }
        } catch let error as AppError {
            throw error
        } catch {
            let unexpectedError = AppError.unexpected(error.localizedDescription)
            logger.error(unexpectedError)
            throw unexpectedError
        }
    }
} 