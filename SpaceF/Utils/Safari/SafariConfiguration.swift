//
//  SafariConfiguration.swift
//  SpaceF
//
//  Created by Mariano Perugini on 10/06/2025.
//

import SwiftUI
import SafariServices

// MARK: - Custom Safari Configuration
struct SafariConfiguration {
    let entersReaderIfAvailable: Bool
    let barCollapsingEnabled: Bool
    let barTintColor: UIColor?
    let controlTintColor: UIColor?
    let dismissButtonStyle: SFSafariViewController.DismissButtonStyle
    
    init(
        entersReaderIfAvailable: Bool = false,
        barCollapsingEnabled: Bool = true,
        barTintColor: UIColor? = nil,
        controlTintColor: UIColor? = nil,
        dismissButtonStyle: SFSafariViewController.DismissButtonStyle = .done
    ) {
        self.entersReaderIfAvailable = entersReaderIfAvailable
        self.barCollapsingEnabled = barCollapsingEnabled
        self.barTintColor = barTintColor
        self.controlTintColor = controlTintColor
        self.dismissButtonStyle = dismissButtonStyle
    }
}

// MARK: - Predefined Configurations
extension SafariConfiguration {
    static let spaceTheme = SafariConfiguration(
        entersReaderIfAvailable: true,
        barCollapsingEnabled: true,
        barTintColor: UIColor.systemBackground,
        controlTintColor: UIColor.systemBlue,
        dismissButtonStyle: .done
    )
    
    static let darkTheme = SafariConfiguration(
        entersReaderIfAvailable: true,
        barCollapsingEnabled: true,
        barTintColor: UIColor.black,
        controlTintColor: UIColor.white,
        dismissButtonStyle: .done
    )
    
    static let lightTheme = SafariConfiguration(
        entersReaderIfAvailable: false,
        barCollapsingEnabled: true,
        barTintColor: UIColor.white,
        controlTintColor: UIColor.systemBlue,
        dismissButtonStyle: .done
    )
    
    static let minimal = SafariConfiguration(
        entersReaderIfAvailable: false,
        barCollapsingEnabled: false,
        barTintColor: nil,
        controlTintColor: nil,
        dismissButtonStyle: .close
    )
}
