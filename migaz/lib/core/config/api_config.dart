import 'dart:io';
import 'package:flutter/foundation.dart'; // Necesario para kIsWeb

class ApiConfig {
  // Permite definir una URL pública (por ejemplo, devtunnels.ms)
  static String? publicServerUrl;

  // Regex para detectar URLs devtunnels.ms o ngrok
  static final RegExp _devTunnelOrNgrokRegex = RegExp(
    r'^(https:\/\/[\w-]+-3000\.\w+\.devtunnels\.ms|https:\/\/[\w-]+\.ngrok(-free)?\.dev)',
  );

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

  // 2. Definimos la URL base del servidor usando el host dinámico o la pública
  static String get serverUrl {
    if (publicServerUrl != null &&
        _devTunnelOrNgrokRegex.hasMatch(publicServerUrl!)) {
      return publicServerUrl!;
    }
    return 'http://$_host:3000';
  }

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

  // Endpoints de Autenticación
  static const String loginEndpoint = '/usuarios/login';
  static const String registroEndpoint = '/usuarios/registro';

  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> get multipartHeaders => {
    'Accept': 'application/json',
  };

  // Usuario actual (Dinámico)
  // Inicialmente vacío, se debe setear al hacer login
  static String currentUser =
      ""; // Se actualiza dinámicamente desde AuthService

  // ✅ MÉTODO CLAVE: Generador de URLs de imágenes centralizado
  static String getImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';

    // Si ya viene con http (imágenes externas), se devuelve tal cual
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    // Tu JSON devuelve algo como: "img/693fd...jpeg"
    // Las imágenes estáticas se sirven desde: "http://HOST:3000/img/693fd...jpeg"
    // NO desde /api/img/...

    // Limpieza: Aseguramos que no haya doble barra //
    final cleanPath = imagePath.startsWith('/')
        ? imagePath.substring(1)
        : imagePath;

    // Resultado: http://10.0.2.2:3000/img/foto.jpg (usando serverUrl, no baseUrl)
    return '$serverUrl/$cleanPath';
  }
}
