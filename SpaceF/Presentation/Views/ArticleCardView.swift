//
//  ArticleCardView.swift
//  SpaceF
//
//  Created by Mariano Perugini on 04/06/2025.
//

import SwiftUI

struct ArticleCardView: View {
    let article: Article
    @State private var hasAppeared = false
    @State private var imageLoadingState: ImageLoadingState = .loading
    
    enum ImageLoadingState {
        case loading, loaded, failed
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let imageUrl = article.secureImageURL {
                CachedAsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 220)
                            .clipped()
                            .onAppear {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    imageLoadingState = .loaded
                                }
                            }
                    case .failure(_):
                        ImagePlaceholder(isError: true)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    imageLoadingState = .failed
                                }
                            }
                    case .empty:
                        ZStack {
                            ShimmerEffect()
                                .frame(height: 220)
                            
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        .onAppear {
                            imageLoadingState = .loading
                        }
                    @unknown default:
                        ImagePlaceholder(isError: true)
                    }
                }
                .accessibilityLabel("Imagen del artículo: \(article.title)")
            }
            
            // Contenido del artículo
            VStack(alignment: .leading, spacing: 12) {
                // Fuente y fecha
                HStack {
                    Text(article.newsSite)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                    
                    Spacer()
                    
                    Text(formattedDate)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                // Título
                Text(article.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                // Resumen
                Text(article.summary)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
            }
            .padding(16)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(
            color: Color.black.opacity(0.1), 
            radius: 8, 
            x: 0, 
            y: 2
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 0.5)
        )
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: hasAppeared)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Artículo")
        .accessibilityValue("\(article.title). \(article.summary). Publicado por \(article.newsSite) el \(formattedDate)")
        .accessibilityAddTraits(.isButton)
        .onAppear {
            hasAppeared = true
        }
    }
    
    private var formattedDate: String {
        if let date = ISO8601DateFormatter().date(from: article.publishedAt) {
            return dateFormatter.string(from: date)
        } else {
            return String(article.publishedAt.prefix(10))
        }
    }
    

}
