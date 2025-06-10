import Foundation

class ArticleService {
    private let baseURL = "https://api.spaceflightnewsapi.net/v4"
    private let logger = AppLogger.shared
    private let session: URLSession
    private let cache = NSCache<NSString, NSData>()
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true
        config.requestCachePolicy = .returnCacheDataElseLoad
        
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
        
        self.session = URLSession(configuration: config)
    }
    
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
        
        // busco primero si hay cache
        if let cachedData = cache.object(forKey: url.absoluteString as NSString) {
            do {
                let response = try JSONDecoder().decode(ArticleResponse.self, from: cachedData as Data)
                logger.info("Datos desde cache")
                return response
            } catch {
             //   logger.error("Error decoder datos del cache")
            }
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = AppError.network(.serverError("response invalida "))
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

                cache.setObject(data as NSData, forKey: url.absoluteString as NSString)
                
                logger.info("Articulos bajados: \(response.count)")
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
        
        if let cachedData = cache.object(forKey: url.absoluteString as NSString) {
            do {
                let article = try JSONDecoder().decode(Article.self, from: cachedData as Data)
                logger.info("Detalle del articulo desde cache")
                return article
            } catch {
              //  logger.error("Error decoder datos del cache")
            }
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = AppError.network(.serverError("response invalida"))
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
                
                cache.setObject(data as NSData, forKey: url.absoluteString as NSString)
                
                logger.info("Detalle del artículo: \(article.id)")
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
