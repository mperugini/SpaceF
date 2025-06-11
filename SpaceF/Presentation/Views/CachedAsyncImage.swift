//
//  CachedAsyncImage.swift
//  SpaceF
//
//  Created by Mariano Perugini on 04/06/2025.
//

import SwiftUI
import UIKit

/// Vista que carga imagenes de forma asíncrona con soporte de cache en memoria.
struct CachedAsyncImage<Content>: View where Content: View {
    private let url: URL?
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (AsyncImagePhase) -> Content

    @Environment(\.imageCache) private var cache: ImageCacheType
    @State private var phase: AsyncImagePhase = .empty

    init(
        url: URL?,
        scale: CGFloat = 1.0,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
    }

    var body: some View {
        content(phase)
            .task(id: url) {
                await load()
            }
    }

    // MARK: - Private helpers

    private func load() async {
        guard let url = url else {
            await updatePhase(.empty)
            return
        }

        // if cached, retrive inmediatly
        if let cachedImage = cache[url] {
            let image = Image(uiImage: cachedImage)
            await updatePhase(.success(image))
            return
        }

        // download
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let uiImage = UIImage(data: data) else {
                await updatePhase(.failure(ImageLoadingError.invalidData))
                return
            }
            // Gsave to cache
            cache[url] = uiImage
            let image = Image(uiImage: uiImage)
            await updatePhase(.success(image))
        } catch {
            await updatePhase(.failure(error))
        }
    }

    @MainActor
    private func updatePhase(_ newPhase: AsyncImagePhase) {
        withAnimation(.easeInOut(duration: 0.3)) {
            self.phase = newPhase
        }
    }

    private enum ImageLoadingError: Error {
        case invalidData
    }
} 
