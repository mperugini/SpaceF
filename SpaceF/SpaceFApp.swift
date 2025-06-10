//
//  SpaceFApp.swift
//  SpaceF
//
//  Created by Mariano Perugini on 03/06/2025.
//


import SwiftUI

@main
struct SpaceFApp: App {
    private let logger = AppLogger.shared
    
    init() {
        setupApp()
    }
    
    var body: some Scene {
        WindowGroup {
            RootAppView()
                .preferredColorScheme(.dark) // Tema espacial
                .onAppear {
                    logger.info("App iniciada")
                }
        }
    }
    
    private func setupApp() {
        // Configuraciones globales de la app
        logger.info("Configurando aplicación...")
        
        // Configurar apariencia global si es necesario
        setupGlobalAppearance()
    }
    
    private func setupGlobalAppearance() {
        // Configuraciones de apariencia global
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
    }
}
