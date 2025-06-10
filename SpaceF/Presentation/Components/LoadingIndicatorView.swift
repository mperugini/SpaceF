//
//  LoadingIndicatorView.swift
//  SpaceF
//
//  Created by Mariano Perugini on 04/06/2025.
//

import SwiftUI

struct LoadingIndicatorView: View {
    var body: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            Text("Actualizando...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 20)
    }
}
