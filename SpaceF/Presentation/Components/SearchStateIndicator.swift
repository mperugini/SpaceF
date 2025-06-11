//
//  SearchStateIndicator.swift
//  SpaceF
//
//  Created by Mariano Perugini on 11/06/2025.
//

import SwiftUI

struct SearchStateIndicator: View {
    let state: String
    @State private var animationScale = 1.0
    
    var body: some View {
        HStack(spacing: 8) {
            switch state {
            case "idle":
                EmptyView()
            case "searching":
                ProgressView()
                    .scaleEffect(0.8)
                Text("Buscando...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            case let found where found.hasPrefix("found:"):
                let count = String(found.dropFirst(6)) // Remove "found:" prefix
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .scaleEffect(animationScale)
                Text("\(count) resultados encontrados")
                    .font(.caption)
                    .foregroundColor(.secondary)
            case "empty":
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.orange)
                Text("Sin resultados")
                    .font(.caption)
                    .foregroundColor(.secondary)
            default:
                EmptyView()
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.regularMaterial)
        )
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
            if state.hasPrefix("found:") {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    animationScale = 1.2
                }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.1)) {
                    animationScale = 1.0
                }
            }
        }
    }
} 
