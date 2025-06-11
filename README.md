# Space Flight News 🚀

Una aplicación iOS nativa desarrollada en SwiftUI que permite explorar las últimas noticias de vuelos espaciales utilizando la API de Space Flight News.

<p align="center">
  <img src="https://github.com/user-attachments/assets/55cba73b-3df5-4dd3-8b24-b4372099e377" width="200"/>
  <img src="https://github.com/user-attachments/assets/addee68f-902b-4ed5-a68b-e3a9e276e25f" width="200"/>
  <img src="https://github.com/user-attachments/assets/b27df9f7-91f7-41fa-a40a-dde2dbee1d65" width="200"/>
  <img src="https://github.com/user-attachments/assets/61dc58f5-c584-41c3-a570-39177f1a3faa" width="200"/>
</p>


## 📱 Funcionalidades

- **Listado de artículos**: Visualización de los últimos artículos de noticias espaciales
- **Búsqueda**: Campo de búsqueda para filtrar artículos por términos específicos
- **Detalle de artículo**: Vista completa del artículo seleccionado
- **Soporte de rotación**: Todas las pantallas mantienen su estado al rotar el dispositivo
- **Tema espacial**: Interfaz oscura optimizada para la temática espacial

## 🏗️ Arquitectura

La aplicación implementa **Clean Architecture** con los siguientes componentes:

### Capas de la Arquitectura
- **Presentation Layer**: ViewModels y Views (SwiftUI)
- **Domain Layer**: Use Cases y Protocols
- **Data Layer**: Repositories, Data Sources (Remote/Local)

### Patrones Implementados
- **MVVM**: Model-View-ViewModel para la capa de presentación
- **Repository Pattern**: Abstracción del acceso a datos
- **Dependency Injection**: Container personalizado para gestión de dependencias
- **Use Cases**: Lógica de negocio encapsulada

## 📁 Estructura del Proyecto

```
SpaceF/
├── App/
│   ├── SpaceFApp.swift
│   ├── RootAppView.swift
│   └── DependencyContainer.swift
├── Core/
│   ├── AppConfig.swift
│   ├── AppError.swift
│   └── URLSecurity.swift
├── Domain/
│   ├── Models/
│   ├── UseCases/
│   └── Repositories/
├── Data/
│   ├── DataSources/
│   ├── Repositories/
│   └── Models/
└── Presentation/
    ├── Views/
    └── ViewModels/
```

## 🔧 Configuración y Setup

### Requisitos
- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

### Instalación
1. Clona el repositorio:
```bash
git clone https://github.com/tuusuario/SpaceF.git
```

2. Abre el proyecto en Xcode:
```bash
cd SpaceF
open SpaceF.xcodeproj
```

3. Compila y ejecuta el proyecto (⌘+R)

No requiere configuración adicional ni API keys - utiliza la API pública de Space Flight News.

## 🌐 API Integration

La aplicación consume la **Space Flight News API v4**:
- **Base URL**: `https://api.spaceflightnewsapi.net/v4`
- **Endpoints utilizados**:
  - `GET /articles` - Listado de artículos
  - `GET /articles?search={query}` - Búsqueda de artículos

## 🛡️ Manejo de Errores

### Para Desarrolladores
- **Logging estructurado**: Utiliza `OSLog` para logging categorizado
- **Errores tipados**: Enums específicos para diferentes tipos de errores
- **Error tracking**: Logging con ubicación exacta (archivo, línea, función)

```swift
enum AppError: LocalizedError {
    case network(NetworkError)
    case data(DataError)
    case validation(ValidationError)
    case unexpected(String)
}
```

### Para Usuarios
- **Estados de carga**: Indicadores visuales durante las operaciones
- **Mensajes amigables**: Errores traducidos a español
- **Retry mechanisms**: Opciones para reintentar operaciones fallidas
- **Offline support**: Caché local para uso sin conexión

## 🔒 Seguridad

- **HTTPS enforcement**: Conversión automática de URLs HTTP a HTTPS
- **URL validation**: Validación estricta de URLs de imágenes
- **Trusted domains**: Lista blanca de dominios confiables para imágenes
- **Input sanitization**: Validación de entradas de usuario

## 🎨 Diseño y UX

- **Design System**: Componentes reutilizables y consistentes
- **Tema oscuro**: Optimizado para la temática espacial
- **Responsive**: Layouts adaptativos para diferentes tamaños de pantalla
- **Accessibility**: Soporte para tecnologías de asistencia
- **Smooth animations**: Transiciones fluidas entre pantallas

## 🧪 Testing

### Estrategia de Testing
- **Unit Tests**: Lógica de negocio y Use Cases
- **Integration Tests**: Repositories y Data Sources
- **UI Tests**: Flujos principales de usuario

### Ejecutar Tests
```bash
# Unit tests
⌘+U en Xcode

# Tests específicos
xcodebuild test -scheme SpaceF -destination 'platform=iOS Simulator,name=iPhone 14'
```


## 📱 Compatibilidad

- **iOS Versions**: 15.0+
- **Device Support**: iPhone y iPad
- **Orientations**: Portrait y Landscape
- **Accessibility**: VoiceOver, Dynamic Type

## 🚀 Roadmap

### Próximas Funcionalidades
- [ ] Favoritos offline
- [ ] Notificaciones push
- [ ] Compartir artículos
- [ ] Modo offline mejorado
- [ ] Temas personalizables

### Mejoras Técnicas
- [ ] Core Data migration
- [ ] Background refresh
- [ ] Widget extension

## 📄 Licencia

Este proyecto es desarrollado como parte del challenge técnico de Meli
