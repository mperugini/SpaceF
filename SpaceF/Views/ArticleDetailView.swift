import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let imageUrl = article.imageUrl {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .clipped()
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(article.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text(article.newsSite)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        
                        Spacer()
                        
                        Text("Publicado: \(article.publishedAt.prefix(10))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Divider()
                    
                    Text(article.summary)
                        .font(.body)
                        .lineSpacing(4)
                    
                    Button(action: {
                        if let url = URL(string: article.url) {
                            openURL(url)
                        }
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
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
} 
