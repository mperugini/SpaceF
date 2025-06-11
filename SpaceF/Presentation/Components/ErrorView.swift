//
//  ErrorView.swift
//  SpaceF
//
//  Created by Mariano Perugini on 04/06/2025.
//

import SwiftUI

import SwiftUI

struct ErrorView: View {
    @State private var bounce = false
    @State private var opacity = 0.0
    @State private var scale = 0.8
    
    let errorMessage: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Icono animado
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50, weight: .medium))
                .foregroundStyle(.red, .red.opacity(0.3))
                .scaleEffect(bounce ? 1.1 : 1.0)
                .animation(
                    .spring(response: 0.4, dampingFraction: 0.3)
                    .repeatForever(autoreverses: true),
                    value: bounce
                )
            
            VStack(spacing: 12) {
                Text("¡Ups! Algo salió mal")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(errorMessage)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            
            Button(action: {
                impactFeedback()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    onRetry()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Reintentar")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.blue)
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                )
            }
            .buttonStyle(PulsatingButtonStyle())
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 8)
        )
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                opacity = 1.0
                scale = 1.0
            }
            
            withAnimation(.linear(duration: 0.1).delay(0.3)) {
                bounce = true
            }
        }
    }
    
    private func impactFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}
