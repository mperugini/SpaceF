import SwiftUI

struct ArticlesListView: View {
    @StateObject private var viewModel = ArticlesViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $viewModel.searchText, onSearch: {
                    Task {
                        await viewModel.search()
                    }
                })
                
                if viewModel.isLoading && viewModel.articles.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.articles) { article in
                            NavigationLink(destination: ArticleDetailView(article: article)) {
                                ArticleRowView(article: article)
                            }
                        }
                        
                        if viewModel.hasMorePages {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .onAppear {
                                    Task {
                                        await viewModel.loadMoreArticles()
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Space Flight News")
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.error = nil
                }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "Unknown error")
            }
        }
        .task {
            await viewModel.loadArticles()
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    let onSearch: () -> Void
    
    var body: some View {
        HStack {
            TextField("Search articles...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    onSearch()
                }
            
            Button(action: onSearch) {
                Image(systemName: "magnifyingglass")
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
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            HStack {
                Text(article.newsSite)
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Text(article.publishedAt.prefix(10))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
} 