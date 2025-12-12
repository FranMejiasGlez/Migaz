import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:migaz/core/config/api_config.dart';
import 'package:migaz/data/services/api_service.dart';

class RecetaService {
  final ApiService _apiService;

  RecetaService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  Future<List<dynamic>> obtenerTodas() async {
    final response = await _apiService.get(ApiConfig.recetasEndpoint);
    return response as List<dynamic>;
  }

  Future<List<dynamic>> obtenerMasValoradas({int limit = 10}) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.recetasMasValoradasEndpoint}?limit=$limit',
      );
      return response as List<dynamic>;
    } catch (e) {
      final response = await _apiService.get(ApiConfig.recetasEndpoint);
      final List<dynamic> recetas = response as List<dynamic>;

      recetas.sort(
        (a, b) => ((b['promedio'] ?? 0) as num).compareTo(
          (a['promedio'] ?? 0) as num,
        ),
      );

      return recetas.take(limit).toList();
    }
  }

  Future<List<dynamic>> obtenerMasNuevas({int limit = 10}) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.recetasMasNuevasEndpoint}?limit=$limit',
      );
      return response as List<dynamic>;
    } catch (e) {
      final response = await _apiService.get(ApiConfig.recetasEndpoint);
      final List<dynamic> recetas = response as List<dynamic>;

      recetas.sort((a, b) {
        final fechaA =
            DateTime.tryParse(a['createdAt']?.toString() ?? '') ??
            DateTime(1970);
        final fechaB =
            DateTime.tryParse(b['createdAt']?.toString() ?? '') ??
            DateTime(1970);
        return fechaB.compareTo(fechaA);
      });

      return recetas.take(limit).toList();
    }
  }

  Future<List<dynamic>> obtenerPorUsuario(String usuario) async {
    try {
      print('🔥 DEBUG - Obteniendo recetas del usuario: $usuario');
      final response = await _apiService.get(
        ApiConfig.recetasByUserEndPoint(usuario),
      );
      print(
        '✅ DEBUG - Recetas del usuario obtenidas: ${(response as List).length}',
      );
      return response as List<dynamic>;
    } catch (e) {
      print(
        '⚠️ DEBUG - Endpoint de usuario no disponible, filtrando localmente',
      );
      final response = await _apiService.get(ApiConfig.recetasEndpoint);
      final List<dynamic> recetas = response as List<dynamic>;

      final recetasUsuario = recetas.where((receta) {
        return receta['user']?.toString().toLowerCase() ==
            usuario.toLowerCase();
      }).toList();

      print('✅ DEBUG - Recetas filtradas localmente: ${recetasUsuario.length}');
      return recetasUsuario;
    }
  }

  Future<Map<String, dynamic>> obtenerPorId(String id) async {
    final response = await _apiService.get(ApiConfig.recetaByIdEndpoint(id));
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> crear({
    required String nombre,
    required String categoria,
    required String descripcion,
    required int dificultad,
    required String tiempo,
    required int comensales,
    required List<String> instrucciones,
    required List<String> ingredientes,
    required String user,
    String? youtube,
    List<File>? imagenes,
    List<XFile>? imagenesXFile,
  }) async {
    final datos = {
      'nombre': nombre,
      'categoria': categoria.toLowerCase(),
      'descripcion': descripcion,
      'dificultad': dificultad,
      'tiempo': tiempo,
      'comensales': comensales,
      'instrucciones': instrucciones,
      'ingredientes': ingredientes,
      'user': user,
      if (youtube != null && youtube.isNotEmpty) 'youtube': youtube,
    };

    print('📝 DEBUG - Datos a enviar: $datos');
    print(
      '📝 DEBUG - Imágenes: ${kIsWeb ? imagenesXFile?.length : imagenes?.length}',
    );

    final response = await _apiService.postMultipartWithJson(
      ApiConfig.recetasEndpoint,
      datos,
      kIsWeb ? imagenesXFile : imagenes,
    );

    return response as Map<String, dynamic>;
  }

  // ✅ CORREGIDO: Método completo para actualizar con todos los campos
  Future<Map<String, dynamic>> actualizar({
    required String id,
    required String nombre,
    required String categoria,
    required String descripcion,
    required int dificultad,
    required String tiempo,
    required int comensales,
    required List<String> instrucciones,
    required List<String> ingredientes,
    String? youtube,
    List<File>? imagenes,
    List<XFile>? imagenesXFile,
    List<String>? imagenesPrevias,
  }) async {
    print('📝 DEBUG ACTUALIZAR - ID: $id');
    print('📝 DEBUG ACTUALIZAR - Nombre: $nombre');
    print('📝 DEBUG ACTUALIZAR - Categoría: $categoria');
    print(
      '📝 DEBUG ACTUALIZAR - Imágenes nuevas: ${kIsWeb ? imagenesXFile?.length ?? 0 : imagenes?.length ?? 0}',
    );
    print(
      '📝 DEBUG ACTUALIZAR - Imágenes previas: ${imagenesPrevias?.length ?? 0}',
    );

    final datos = {
      'nombre': nombre,
      'categoria': categoria.toLowerCase(),
      'descripcion': descripcion,
      'dificultad': dificultad,
      'tiempo': tiempo,
      'comensales': comensales,
      'instrucciones': instrucciones,
      'ingredientes': ingredientes,
      if (youtube != null && youtube.isNotEmpty) 'youtube': youtube,
      if (imagenesPrevias != null && imagenesPrevias.isNotEmpty)
        'imagenesPrevias': imagenesPrevias,
    };

    final response = await _apiService.putMultipartWithJson(
      ApiConfig.recetaByIdEndpoint(id),
      datos,
      kIsWeb ? imagenesXFile : imagenes,
    );

    print('✅ DEBUG ACTUALIZAR - Respuesta recibida');
    return response as Map<String, dynamic>;
  }

  Future<void> eliminar(String id) async {
    await _apiService.delete(ApiConfig.recetaByIdEndpoint(id));
  }

  Future<Map<String, dynamic>> valorar(
    String id,
    double puntuacion,
    String usuario,
  ) async {
    final response = await _apiService.post(
      ApiConfig.valorarRecetaEndpoint(id),
      {'user': usuario, 'puntuacion': puntuacion},
    );
    return response as Map<String, dynamic>;
  }
}
