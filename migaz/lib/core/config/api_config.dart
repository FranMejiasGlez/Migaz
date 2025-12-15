class ApiConfig {
  // 🔧 URL base del servidor (sin /api)
  static const String serverUrl = 'http://localhost:3000';

  // 🔧 URL de la API
  static const String baseUrl = '$serverUrl/api';

  // 🔧 URL para imágenes
  static const String imageUrl = '$serverUrl/img';

  // Endpoints de Recetas
  static const String recetasEndpoint = '/recetas';
  static String recetaByIdEndpoint(String id) => '/recetas/$id';
  static String valorarRecetaEndpoint(String id) => '/recetas/$id/valorar';
  static const String recetasMasValoradasEndpoint = '/recetas/mas-valoradas';
  static const String recetasMasNuevasEndpoint = '/recetas/mas-nuevas';
  static String recetasByUserEndPoint(String id) => '/recetas/$id';

  // Endpoints de Comentarios
  static const String comentariosEndpoint = '/comentarios';
  static String comentariosByRecetaEndpoint(String recetaId) =>
      '/comentarios/receta/$recetaId';
  static String comentarioByIdEndpoint(String id) => '/comentarios/$id';

  // Headers comunes
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers para multipart (con imágenes)
  static Map<String, String> get multipartHeaders => {
    'Accept': 'application/json',
  };

  //Usuarios estaticos
  static String currentUser = "Cocinero Experto";

  // ✅ NUEVO: Helper para construir URLs de imágenes
  static String getImageUrl(String imagePath) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    // Si la ruta empieza con /img, usar serverUrl
    if (imagePath.startsWith('/img/')) {
      return '$serverUrl$imagePath';
    }
    // Si solo es el nombre del archivo, agregar /img/
    return '$imageUrl/$imagePath';
  }
}
