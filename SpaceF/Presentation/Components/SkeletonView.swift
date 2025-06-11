//
//  SkeletonView.swift
//  SpaceF
//
//  Created by Mariano Perugini on 04/06/2025.
//

import SwiftUI


struct SkeletonView: View {
    @State private var animationOffset: CGFloat = -1
    let height: CGFloat
    let cornerRadius: CGFloat
    
    init(height: CGFloat = 20, cornerRadius: CGFloat = 8) {
        self.height = height
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(.gray.opacity(0.3))
            .frame(height: height)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.8), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: animationOffset * UIScreen.main.bounds.width)
            )
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    animationOffset = 1
                }
            }
    }
}

struct CardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image skeleton
            SkeletonView(height: 220, cornerRadius: 12)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    SkeletonView(height: 20, cornerRadius: 6)
                        .frame(width: 80)
                    Spacer()
                    SkeletonView(height: 16, cornerRadius: 4)
                        .frame(width: 60)
                }
                
                // Title skeleton
                VStack(alignment: .leading, spacing: 4) {
                    SkeletonView(height: 18, cornerRadius: 4)
                    SkeletonView(height: 18, cornerRadius: 4)
                        .frame(width: 200)
                }
                
                // Summary skeleton
                VStack(alignment: .leading, spacing: 4) {
                    SkeletonView(height: 14, cornerRadius: 4)
                    SkeletonView(height: 14, cornerRadius: 4)
                    SkeletonView(height: 14, cornerRadius: 4)
                        .frame(width: 150)
                }
            }
            .padding(16)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}
