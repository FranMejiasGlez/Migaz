import 'package:migaz/data/models/comentario.dart';
import 'package:migaz/data/services/comentario_service.dart';

class ComentarioRepository {
  final ComentarioService _comentarioService;

  ComentarioRepository({ComentarioService? comentarioService})
    : _comentarioService = comentarioService ?? ComentarioService();

  /// Crear comentario
  Future<Comentario> crear({
    required String recetaId,
    required String texto,
    required String usuario,
  }) async {
    try {
      final json = await _comentarioService.crear(
        recetaId: recetaId,
        texto: texto,
        usuario: usuario,
      );
      return Comentario.fromJson(json);
    } catch (e) {
      throw Exception('Error al crear comentario: $e');
    }
  }

  /// Obtener comentarios de una receta
  Future<List<Comentario>> obtenerDeReceta(String recetaId) async {
    try {
      final jsonList = await _comentarioService.obtenerDeReceta(recetaId);
      return jsonList.map((json) => Comentario.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener comentarios: $e');
    }
  }

  /// Editar comentario
  Future<Comentario> editar(String id, String nuevoTexto) async {
    try {
      final json = await _comentarioService.editar(id, nuevoTexto);
      return Comentario.fromJson(json);
    } catch (e) {
      throw Exception('Error al editar comentario: $e');
    }
  }

  /// Eliminar comentario
  Future<void> eliminar(String id) async {
    try {
      await _comentarioService.eliminar(id);
    } catch (e) {
      throw Exception('Error al eliminar comentario:  $e');
    }
  }
}
