// lib/data/services/comentario_service.dart
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
    final data = {'usuario': usuario, 'receta': recetaId, 'contenido': texto};

    print('📤 DEBUG - Enviando comentario: ');
    print('   recetaId: $recetaId');
    print('   texto: $texto');
    print('   usuario: $usuario');
    print('   Data completa: $data');

    try {
      final response = await _apiService.post(
        ApiConfig.comentariosEndpoint,
        data,
      );

      print('✅ DEBUG - Respuesta del servidor:  $response');
      return response as Map<String, dynamic>;
    } catch (e) {
      print('❌ DEBUG - Error al crear comentario: $e');
      rethrow;
    }
  }

  /// Obtener comentarios de una receta
  Future<List<dynamic>> obtenerDeReceta(String recetaId) async {
    try {
      final response = await _apiService.get(
        ApiConfig.comentariosByRecetaEndpoint(recetaId),
      );
      return response as List<dynamic>;
    } catch (e) {
      print('❌ DEBUG - Error al obtener comentarios: $e');
      rethrow;
    }
  }

  /// Editar comentario
  Future<Map<String, dynamic>> editar(String id, String nuevoTexto) async {
    final response = await _apiService.put(
      ApiConfig.comentarioByIdEndpoint(id),
      {'texto': nuevoTexto, 'msg': nuevoTexto}, // ✅ AÑADIDO msg
    );
    return response as Map<String, dynamic>;
  }

  /// Eliminar comentario
  Future<void> eliminar(String id) async {
    await _apiService.delete(ApiConfig.comentarioByIdEndpoint(id));
  }
}
