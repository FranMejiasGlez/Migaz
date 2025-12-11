import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/data/repositories/receta_repository.dart';
import 'package:migaz/viewmodels/base_viewmodel.dart';

class HomeViewModel extends BaseViewModel {
  final RecetaRepository _recetaRepository;

  List<Recipe> _recetasMasValoradas = [];
  List<Recipe> _recetasMasNuevas = [];

  HomeViewModel({RecetaRepository? recetaRepository})
    : _recetaRepository = recetaRepository ?? RecetaRepository();

  // Getters
  List<Recipe> get recetasMasValoradas => _recetasMasValoradas;
  List<Recipe> get recetasMasNuevas => _recetasMasNuevas;

  bool get tieneRecetas =>
      _recetasMasValoradas.isNotEmpty || _recetasMasNuevas.isNotEmpty;

  /// Cargar recetas más valoradas
  Future<void> cargarRecetasMasValoradas({int limit = 10}) async {
    await runAsync(() async {
      _recetasMasValoradas = await _recetaRepository.obtenerMasValoradas(
        limit: limit,
      );
    }, errorPrefix: 'Error al cargar recetas más valoradas');
  }

  /// Cargar recetas más nuevas
  Future<void> cargarRecetasMasNuevas({int limit = 10}) async {
    await runAsync(() async {
      _recetasMasNuevas = await _recetaRepository.obtenerMasNuevas(
        limit: limit,
      );
    }, errorPrefix: 'Error al cargar recetas más nuevas');
  }

  /// Cargar todas las secciones de home
  Future<void> cargarHome() async {
    await runAsync(() async {
      // Cargar ambas listas en paralelo
      await Future.wait([
        _recetaRepository
            .obtenerMasValoradas(limit: 5)
            .then((recetas) => _recetasMasValoradas = recetas),
        _recetaRepository
            .obtenerMasNuevas(limit: 5)
            .then((recetas) => _recetasMasNuevas = recetas),
      ]);
    }, errorPrefix: 'Error al cargar la pantalla de inicio');
  }

  /// Refrescar home
  Future<void> refrescarHome() async {
    clearError();
    await cargarHome();
  }

  /// Valorar una receta y actualizar la lista
  Future<bool> valorarReceta(String id, double valoracion) async {
    final result = await runAsync(() async {
      final recetaValorada = await _recetaRepository.valorar(id, valoracion);

      // Actualizar en la lista de más valoradas si existe
      final indexValoradas = _recetasMasValoradas.indexWhere((r) => r.id == id);
      if (indexValoradas != -1) {
        _recetasMasValoradas[indexValoradas] = recetaValorada;
      }

      // Actualizar en la lista de más nuevas si existe
      final indexNuevas = _recetasMasNuevas.indexWhere((r) => r.id == id);
      if (indexNuevas != -1) {
        _recetasMasNuevas[indexNuevas] = recetaValorada;
      }

      return true;
    }, errorPrefix: 'Error al valorar receta');

    return result ?? false;
  }
}
