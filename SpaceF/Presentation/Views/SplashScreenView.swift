//
//  SplashScreenView.swift
//  SpaceF
//
//  Created by Mariano Perugini on 10/06/2025.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0
    @State private var rotationAngle: Double = 0
    @State private var showTitle = false
    @State private var titleOffset: CGFloat = 50
    @Binding var isActive: Bool
    
    private let animationDuration: Double = 2.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color.black,
                        Color.blue.opacity(0.8),
                        Color.purple.opacity(0.6),
                        Color.black
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Animated stars background
                StarsBackgroundView()
                
                // Main content
                VStack(spacing: 30) {
                    Spacer()
                    
                    // App icon/logo
                    ZStack {
                        // Outer glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.blue.opacity(0.6),
                                        Color.purple.opacity(0.4),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 200, height: 200)
                            .scaleEffect(isAnimating ? 1.2 : 0.8)
                            .opacity(isAnimating ? 0.8 : 0.3)
                        
                        // Main icon container
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.blue,
                                        Color.purple,
                                        Color.indigo
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .overlay(
                                // Rocket icon
                                Image(systemName: "rocket.fill")
                                    .font(.system(size: 50, weight: .bold))
                                    .foregroundColor(.white)
                                    .rotationEffect(.degrees(rotationAngle))
                            )
                            .scaleEffect(scale)
                            .opacity(opacity)
                    }
                    
                    // App title
                    VStack(spacing: 8) {
                        Text("Space News")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.white, Color.blue.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .opacity(showTitle ? 1 : 0)
                            .offset(y: titleOffset)
                        
                        Text("Explore the Universe")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .opacity(showTitle ? 1 : 0)
                            .offset(y: titleOffset)
                    }
                    
                    Spacer()
                    
                    // Loading indicator
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                        
                        Text("Loading...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .opacity(showTitle ? 1 : 0)
                    .padding(.bottom, 50)
                }
                .padding()
            }
        }
        .onAppear {
            startAnimations()
            
            // Auto-dismiss after animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration + 1.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isActive = false
                }
            }
        }
    }
    
    private func startAnimations() {
        // Icon entrance animation
        withAnimation(.easeOut(duration: 0.8)) {
            scale = 1.0
            opacity = 1.0
        }
        
        // Rotation animation
        withAnimation(.linear(duration: animationDuration).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // Background pulse
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            isAnimating = true
        }
        
        // Title animation (delayed)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0)) {
                showTitle = true
                titleOffset = 0
            }
        }
    }
}

// MARK: - Stars Background
struct StarsBackgroundView: View {
    @State private var animateStars = false
    
    var body: some View {
        ZStack {
            ForEach(0..<50, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.3...0.8)))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .scaleEffect(animateStars ? 1.2 : 0.8)
                    .animation(
                        .easeInOut(duration: Double.random(in: 1...3))
                        .repeatForever(autoreverses: true)
                        .delay(Double.random(in: 0...2)),
                        value: animateStars
                    )
            }
        }
        .onAppear {
            animateStars = true
        }
    }
}

// MARK: - Preview
#Preview {
    SplashScreenView(isActive: .constant(true))
}
