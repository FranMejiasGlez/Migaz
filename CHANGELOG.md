# Changelog

Todos los cambios notables en este proyecto serán documentados en este archivo.

## [1.0.0] - 2025-12-10

### Agregado

#### Migración de Código
- Migración completa del código fuente desde [PROYECTO_APP_RECETAS](https://github.com/FranMejiasGlez/PROYECTO_APP_RECETAS)
- 24 archivos Dart migrados desde el proyecto original
- Actualización de todas las importaciones de `app_recetas` a `migaz`

#### Arquitectura MVVM
- Implementación completa del patrón arquitectónico MVVM
- Creación de estructura de carpetas siguiendo principios MVVM:
  - `lib/models/` - Clases de dominio
  - `lib/viewmodels/` - ViewModels con lógica de negocio
  - `lib/views/` - Pantallas de presentación
  - `lib/services/` - Servicios (API, BD, etc.)
  - `lib/repositories/` - Abstracciones de datos
  - `lib/widgets/` - Componentes reutilizables
  - `lib/utils/` - Utilidades y constantes
  - `lib/config/` - Configuración de la aplicación

#### ViewModels
- `BaseViewModel`: Clase base con gestión de estado común
  - Manejo de loading states
  - Manejo de errores
  - Método helper `runAsync` para operaciones asíncronas
- `RecipeListViewModel`: Gestión de lista de recetas
  - Búsqueda de recetas
  - Filtrado por categoría
  - Gestión de recetas del usuario
- `AuthViewModel`: Gestión de autenticación
  - Login de usuarios
  - Registro de usuarios
  - Logout
  - Gestión de credenciales

#### Views Refactorizadas
- `PantallaRecetas`: Refactorizada para usar `RecipeListViewModel`
  - Eliminada lógica de negocio del widget
  - Implementado patrón Consumer/Provider
  - Estado gestionado completamente por el ViewModel

#### Testing
- Tests unitarios para `RecipeListViewModel` (13 tests)
  - Tests de estado inicial
  - Tests de filtrado y búsqueda
  - Tests de gestión de recetas
  - Tests de notificaciones
- Tests unitarios para `AuthViewModel` (14 tests)
  - Tests de autenticación
  - Tests de gestión de credenciales
  - Tests de estados de loading y error
  - Tests de logout

#### Dependencias
- `provider: ^6.1.2` - Gestión de estado para MVVM
- `http: ^1.2.1` - Cliente HTTP
- `path_provider: ^2.1.5` - Acceso al sistema de archivos
- `cupertino_icons: ^1.0.8` - Iconos iOS

#### Documentación
- README.md completo con:
  - Descripción de la arquitectura MVVM
  - Estructura del proyecto
  - Guía de instalación y ejecución
  - Documentación de testing
  - Notas de migración
  - Breaking changes
- CHANGELOG.md para seguimiento de cambios

### Modificado
- `main.dart`: Actualizado para usar `MultiProvider` con ViewModels
- `pubspec.yaml`: Agregadas dependencias necesarias
- Todas las importaciones actualizadas de `app_recetas` a `migaz`
- Estructura de carpetas reorganizada según MVVM

### Notas de Compatibilidad
- Package name cambiado de `app_recetas` a `migaz`
- Los widgets que antes usaban `setState` ahora usan ViewModels
- La gestión de estado requiere `Provider` configurado en `main.dart`

### Breaking Changes
- Las importaciones absolutas deben usar `package:migaz/` en lugar de `package:app_recetas/`
- Los StatefulWidgets con lógica de negocio fueron convertidos a usar ViewModels
- La estructura de carpetas cambió: `lib/model/` → `lib/models/`, `lib/screens/` → `lib/views/`

---

## Formato

Este changelog sigue el formato de [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/lang/es/).
