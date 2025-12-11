import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/data/repositories/receta_repository.dart';
import 'package:migaz/viewmodels/base_viewmodel.dart';

class HomeViewModel extends BaseViewModel {
  final RecetaRepository _recetaRepository;

  List<Recipe> _recetasMasValoradas = [];
  List<Recipe> _recetasMasNuevas = [];
  List<Recipe> _todasLasRecetas = [];

  HomeViewModel({RecetaRepository? recetaRepository})
    : _recetaRepository = recetaRepository ?? RecetaRepository();

  // Getters
  List<Recipe> get recetasMasValoradas => _recetasMasValoradas;
  List<Recipe> get recetasMasNuevas => _recetasMasNuevas;
  List<Recipe> get todasLasRecetas => _todasLasRecetas;

  bool get tieneRecetas =>
      _recetasMasValoradas.isNotEmpty ||
      _recetasMasNuevas.isNotEmpty ||
      _todasLasRecetas.isNotEmpty;

  /// Cargar TODAS las recetas
  Future<void> cargarTodasLasRecetas() async {
    await runAsync(() async {
      _todasLasRecetas = await _recetaRepository.obtenerTodas();
    }, errorPrefix: 'Error al cargar todas las recetas');
  }

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
      final todasRecetas = await _recetaRepository.obtenerTodas();
      _todasLasRecetas = todasRecetas;

      // Ordenar localmente para obtener las más valoradas y nuevas
      _recetasMasValoradas = List.from(todasRecetas)
        ..sort((a, b) => b.valoracion.compareTo(a.valoracion))
        ..take(5).toList();

      _recetasMasNuevas = List.from(todasRecetas)..take(5).toList();
    }, errorPrefix: 'Error al cargar la pantalla de inicio');
  }

  /// Refrescar home
  Future<void> refrescarHome() async {
    clearError();
    await cargarHome();
  }

  /// Valorar una receta y actualizar la lista
  /// ✅ CORREGIDO: Añadido parámetro usuario
  Future<bool> valorarReceta(
    String id,
    double puntuacion,
    String usuario, // ✅ AÑADIDO
  ) async {
    final result = await runAsync(() async {
      final recetaValorada = await _recetaRepository.valorar(
        id,
        puntuacion,
        usuario, // ✅ AÑADIDO
      );

      // Actualizar en todas las listas
      final indexTodas = _todasLasRecetas.indexWhere((r) => r.id == id);
      if (indexTodas != -1) {
        _todasLasRecetas[indexTodas] = recetaValorada;
      }

      final indexValoradas = _recetasMasValoradas.indexWhere((r) => r.id == id);
      if (indexValoradas != -1) {
        _recetasMasValoradas[indexValoradas] = recetaValorada;
      }

      final indexNuevas = _recetasMasNuevas.indexWhere((r) => r.id == id);
      if (indexNuevas != -1) {
        _recetasMasNuevas[indexNuevas] = recetaValorada;
      }

      return true;
    }, errorPrefix: 'Error al valorar receta');

    return result ?? false;
  }
}
