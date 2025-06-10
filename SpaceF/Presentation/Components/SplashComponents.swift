//
//  SplashComponents.swift
//  SpaceF
//
//  Created by Mariano Perugini on 10/06/2025.
//

import SwiftUI

// MARK: - Animated Logo Component
struct AnimatedSpaceLogo: View {
    @State private var isAnimating = false
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0
    @State private var rotationAngle: Double = 0
    
    var body: some View {
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
                    // Custom rocket design
                    RocketIcon()
                        .fill(Color.white)
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(rotationAngle))
                )
                .scaleEffect(scale)
                .opacity(opacity)
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Icon entrance animation
        withAnimation(.easeOut(duration: 0.8)) {
            scale = 1.0
            opacity = 1.0
        }
        
        // Rotation animation
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // Background pulse
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            isAnimating = true
        }
    }
}

// MARK: - Custom Rocket Icon Shape
struct RocketIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // Rocket body
        path.move(to: CGPoint(x: width * 0.5, y: height * 0.1))
        path.addLine(to: CGPoint(x: width * 0.3, y: height * 0.7))
        path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.7))
        path.addLine(to: CGPoint(x: width * 0.45, y: height * 0.9))
        path.addLine(to: CGPoint(x: width * 0.55, y: height * 0.9))
        path.addLine(to: CGPoint(x: width * 0.6, y: height * 0.7))
        path.addLine(to: CGPoint(x: width * 0.7, y: height * 0.7))
        path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.1))
        
        // Rocket fins
        path.move(to: CGPoint(x: width * 0.3, y: height * 0.7))
        path.addLine(to: CGPoint(x: width * 0.2, y: height * 0.8))
        path.addLine(to: CGPoint(x: width * 0.35, y: height * 0.8))
        
        path.move(to: CGPoint(x: width * 0.7, y: height * 0.7))
        path.addLine(to: CGPoint(x: width * 0.8, y: height * 0.8))
        path.addLine(to: CGPoint(x: width * 0.65, y: height * 0.8))
        
        return path
    }
}

// MARK: - Particles Effect
struct ParticlesView: View {
    @State private var particles: [Particle] = []
    
    var body: some View {
        ZStack {
            ForEach(particles.indices, id: \.self) { index in
                Circle()
                    .fill(particles[index].color)
                    .frame(width: particles[index].size, height: particles[index].size)
                    .position(particles[index].position)
                    .opacity(particles[index].opacity)
            }
        }
        .onAppear {
            createParticles()
            animateParticles()
        }
    }
    
    private func createParticles() {
        particles = (0..<30).map { _ in
            Particle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                ),
                size: CGFloat.random(in: 1...4),
                color: [Color.blue, Color.purple, Color.white, Color.cyan].randomElement() ?? Color.white,
                opacity: Double.random(in: 0.3...0.8)
            )
        }
    }
    
    private func animateParticles() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            for index in particles.indices {
                withAnimation(.linear(duration: 0.1)) {
                    particles[index].position.y -= CGFloat.random(in: 0.5...2.0)
                    particles[index].opacity *= 0.98
                    
                    if particles[index].position.y < -10 || particles[index].opacity < 0.1 {
                        particles[index] = Particle(
                            position: CGPoint(
                                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                                y: UIScreen.main.bounds.height + 10
                            ),
                            size: CGFloat.random(in: 1...4),
                            color: [Color.blue, Color.purple, Color.white, Color.cyan].randomElement() ?? Color.white,
                            opacity: Double.random(in: 0.3...0.8)
                        )
                    }
                }
            }
        }
    }
}

struct Particle {
    var position: CGPoint
    var size: CGFloat
    var color: Color
    var opacity: Double
}

