import Foundation
import UIKit

// MARK: - Image Cache Protocol
protocol ImageCacheType: AnyObject {
    subscript(_ url: URL) -> UIImage? { get set }
}

// MARK: - Image Cache Implementation
final class ImageCache: ImageCacheType {
    // Singleton
    static let shared: ImageCacheType = ImageCache()

    // Private NSCache
    private let cache = NSCache<NSURL, UIImage>()

    private init() {
        // Configurar límites según las necesidades de la app
        cache.countLimit = 200            // Máximo 200 imágenes
        cache.totalCostLimit = 100 * 1024 * 1024 // 100 MB
    }

    subscript(_ key: URL) -> UIImage? {
        get { cache.object(forKey: key as NSURL) }
        set {
            if let image = newValue {
                let cost = image.jpegData(compressionQuality: 1)?.count ?? 0
                cache.setObject(image, forKey: key as NSURL, cost: cost)
            } else {
                cache.removeObject(forKey: key as NSURL)
            }
        }
    }
}

// MARK: - Environment Key para inyectar caché
import SwiftUI

private struct ImageCacheKey: EnvironmentKey {
    static let defaultValue: ImageCacheType = ImageCache.shared
}

extension EnvironmentValues {
    var imageCache: ImageCacheType {
        get { self[ImageCacheKey.self] }
        set { self[ImageCacheKey.self] = newValue }
    }
} 