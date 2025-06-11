//
//  LoadingIndicatorView.swift
//  SpaceF
//
//  Created by Mariano Perugini on 11/06/2025.
//

import SwiftUI

struct LoadingIndicatorView: View {
    @State private var isAnimating = false
    @State private var opacity = 0.0
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: 4)
                    .frame(width: 40, height: 40)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            }
            
            Text("Cargando...")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3)) {
                opacity = 1.0
            }
            isAnimating = true
        }
        .onDisappear {
            isAnimating = false
        }
    }
}
