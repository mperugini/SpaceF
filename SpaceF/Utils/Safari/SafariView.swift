//
//  SafariView.swift
//  SpaceF
//
//  Created by Mariano Perugini on 10/06/2025.
//

import SwiftUI
import SafariServices

struct SafariView: View {
    let url: URL
    let article: Article
    let configuration: SafariConfiguration
    
    @State private var isLoading = true
    @State private var hasError = false
    @Environment(\.dismiss) private var dismiss
    
    init(url: URL, article: Article, configuration: SafariConfiguration = .spaceTheme) {
        self.url = url
        self.article = article
        self.configuration = configuration
    }
    
    var body: some View {
        ZStack {
            // Safari View Controller
            SafariViewWithCallbacks(
                url: url,
                configuration: configuration,
                onLoadingChange: { loading in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isLoading = loading
                    }
                },
                onError: { error in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        hasError = true
                        isLoading = false
                    }
                }
            )
            
            if isLoading {
                loadingOverlay
                    .transition(.opacity)
            }
            
            if hasError {
                errorOverlay
                    .transition(.opacity)
            }
        }
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    private var loadingOverlay: some View {
        Color.black.opacity(0.8)
            .ignoresSafeArea()
            .overlay(
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    
                    VStack(spacing: 8) {
                        Text("Cargando artículo...")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(article.title)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .padding(.horizontal, 40)
                    }
                    
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                    .font(.system(size: 16, weight: .medium))
                }
            )
    }
    
    @ViewBuilder
    private var errorOverlay: some View {
        Color.black.opacity(0.9)
            .ignoresSafeArea()
            .overlay(
                VStack(spacing: 24) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    
                    VStack(spacing: 12) {
                        Text("Error al cargar")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("No se pudo cargar el artículo. Verifica tu conexión a internet.")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    HStack(spacing: 16) {
                        Button("Reintentar") {
                            withAnimation {
                                hasError = false
                                isLoading = true
                            }
                            // Forzar recarga (esto cerrará y reabrirá Safari View)
                            dismiss()
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(8)
                        
                        Button("Cerrar") {
                            dismiss()
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                    }
                }
            )
    }
}

// MARK: - Safari View with Callbacks
struct SafariViewWithCallbacks: UIViewControllerRepresentable {
    let url: URL
    let configuration: SafariConfiguration
    let onLoadingChange: (Bool) -> Void
    let onError: (Error?) -> Void
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let safariConfig = SFSafariViewController.Configuration()
        safariConfig.entersReaderIfAvailable = configuration.entersReaderIfAvailable
        safariConfig.barCollapsingEnabled = configuration.barCollapsingEnabled
        
        let safariViewController = SFSafariViewController(url: url, configuration: safariConfig)
        
        // Configurar apariencia
        safariViewController.preferredBarTintColor = configuration.barTintColor
        safariViewController.preferredControlTintColor = configuration.controlTintColor
        safariViewController.dismissButtonStyle = configuration.dismissButtonStyle
        
        // Configurar delegate
        safariViewController.delegate = context.coordinator
        
        return safariViewController
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        let parent: SafariViewWithCallbacks
        
        init(_ parent: SafariViewWithCallbacks) {
            self.parent = parent
        }
        
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            AppLogger.shared.info("Safari View cerrado por el usuario")
        }
        
        func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
            DispatchQueue.main.async {
                self.parent.onLoadingChange(false)
                
                if !didLoadSuccessfully {
                    self.parent.onError(AppError.network(.noData))
                    AppLogger.shared.error(AppError.network(.noData))
                } else {
                    AppLogger.shared.info("Safari View cargó exitosamente: \(self.parent.url.absoluteString)")
                }
            }
        }
        
        func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
            AppLogger.shared.info("Safari View redirigido a: \(URL.absoluteString)")
        }
    }
}
