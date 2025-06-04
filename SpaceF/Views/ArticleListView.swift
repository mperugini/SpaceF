import SwiftUI

struct ArticleListView: View {
    @StateObject private var viewModel = ArticleListViewModel()
    @State private var isSearchBarVisible = true
    @State private var scrollOffset: CGFloat = 0
    @State private var lastScrollOffset: CGFloat = 0
    @State private var scrollPosition: String?
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 0) {
                            if isSearchBarVisible {
                                Color.clear
                                    .frame(height: 60)
                            }
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .frame(height: 300)
                            } else if let error = viewModel.errorMessage {
                                ErrorView(message: error)
                                    .frame(height: 300)
                            } else {
                                LazyVStack(spacing: 16) {
                                    ForEach(viewModel.articles) { article in
                                        NavigationLink(destination: ArticleDetailView(article: article)) {
                                            ArticleRowView(article: article)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .id(article.id)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .background(
                            GeometryReader { geometry in
                                Color.clear.preference(
                                    key: ScrollOffsetPreferenceKey.self,
                                    value: geometry.frame(in: .named("scroll")).minY
                                )
                            }
                        )
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        let delta = value - lastScrollOffset
                        lastScrollOffset = value
                        
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if delta > 0 && !isSearchBarVisible {
                                isSearchBarVisible = true
                            } else if delta < 0 && isSearchBarVisible {
                                isSearchBarVisible = false
                            }
                        }
                    }
                    .onChange(of: scrollPosition) { oldValue, newValue in
                        if let position = newValue,
                           let articleId = Int(position) {
                            withAnimation {
                                proxy.scrollTo(articleId, anchor: .top)
                            }
                        }
                    }
                }
                
                // Barra de búsqueda flotante
                VStack(spacing: 0) {
                    SearchBar(text: $viewModel.searchText, onSearch: {
                        viewModel.searchArticles()
                    })
                    .background(Color(UIColor.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                }
                .offset(y: isSearchBarVisible ? 0 : -60)
            }
            .navigationTitle("Space News")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await viewModel.fetchArticles()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .navigationViewStyle(.stack) // Forzar estilo de navegación para iPhone
        .task {
            await viewModel.fetchArticles()
        }
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
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct SearchBar: View {
    @Binding var text: String
    let onSearch: () -> Void
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Buscar artículos...", text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onSubmit {
                        onSearch()
                    }
                
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(8)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            
            if !text.isEmpty {
                Button("Buscar") {
                    onSearch()
                }
                .foregroundColor(.blue)
            }
        }
        .padding()
    }
}

struct ArticleRowView: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageUrl = article.imageUrl {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray
                }
                .frame(height: 200)
                .clipped()
                .cornerRadius(8)
            }
            
            Text(article.title)
                .font(.headline)
                .lineLimit(2)
            
            Text(article.summary)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(3)
            
            HStack {
                Text(article.newsSite)
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Text(article.publishedAt.prefix(10))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct ErrorView: View {
    let message: String
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            
            Text(message)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}
