//
//  ImagePlaceholder.swift
//  SpaceF
//
//  Created by Mariano Perugini on 04/06/2025.
//

import SwiftUI

struct ImagePlaceholder: View {
    let isError: Bool
    
    var body: some View {
        Rectangle()
            .fill(Color(.systemGray6))
            .frame(height: 220)
            .overlay(
                VStack(spacing: 8) {
                    if isError {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .overlay(
                                VStack(spacing: 8) {
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                    Text("Imagen no disponible")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            )
                    } else {
                        ProgressView()
                            .controlSize(.extraLarge)
                            .scaleEffect(1.2)
                    }
                }
            )
    }
}
