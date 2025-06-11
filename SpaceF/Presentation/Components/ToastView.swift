//
//  ToastView.swift
//  SpaceF
//
//  Created by Mariano Perugini on 11/06/2025.
//

import SwiftUI

struct ToastView: View {
    let message: String
    let type: ToastType
    @State private var show = false
    @State private var workItem: DispatchWorkItem?
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.icon)
                .foregroundColor(type.color)
                .font(.system(size: 16, weight: .semibold))
            
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(2)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .scaleEffect(show ? 1.0 : 0.8)
        .opacity(show ? 1.0 : 0.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: show)
        .onAppear {
            show = true
            
            workItem = DispatchWorkItem {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    show = false
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: workItem!)
        }
        .onDisappear {
            workItem?.cancel()
        }
    }
}
