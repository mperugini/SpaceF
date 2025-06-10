//
//  AppCoordinator.swift
//  SpaceF
//
//  Created by Mariano Perugini on 10/06/2025.
//

import SwiftUI
import Combine

@MainActor
class AppCoordinator: ObservableObject {
    @Published var showSplashScreen = true
    @Published var isAppReady = false
    
    private let logger = AppLogger.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        startAppInitialization()
    }
    
    private func startAppInitialization() {
        logger.info("Iniciando aplicación...")
        
        // Simular tareas de inicialización
        Task {
            await performInitializationTasks()
            
            // Esperar un mínimo de tiempo para mostrar el splash
            let minSplashTime: TimeInterval = 2.0
            try? await Task.sleep(nanoseconds: UInt64(minSplashTime * 1_000_000_000))
            
            // Marcar como lista y ocultar splash
            isAppReady = true
            
            // Pequeño delay antes de ocultar el splash para una transición suave
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            withAnimation(.easeInOut(duration: 0.5)) {
                showSplashScreen = false
            }
        }
    }
    
    private func performInitializationTasks() async {
        logger.info("tareas de inicialización...")
        
        do {
        
            await preloadEssentialData() // such as Firebase sdk init, remote logger, etc
            
            await initializeServices()
            logger.info("Inicialización completada exitosamente")
        }
    }
    
    private func preloadEssentialData() async {
        // Simular carga de datos esenciales
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        logger.debug("Datos esenciales precargados")
    }
    
    private func initializeServices() async {
        // Simula inicializacion de servicios
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        logger.debug("Servicios inicializados")
    }
    
    func handleAppBecomeActive() {
        logger.info("App se volvió activa")
    }
    
    func handleAppResignActive() {
        logger.info("App perdió el foco")
    }
}
