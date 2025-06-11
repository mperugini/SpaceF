//
//  ButtonStyles.swift
//  SpaceF
//
//  Created by Mariano Perugini on 11/06/2025.
//

import SwiftUI

struct PulsatingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
