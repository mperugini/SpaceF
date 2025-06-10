//
//  RootAppView.swift
//  SpaceF
//
//  Created by Mariano Perugini on 10/06/2025.
//

import SwiftUI

struct RootAppView: View {
    @StateObject private var appCoordinator = AppCoordinator()
    
    var body: some View {
        ZStack {
            if appCoordinator.showSplashScreen {
                SplashScreenView(isActive: $appCoordinator.showSplashScreen)
                    .transition(.asymmetric(
                        insertion: .identity,
                        removal: .opacity.combined(with: .scale(scale: 1.2))
                    ))
                    .zIndex(1)
            }
            
            if appCoordinator.isAppReady {
                ArticleListView()
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95)),
                        removal: .identity
                    ))
                    .zIndex(0)
            }
        }
        .animation(.easeInOut(duration: 0.8), value: appCoordinator.showSplashScreen)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            appCoordinator.handleAppBecomeActive()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            appCoordinator.handleAppResignActive()
        }
    }
}
