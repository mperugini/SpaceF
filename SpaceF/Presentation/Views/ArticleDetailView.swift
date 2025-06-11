//
//  ArticleDetailView.swift
//  SpaceF
//
//  Created by Mariano Perugini on 04/06/2025.
//

import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    @Environment(\.dismiss) private var dismiss
    @State private var scrollOffset: CGFloat = 0
    @State private var showShareSheet = false
    @State private var showSafariView = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }()
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Hero Image con URL segura
                    if let secureImageURL = article.secureImageURL {
                        AsyncImage(url: secureImageURL) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width, height: 300)
                                    .clipped()
                            case .failure(_):
                                Rectangle()
                                    .fill(Color(.systemGray5))
                                    .frame(width: geometry.size.width, height: 300)
                                    .overlay(
                                        VStack(spacing: 8) {
                                            Image(systemName: "photo")
                                                .font(.system(size: 40))
                                                .foregroundColor(.gray)
                                            Text("Imagen no disponible")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    )
                            case .empty:
                                Rectangle()
                                    .fill(Color(.systemGray6))
                                    .frame(width: geometry.size.width, height: 300)
                                    .overlay(
                                        ProgressView()
                                            .scaleEffect(1.2)
                                    )
                            @unknown default:
                                Rectangle()
                                    .fill(Color(.systemGray5))
                                    .frame(width: geometry.size.width, height: 300)
                            }
                        }
                    }
                    
                    // Content
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(article.title)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            HStack {
                                Text(article.newsSite)
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                
                                Spacer()
                                
                                Text("Publicado: \(formattedDate)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Divider()
                            
                            Text(article.summary)
                                .font(.body)
                                .lineSpacing(4)
                            
                            Button(action: {
                                showSafariView = true
                            }) {
                                HStack {
                                    Text("Leer artículo completo")
                                    Image(systemName: "arrow.right")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .padding(.top)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Bottom spacing
                        Color.clear.frame(height: 20)
                    }
                    .background(Color(.systemBackground))
                }
                .background(
                    GeometryReader { scrollGeometry in
                        Color.clear
                            .onChange(of: scrollGeometry.frame(in: .global).minY) { _, newValue in
                                scrollOffset = newValue
                            }
                    }
                )
            }
            .ignoresSafeArea(.all, edges: .top)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .overlay(customNavigationBar, alignment: .top)
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [article.url, article.title])
        }
        .sheet(isPresented: $showSafariView) {
            if let url = URL(string: article.url) {
                SafariView(url: url, article: article, configuration: .spaceTheme)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
    
    @ViewBuilder
    private var customNavigationBar: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 2)
            }
            
            Spacer()
            
            Button(action: {
                showShareSheet = true
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 2)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private var formattedDate: String {
        if let date = ISO8601DateFormatter().date(from: article.publishedAt) {
            return dateFormatter.string(from: date)
        } else {
            return String(article.publishedAt.prefix(10))
        }
    }
}

// MARK: - Extensions and Helper Views

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
