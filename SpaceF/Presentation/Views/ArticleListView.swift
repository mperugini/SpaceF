//
//  ArticleListView.swift
//  SpaceF
//
//  Created by Mariano Perugini on 04/06/2025.
//

import SwiftUI

struct ArticleListView: View {
    @StateObject private var viewModel = ArticleListViewModel()
    @State private var scrollOffset: CGFloat = 0
    @State private var scrollPosition: String?
    @State private var hasInitiallyLoaded = false
    @Namespace private var imageTransition
    
    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        contentBasedOnState
                        
                        if viewModel.morePagesAbailability() && !viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .onAppear {
                                    Task {
                                        await viewModel.loadMoreArticles()
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                .refreshable {
                    await viewModel.fetchArticles()
                }
                .onChange(of: scrollPosition) { oldValue, newValue in
                    if let position = newValue,
                       let articleId = Int(position) {
                        withAnimation {
                            proxy.scrollTo(articleId, anchor: .top)
                        }
                    }
                }
                .onChange(of: viewModel.articles.count) { oldValue, newValue in
                    if newValue > 0 && !hasInitiallyLoaded {
                        hasInitiallyLoaded = true
                    }
                }
            }
            .navigationTitle("Space News")
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Buscar artículos..."
            )
            .onSubmit(of: .search) {
                Task {
                    await viewModel.fetchArticles()
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    
                    Button(action: {
                        Task {
                            await viewModel.fetchArticles()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .background(Color(.systemGroupedBackground))
        }
        .navigationViewStyle(.stack)
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let currentArticle = viewModel.articles.first(where: { String($0.id) == scrollPosition }) {
                    withAnimation {
                        scrollPosition = String(currentArticle.id)
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties para evitar expresiones complejas
    
    @ViewBuilder
    private var contentBasedOnState: some View {
        if shouldShowSkeleton {
            SkeletonView()
        } else if shouldShowError {
            errorViewContent
        } else if shouldShowEmptyState {
            emptyStateContent
        } else {
            articlesContent
        }
    }
    
    @ViewBuilder
    private var errorViewContent: some View {
        if let error = viewModel.errorMessage {
            ErrorView(
                message: error,
                onRetry: {
                    Task {
                        await viewModel.fetchArticles()
                    }
                }
            )
        }
    }
    
    @ViewBuilder
    private var emptyStateContent: some View {
        ContentUnavailableView(
            "No se encontraron artículos",
            systemImage: "newspaper",
            description: Text("Intenta buscar algo diferente o regresa más tarde")
        )
    }
    
    @ViewBuilder
    private var articlesContent: some View {
        ForEach(viewModel.articles) { article in
            NavigationLink(destination: ArticleDetailView(article: article, imageTransition: imageTransition)) {
                ArticleCardView(article: article, imageTransition: imageTransition)
            }
            .buttonStyle(PlainButtonStyle())
            .id(article.id)
        }
        
        if viewModel.isLoading && !viewModel.articles.isEmpty {
            LoadingIndicatorView()
        }
    }
    
    // MARK: - Computed Properties para condiciones
    
    private var shouldShowSkeleton: Bool {
        !hasInitiallyLoaded || (viewModel.isLoading && viewModel.articles.isEmpty)
    }
    
    private var shouldShowError: Bool {
        viewModel.errorMessage != nil && viewModel.articles.isEmpty
    }
    
    private var shouldShowEmptyState: Bool {
        viewModel.articles.isEmpty && !viewModel.isLoading
    }
}
