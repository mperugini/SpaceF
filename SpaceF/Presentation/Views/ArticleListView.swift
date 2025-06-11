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
    @State private var pullAmount: CGFloat = 0
    @Namespace private var imageTransition
    
    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        contentBasedOnState
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                .refreshable {
                    await viewModel.refreshArticles()
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
            .navigationTitle("Space Flight News")
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Buscar Articulos ..."
            )
            .onSubmit(of: .search) {
                Task {
                    await viewModel.fetchArticles()
                }
            }
            .onChange(of: viewModel.searchText) { oldValue, newValue in
                // Handle search cancellation when search text is cleared
                if !oldValue.isEmpty && newValue.isEmpty {
                    viewModel.handleSearchCancellation()
                }
            }
            .overlay(
                // Search state indicator
                VStack {
                    if viewModel.searchState != "idle" {
                        SearchStateIndicator(state: viewModel.searchState)
                            .padding(.top, 8)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .animation(.spring(), value: viewModel.searchState)
                    }
                    Spacer()
                },
                alignment: .top
            )
            .overlay(
                // Toast overlay
                VStack {
                    Spacer()
                    if let toastMessage = viewModel.toastMessage {
                        ToastView(message: toastMessage.message, type: convertToastType(toastMessage.type))
                            .padding(.horizontal, 16)
                            .padding(.bottom, 100)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                },
                alignment: .bottom
            )
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
            skeletonContent
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
        ErrorView(
            errorMessage: viewModel.errorMessage ?? "Error desconocido"
        ) {
            viewModel.retry()
        }
        .padding(.horizontal, 32)
    }
    
    @ViewBuilder
    private var emptyStateContent: some View {
        ContentUnavailableView(
            "No se encontraron artículos",
            systemImage: "newspaper",
            description: Text("Intenta buscar algo diferente o regresa más tarde") //ToDo: i18n
        )
    }
    
    @ViewBuilder
    private var articlesContent: some View {
        ForEach(Array(viewModel.articles.enumerated()), id: \.element.id) { index, article in
            NavigationLink {
                ArticleDetailView(article: article)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
            } label: {
                ArticleCardView(article: article)
            }
            .buttonStyle(PulsatingButtonStyle())
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }
            )
            .id(article.id)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .scale.combined(with: .opacity)
            ))
            .animation(
                .spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.1)
                .delay(Double(index % 10) * 0.05), 
                value: viewModel.articles.count
            )
            .onAppear {
                // Scroll infinito: carga mas articulos cuando llegamos cerca del final
                if index == viewModel.articles.count - 3 && !viewModel.isLoading && viewModel.hasMorePages {
                    Task {
                        await viewModel.loadMoreArticles()
                    }
                }
            }
        }
        
        // Loading indicator mejorado
        if viewModel.isLoading && !viewModel.articles.isEmpty {
            HStack {
                Spacer()
                LoadingIndicatorView()
                Spacer()
            }
            .padding(.vertical, 20)
            .transition(.scale.combined(with: .opacity))
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.isLoading)
        }
    }
    
    @ViewBuilder
    private var skeletonContent: some View {
        ForEach(0..<5, id: \.self) { index in
            CardSkeleton()
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
                .animation(
                    .spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.1)
                    .delay(Double(index) * 0.1), 
                    value: hasInitiallyLoaded
                )
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
    
    private func convertToastType(_ type: ToastType) -> ToastType {
        return type
    }
}
