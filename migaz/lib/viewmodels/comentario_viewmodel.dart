import 'package:migaz/data/models/comentario.dart';
import 'package:migaz/data/repositories/comentario_repository.dart';
import 'package:migaz/viewmodels/base_viewmodel.dart';

class ComentarioViewModel extends BaseViewModel {
  final ComentarioRepository _comentarioRepository;

  List<Comentario> _comentarios = [];

  ComentarioViewModel({ComentarioRepository? comentarioRepository})
    : _comentarioRepository = comentarioRepository ?? ComentarioRepository();

  List<Comentario> get comentarios => _comentarios;

  /// Cargar comentarios de una receta
  Future<void> cargarComentarios(String recetaId) async {
    await runAsync(() async {
      _comentarios = await _comentarioRepository.obtenerDeReceta(recetaId);
    }, errorPrefix: 'Error al cargar comentarios');
  }

  /// Crear comentario
  Future<bool> crearComentario({
    required String recetaId,
    required String texto,
    required String usuario,
  }) async {
    final result = await runAsync(() async {
      final nuevoComentario = await _comentarioRepository.crear(
        recetaId: recetaId,
        texto: texto,
        usuario: usuario,
      );
      _comentarios.add(nuevoComentario);
      return true;
    }, errorPrefix: 'Error al crear comentario');

    return result ?? false;
  }

  /// Editar comentario
  Future<bool> editarComentario(String id, String nuevoTexto) async {
    final result = await runAsync(() async {
      final comentarioEditado = await _comentarioRepository.editar(
        id,
        nuevoTexto,
      );

      final index = _comentarios.indexWhere((c) => c.id == id);
      if (index != -1) {
        _comentarios[index] = comentarioEditado;
      }
      return true;
    }, errorPrefix: 'Error al editar comentario');

    return result ?? false;
  }

  /// Eliminar comentario
  Future<bool> eliminarComentario(String id) async {
    final result = await runAsync(() async {
      await _comentarioRepository.eliminar(id);
      _comentarios.removeWhere((c) => c.id == id);
      return true;
    }, errorPrefix: 'Error al eliminar comentario');

    return result ?? false;
  }
}
