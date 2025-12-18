# Migaz — App de Recetas (Flutter)

Migaz es una aplicación móvil desarrollada con Flutter para gestionar recetas: autenticación (login/registro), CRUD de recetas (con subida de imágenes), comentarios, valoración de recetas y un tema dinámico. El proyecto está pensado para usarse junto a un backend REST (por defecto en el puerto 3000).

> Estado: Proyecto con estructura funcional. Contiene múltiples ViewModels, configuración de rutas, utilidades para conexión con backend y soporte para DevicePreview en desarrollo.

---

## Características principales

- Autenticación: login / registro / sesión persistente.
- Gestión de recetas: crear, leer, actualizar, eliminar (con imágenes).
- Comentarios en recetas.
- Valoración de recetas.
- Biblioteca personal (guardados, mis recetas).
- Tema dinámico (claro/oscuro) manejado por `ThemeViewModel`.
- Soporte para DevicePreview en modo desarrollo (facilita probar diseños y localizaciones).
- Soporte para subir imágenes usando `image_picker`.

---

## Requisitos

- Flutter (versión estable recomendada).
- SDK de Dart (incluido con Flutter).
- Un emulador o dispositivo físico (Android / iOS).
- Backend REST corriendo en http://localhost:3000 o en una URL pública (p. ej. devtunnels / ngrok).

---

## Instalación y ejecución

1. Clonar el repositorio:
   git clone https://github.com/FranMejiasGlez/Migaz.git

2. Abrir la carpeta de la app Flutter:
   cd migaz

3. Instalar dependencias:
   flutter pub get

4. Ejecutar en emulador/dispositivo:
   flutter run

Nota: en la rama principal la app ya usa DevicePreview en desarrollo; para producción DevicePreview está deshabilitado automáticamente.

---

## Configuración del backend (URL pública / local)

La app incluye un helper central `ApiConfig` (migaz/lib/core/config/api_config.dart) que construye las URLs del servidor y de las imágenes:

- Por defecto, `ApiConfig` usa un host dinámico:
  - En Android emulado usa `10.0.2.2` (mapeo a localhost).
  - En iOS / otras plataformas usa `localhost`.
  - En web usa `localhost`.

- Para usar una URL pública (p. ej. devtunnels o ngrok) se puede establecer `ApiConfig.publicServerUrl` en `main.dart`. Ejemplo (en `main()`):
  ApiConfig.publicServerUrl = 'https://<tu-subdominio>-3000.uks1.devtunnels.ms';

  - Importante: la app valida si la URL corresponde a devtunnels o ngrok usando una expresión regular.
  - No incluir la barra final (`/`) en la URL pública.

- `ApiConfig.baseUrl` apunta a la API (p. ej. http://10.0.2.2:3000/api) y `getImageUrl` genera la URL completa para imágenes estáticas (p. ej. http://10.0.2.2:3000/img/foto.jpg). Si las imágenes no cargan, comprueba que el servidor sirva archivos estáticos en `/img` y que la URL pública / local esté bien configurada.

---

## Estructura relevante del repositorio

- migaz/
  - lib/
    - main.dart — Punto de entrada. Configura `ApiConfig.publicServerUrl`, DevicePreview y `MultiProvider`.
    - core/config/
      - api_config.dart — Configuración central de URLs, endpoints y generación de URLs de imagen.
      - routes.dart — Definición de rutas de la aplicación.
    - data/ — Modelos, repositories y services que consumen la API (ej. `AuthService`, `RecetaRepository`).
    - viewmodels/ — Lógica de negocio y estado (Provider / ChangeNotifier).
      - auth_viewmodel.dart — Manejo de sesión, login/registro.
      - recipe_list_viewmodel.dart — Carga, búsqueda, filtros, creación/actualización/eliminación y valoración de recetas.
      - comentario_viewmodel.dart, home_viewmodel.dart, biblioteca_viewmodel.dart, user_viewmodel.dart, theme_viewmodel.dart, base_viewmodel.dart, ...
    - ui/ — Vistas y widgets (pantallas: login, registro, biblioteca, perfil, recetas, configuración, etc).
  - pubspec.yaml — Declaración de dependencias del proyecto.
  - assets/ — Recursos estáticos de la app (iconos, imágenes, etc).

---

## Archivos clave (resumen)

- migaz/lib/main.dart
  - Inicializa `ApiConfig.publicServerUrl` (opcional).
  - Activa DevicePreview solo en modo desarrollo.
  - Registra `MultiProvider` con los ViewModels:
    AuthViewModel, RecipeListViewModel, ComentarioViewModel, HomeViewModel, BibliotecaViewModel, UserViewModel, ThemeViewModel.

- migaz/lib/core/config/api_config.dart
  - Genera `serverUrl` dinámicamente según plataforma.
  - Proporciona `baseUrl`, endpoints (recetas, comentarios, autenticación) y headers.
  - `getImageUrl(imagePath)` construye la URL completa para imágenes (usa `serverUrl` en vez de `baseUrl`).

- migaz/lib/core/config/routes.dart
  - Define rutas y las vistas asociadas (login, register, home, biblioteca, perfil, guardados, misrecetas, configuracion).

- migaz/lib/viewmodels/*
  - Contienen la lógica para interactuar con los repositories/services y actualizar la UI vía Provider.

---

## Cómo contribuir

- Reporta issues para bugs o mejoras en la sección de Issues de GitHub.
- Para nuevas funcionalidades o correcciones:
  - Crea una rama por feature: git checkout -b feat/nueva-funcionalidad
  - Abre un Pull Request con descripción clara y pasos para probar.
- Sigue el estilo del código existente (idioma: español en mensajes y comentarios).

---

## Buenas prácticas / recomendaciones

- Mantener actualizada la variable `ApiConfig.publicServerUrl` si usas túneles públicos (ngrok / devtunnels).
- Si trabajas con Android Emulator recuerda que la app mapea `localhost` al host del emulador usando `10.0.2.2` (esto ya se gestiona en ApiConfig).
- Separar la lógica de UI y de negocio: usar ViewModels y repositories como ya está estructurado.
- Añadir pruebas unitarias y/o de integración para los ViewModels y servicios.

---

## Depuración y problemas comunes

- Error al conectar con el backend:
  - Asegúrate de que el backend está corriendo en el puerto 3000 o usa `ApiConfig.publicServerUrl`.
  - Comprueba CORS y la ruta de los endpoints (la app usa `baseUrl = serverUrl/api`).
- Imágenes que no aparecen:
  - Verifica que el backend sirve las imágenes estáticas bajo la ruta que devuelve el JSON (por ejemplo `img/..`).
  - `ApiConfig.getImageUrl` espera rutas relativas como `img/xx.jpg` y las transforma a `http://HOST:3000/img/xx.jpg`.
- DevicePreview activo en desarrollo: si quieres deshabilitarlo para probar comportamiento de producción, comenta o cambia `enabled: !kReleaseMode` en `main.dart`.

---

## Changelog

Consultar CHANGELOG.md en la raíz para versiones y cambios históricos.

---

## Licencia y contacto

- Añade aquí la licencia del proyecto (si procede).
- Autor / contacto: FranMejiasGlez, Andy Jan, Pablo Jimenez, Javier Fernandez.
