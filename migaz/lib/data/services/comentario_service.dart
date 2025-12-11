import 'package:migaz/core/config/api_config.dart';
import 'package:migaz/data/services/api_service.dart';

class ComentarioService {
  final ApiService _apiService;

  ComentarioService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  /// Crear comentario
  Future<Map<String, dynamic>> crear({
    required String recetaId,
    required String texto,
    required String usuario,
  }) async {
    final data = {'recetaId': recetaId, 'texto': texto, 'usuario': usuario};

    final response = await _apiService.post(
      ApiConfig.comentariosEndpoint,
      data,
    );
    return response as Map<String, dynamic>;
  }

  /// Obtener comentarios de una receta
  Future<List<dynamic>> obtenerDeReceta(String recetaId) async {
    final response = await _apiService.get(
      ApiConfig.comentariosByRecetaEndpoint(recetaId),
    );
    return response as List<dynamic>;
  }

  /// Editar comentario
  Future<Map<String, dynamic>> editar(String id, String nuevoTexto) async {
    final response = await _apiService.put(
      ApiConfig.comentarioByIdEndpoint(id),
      {'texto': nuevoTexto},
    );
    return response as Map<String, dynamic>;
  }

  /// Eliminar comentario
  Future<void> eliminar(String id) async {
    await _apiService.delete(ApiConfig.comentarioByIdEndpoint(id));
  }
}
