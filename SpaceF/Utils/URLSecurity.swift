//
//  URLSecurity.swift
//  SpaceF
//
//  Created by Mariano Perugini on 10/06/2025.
//

import Foundation

// MARK: - URL Security Extensions
extension String {
    /// Convierte HTTP a HTTPS de forma segura
    var secureHTTPS: String {
        if self.hasPrefix("http://") {
            return self.replacingOccurrences(of: "http://", with: "https://")
        }
        return self
    }
    
    /// Valida si la URL es segura (HTTPS)
    var isSecureURL: Bool {
        return self.hasPrefix("https://") || self.hasPrefix("data:") // data: para imágenes base64
    }
    
    /// Convierte a URL segura solo si es una URL válida
    var toSecureURL: URL? {
        let secureString = self.secureHTTPS
        
        // Validar que sea una URL bien formada
        guard let url = URL(string: secureString),
              let scheme = url.scheme,
              ["https", "data"].contains(scheme.lowercased()) else {
            AppLogger.shared.error(AppError.validation(.invalidInput("URL no segura: \(self)")))
            return nil
        }
        
        return url
    }
}

extension URL {
    /// Convierte la URL a HTTPS si es HTTP
    var secureHTTPS: URL? {
        if scheme == "http" {
            var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
            components?.scheme = "https"
            return components?.url
        }
        return self
    }
    
    /// Verifica si la URL es segura
    var isSecure: Bool {
        guard let scheme = scheme?.lowercased() else { return false }
        return ["https", "data"].contains(scheme)
    }
}

// MARK: - Image URL Validator
struct ImageURLValidator {
    private static let logger = AppLogger.shared
    
    /// Valida y convierte una URL de imagen a HTTPS
    static func validateAndSecure(_ urlString: String?) -> URL? {
        guard let urlString = urlString?.trimmingCharacters(in: .whitespacesAndNewlines),
              !urlString.isEmpty else {
            logger.debug("URL de imagen vacía o nil")
            return nil
        }
        
        // Convertir a HTTPS
        let secureURLString = urlString.secureHTTPS
        
        // Crear URL
        guard let url = URL(string: secureURLString) else {
            logger.error(AppError.validation(.invalidInput("URL malformada: \(urlString)")))
            return nil
        }
        
        // Validar esquema seguro
        guard url.isSecure else {
            logger.error(AppError.validation(.invalidInput("URL no segura: \(urlString)")))
            return nil
        }
        
        // Validar que sea una URL de imagen válida
        guard isValidImageURL(url) else {
            logger.error(AppError.validation(.invalidInput("URL no es de imagen válida: \(urlString)")))
            return nil
        }
        
        logger.debug("URL de imagen validada: \(secureURLString)")
        return url
    }
    
    /// Verifica si la URL parece ser de una imagen
    private static func isValidImageURL(_ url: URL) -> Bool {
        let pathExtension = url.pathExtension.lowercased()
        let validExtensions = ["jpg", "jpeg", "png", "gif", "webp", "svg", "bmp", "ico"]
        
        // Si tiene extensión de imagen válida
        if validExtensions.contains(pathExtension) {
            return true
        }
        
        // Si no tiene extensión, asumir que es válida (muchas APIs no usan extensiones)
        // pero verificar que tenga un host válido
        guard let host = url.host, !host.isEmpty else {
            return false
        }
        
        // Lista blanca de dominios conocidos de imágenes
        let trustedImageHosts = [
            "images.unsplash.com",
            "cdn.pixabay.com",
            "images.pexels.com",
            "i.imgur.com",
            "cdn.spaceflightnewsapi.net",
            "spaceflightnewsapi.net"
        ]
        
        // Si es de un host de confianza, permitir sin extensión
        if trustedImageHosts.contains(where: { host.contains($0) }) {
            return true
        }
        
        // Para otros hosts, ser más permisivo pero loggear
        logger.debug("URL de imagen sin extensión conocida: \(url.absoluteString)")
        return true
    }
}
