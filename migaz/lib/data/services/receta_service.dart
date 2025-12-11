import 'dart:io';
import 'package:migaz/core/config/api_config.dart';
import 'package:migaz/data/services/api_service.dart';

class RecetaService {
  final ApiService _apiService;

  RecetaService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  /// Obtener todas las recetas
  Future<List<dynamic>> obtenerTodas() async {
    final response = await _apiService.get(ApiConfig.recetasEndpoint);
    return response as List<dynamic>;
  }

  /// Obtener receta por ID
  Future<Map<String, dynamic>> obtenerPorId(String id) async {
    final response = await _apiService.get(ApiConfig.recetaByIdEndpoint(id));
    return response as Map<String, dynamic>;
  }

  /// Crear nueva receta (con imágenes)
  Future<Map<String, dynamic>> crear({
    required String nombre,
    required String categoria,
    required String descripcion,
    required String dificultad,
    required String tiempo,
    required int servings,
    required List<String> pasos,
    required List<String> ingredientes,
    List<File>? imagenes,
  }) async {
    final fields = {
      'nombre': nombre,
      'categoria': categoria,
      'descripcion': descripcion,
      'dificultad': dificultad,
      'tiempo': tiempo,
      'servings': servings.toString(),
      'pasos': pasos.join(','), // ajusta según tu API
      'ingredientes': ingredientes.join(','), // ajusta según tu API
    };

    final response = await _apiService.postMultipart(
      ApiConfig.recetasEndpoint,
      fields,
      imagenes,
    );
    return response as Map<String, dynamic>;
  }

  /// Actualizar receta
  Future<Map<String, dynamic>> actualizar({
    required String id,
    required Map<String, String> campos,
    List<File>? imagenes,
  }) async {
    final response = await _apiService.putMultipart(
      ApiConfig.recetaByIdEndpoint(id),
      campos,
      imagenes,
    );
    return response as Map<String, dynamic>;
  }

  /// Eliminar receta
  Future<void> eliminar(String id) async {
    await _apiService.delete(ApiConfig.recetaByIdEndpoint(id));
  }

  /// Valorar receta
  Future<Map<String, dynamic>> valorar(String id, double valoracion) async {
    final response = await _apiService.post(
      ApiConfig.valorarRecetaEndpoint(id),
      {'valoracion': valoracion},
    );
    return response as Map<String, dynamic>;
  }
}
