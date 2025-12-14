import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/data/repositories/receta_repository.dart';
import 'package:migaz/viewmodels/base_viewmodel.dart';

class BibliotecaViewModel extends BaseViewModel {
  final RecetaRepository _recetaRepository;

  // Listas de datos
  List<Recipe> _misRecetas = [];
  List<Recipe> _recetasGuardadas =
      []; // Por si quieres añadir la tab de guardados aquí

  // Getters
  List<Recipe> get misRecetas => _misRecetas;
  List<Recipe> get recetasGuardadas => _recetasGuardadas;

  // Constructor
  BibliotecaViewModel({RecetaRepository? recetaRepository})
    : _recetaRepository = recetaRepository ?? RecetaRepository();

  /// Carga inicial de datos
  Future<void> cargarDatos(String usuarioId) async {
    if (usuarioId.isEmpty) return;

    // Usamos runAsync (de tu BaseViewModel) para manejar loading/error auto
    await runAsync(() async {
      // 1. Cargar recetas creadas por el usuario
      final recetas = await _recetaRepository.obtenerPorUsuario(usuarioId);

      // Ordenar por fecha (más nuevas primero)
      recetas.sort((a, b) {
        final fechaA = a.fechaCreacion ?? DateTime(2000);
        final fechaB = b.fechaCreacion ?? DateTime(2000);
        return fechaB.compareTo(fechaA);
      });

      _misRecetas = recetas;

      // Aquí podrías cargar también las guardadas si quisieras
      _recetasGuardadas = _recetasGuardadas;
    }, errorPrefix: 'Error al cargar tu biblioteca');
  }

  /// Método público para refrescar manualmente
  Future<void> refrescar(String usuarioId) async {
    await cargarDatos(usuarioId);
  }
}
