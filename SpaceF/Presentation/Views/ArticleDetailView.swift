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
    @State private var imageOffset: CGFloat = -200
    @State private var contentOpacity: Double = 0
    @State private var hasAppeared = false
    
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
                    if let secureImageURL = article.secureImageURL {
                        CachedAsyncImage(url: secureImageURL) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width, height: 300)
                                    .clipped()
                                    .offset(y: imageOffset)
                                    .onAppear {
                                        withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                                            imageOffset = 0
                                        }
                                    }
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
                                        .opacity(contentOpacity)
                                    )
                                    .offset(y: imageOffset)
                            case .empty:
                                ZStack {
                                    ShimmerEffect()
                                        .frame(width: geometry.size.width, height: 300)
                                    
                                    ProgressView()
                                        .scaleEffect(1.2)
                                }
                                .offset(y: imageOffset)
                            @unknown default:
                                Rectangle()
                                    .fill(Color(.systemGray5))
                                    .frame(width: geometry.size.width, height: 300)
                                    .offset(y: imageOffset)
                            }
                        }
                    }
                    
                    // Content
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(article.title)
                                .font(.title)
                                .fontWeight(.bold)
                                .opacity(contentOpacity)
                                .animation(.easeInOut(duration: 0.6).delay(0.2), value: contentOpacity)
                            
                            HStack {
                                Text(article.newsSite)
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                                
                                Spacer()
                                
                                Text("Publicado: \(formattedDate)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .opacity(contentOpacity)
                            .animation(.easeInOut(duration: 0.6).delay(0.3), value: contentOpacity)
                            
                            Divider()
                                .opacity(contentOpacity)
                                .animation(.easeInOut(duration: 0.6).delay(0.4), value: contentOpacity)
                            
                            Text(article.summary)
                                .font(.body)
                                .lineSpacing(4)
                                .opacity(contentOpacity)
                                .animation(.easeInOut(duration: 0.6).delay(0.5), value: contentOpacity)
                            
                            Button(action: {
                                impactFeedback()
                                showSafariView = true
                            }) {
                                HStack(spacing: 8) {
                                    Text("Leer artículo completo")
                                        .fontWeight(.semibold)
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .padding(.horizontal, 24)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(.blue)
                                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                                )
                                .foregroundColor(.white)
                            }
                            .buttonStyle(PulsatingButtonStyle())
                            .padding(.top, 8)
                            .opacity(contentOpacity)
                            .animation(.easeInOut(duration: 0.6).delay(0.6), value: contentOpacity)
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
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                imageOffset = 0
            }
            withAnimation(.easeInOut(duration: 0.6).delay(0.3)) {
                contentOpacity = 1
            }
        }
    }
    
    private func impactFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
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
