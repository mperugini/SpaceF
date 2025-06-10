//
//  AppConfig.swift
//  SpaceF
//
//  Created by Mariano Perugini on 10/06/2025.
//

import Foundation

struct AppConfig {
    static let baseURL = "https://api.spaceflightnewsapi.net/v4"
    static let defaultLimit = 10
    static let maxLimit = 100
    static let minSearchCharacters = 3
    static let cacheExpirationTime: TimeInterval = 3600 // 1 hora
    
    // Environment specific configurations
    struct Environment {
        static var current: EnvironmentType {
            #if DEBUG
            return .development
            #else
            return .production
            #endif
        }
    }
    
    enum EnvironmentType {
        case development
        case production
        
        var isDebug: Bool {
            switch self {
            case .development:
                return true
            case .production:
                return false
            }
        }
    }
}
