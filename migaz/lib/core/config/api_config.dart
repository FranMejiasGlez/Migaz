import 'dart:io';
import 'package:flutter/foundation.dart'; // Necesario para kIsWeb

class ApiConfig {
  // 1. Detectamos dinámicamente el host correcto
  static String get _host {
    if (kIsWeb) {
      return 'localhost';
    } else if (Platform.isAndroid) {
      return '10.0.2.2';
    } else {
      return 'localhost'; // iOS u otros
    }
  }

  // 2. Definimos la URL base del servidor usando el host dinámico
  static String get serverUrl => 'http://$_host:3000';

  // 3. URL de la API (Aquí es donde añadimos '/api')
  static String get baseUrl => '$serverUrl/api';

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

  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> get multipartHeaders => {
    'Accept': 'application/json',
  };

  static const String currentUser = "MojonPeinao";

  // ✅ MÉTODO CLAVE: Generador de URLs de imágenes centralizado
  static String getImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';

    // Si ya viene con http (imágenes externas), se devuelve tal cual
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    // Tu JSON devuelve algo como: "img/693fd...jpeg"
    // Tu API espera: "http://HOST:3000/api/img/693fd...jpeg"
    // Por tanto, usamos baseUrl (que ya acaba en /api) + / + la ruta

    // Limpieza: Aseguramos que no haya doble barra //
    final cleanPath = imagePath.startsWith('/')
        ? imagePath.substring(1)
        : imagePath;

    // Resultado: http://10.0.2.2:3000/api/img/foto.jpg
    return '$baseUrl/$cleanPath';
  }
}
