class ApiConfig {
  // 🔧 CAMBIA ESTA URL POR LA DE TU API
  static const String baseUrl = 'http://localhost:3000/api';

  // Endpoints de Recetas
  static const String recetasEndpoint = '/recetas';
  static String recetaByIdEndpoint(String id) => '/recetas/$id';
  static String valorarRecetaEndpoint(String id) => '/recetas/$id/valorar';

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
}
