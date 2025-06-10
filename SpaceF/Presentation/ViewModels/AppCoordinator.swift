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
        logger.info("Ejecutando tareas de inicialización...")
        
        // Aquí puedes agregar tareas de inicialización como:
        // - Verificar conectividad
        // - Cargar configuraciones
        // - Inicializar analytics
        // - Precarga de datos críticos
        
        
        do {
            // Ejemplo: Precargar algunos datos
            await preloadEssentialData()
            
            // Ejemplo: Inicializar servicios
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
        // Simular inicialización de servicios
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        logger.debug("Servicios inicializados")
    }
    
    func handleAppBecomeActive() {
        // Manejar cuando la app se vuelve activa
        logger.info("App se volvió activa")
    }
    
    func handleAppResignActive() {
        // Manejar cuando la app pierde el foco
        logger.info("App perdió el foco")
    }
}
