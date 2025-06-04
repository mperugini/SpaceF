import Foundation
import OSLog

enum AppError: LocalizedError {
    case network(NetworkError)
    case data(DataError)
    case validation(ValidationError)
    case unexpected(String)
    
    var errorDescription: String? {
        switch self {
        case .network(let error):
            return "Error de red: \(error.localizedDescription)"
        case .data(let error):
            return "Error de datos: \(error.localizedDescription)"
        case .validation(let error):
            return "Error de validación: \(error.localizedDescription)"
        case .unexpected(let message):
            return "Error inesperado: \(message)"
        }
    }
    
    var errorCode: Int {
        switch self {
        case .network: return 1000
        case .data: return 2000
        case .validation: return 3000
        case .unexpected: return 9999
        }
    }
}

enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    case timeout
    case noInternetConnection
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .noData:
            return "No se recibieron datos"
        case .decodingError:
            return "Error al procesar los datos"
        case .serverError(let message):
            return "Error del servidor: \(message)"
        case .timeout:
            return "La solicitud ha expirado"
        case .noInternetConnection:
            return "No hay conexión a internet"
        }
    }
}

enum DataError: LocalizedError {
    case saveFailed
    case loadFailed
    case deleteFailed
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Error al guardar los datos"
        case .loadFailed:
            return "Error al cargar los datos"
        case .deleteFailed:
            return "Error al eliminar los datos"
        case .invalidData:
            return "Datos inválidos"
        }
    }
}

enum ValidationError: LocalizedError {
    case invalidInput(String)
    case requiredField(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidInput(let field):
            return "Entrada inválida en \(field)"
        case .requiredField(let field):
            return "El campo \(field) es requerido"
        }
    }
}

// Logger para la aplicación
struct AppLogger {
    static let shared = AppLogger()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.spacef", category: "App")
    
    func error(_ error: Error, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        logger.error("\(fileName):\(line) - \(function) - \(error.localizedDescription)")
    }
    
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        logger.info("\(fileName):\(line) - \(function) - \(message)")
    }
    
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        logger.debug("\(fileName):\(line) - \(function) - \(message)")
    }
} 