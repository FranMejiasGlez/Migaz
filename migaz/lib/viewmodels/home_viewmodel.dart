import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/data/repositories/receta_repository.dart';
import 'package:migaz/data/services/guardados_service.dart';
import 'package:migaz/viewmodels/base_viewmodel.dart';

class HomeViewModel extends BaseViewModel {
  final RecetaRepository _recetaRepository;
  final GuardadosService _guardadosService;

  List<Recipe> _recetasMasValoradas = [];
  List<Recipe> _recetasMasNuevas = [];
  List<Recipe> _todasLasRecetas = [];
  List<String> _recetasGuardadasIds = [];

  HomeViewModel({
    RecetaRepository? recetaRepository,
    GuardadosService? guardadosService,
  }) : _recetaRepository = recetaRepository ?? RecetaRepository(),
       _guardadosService = guardadosService ?? GuardadosService();

  // Getters
  List<Recipe> get recetasMasValoradas => _recetasMasValoradas;
  List<Recipe> get recetasMasNuevas => _recetasMasNuevas;
  List<Recipe> get todasLasRecetas => _todasLasRecetas;

  // ✅ NUEVO: Obtener recetas guardadas
  List<Recipe> get recetasGuardadas {
    return _todasLasRecetas
        .where((r) => _recetasGuardadasIds.contains(r.id))
        .toList();
  }

  bool get tieneRecetas =>
      _recetasMasValoradas.isNotEmpty ||
      _recetasMasNuevas.isNotEmpty ||
      _todasLasRecetas.isNotEmpty;

  /// ✅ NUEVO: Cargar recetas guardadas
  Future<void> cargarGuardadas(String usuario) async {
    _recetasGuardadasIds = await _guardadosService.obtenerGuardadas(usuario);
    _actualizarEstadoGuardadas();
    notifyListeners();
  }

  /// ✅ NUEVO: Guardar/Quitar receta
  Future<bool> toggleGuardarReceta(String recetaId, String usuario) async {
    final estaGuardada = _recetasGuardadasIds.contains(recetaId);

    bool exito;
    if (estaGuardada) {
      exito = await _guardadosService.quitarGuardada(usuario, recetaId);
      if (exito) {
        _recetasGuardadasIds.remove(recetaId);
      }
    } else {
      exito = await _guardadosService.guardarReceta(usuario, recetaId);
      if (exito) {
        _recetasGuardadasIds.add(recetaId);
      }
    }

    if (exito) {
      _actualizarEstadoGuardadas();
      notifyListeners();
    }

    return exito;
  }

  /// Actualizar estado isGuardada en todas las recetas
  void _actualizarEstadoGuardadas() {
    for (var receta in _todasLasRecetas) {
      receta.isGuardada = _recetasGuardadasIds.contains(receta.id);
    }
    for (var receta in _recetasMasValoradas) {
      receta.isGuardada = _recetasGuardadasIds.contains(receta.id);
    }
    for (var receta in _recetasMasNuevas) {
      receta.isGuardada = _recetasGuardadasIds.contains(receta.id);
    }
  }

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

      // Más valoradas
      _recetasMasValoradas = List<Recipe>.from(todasRecetas)
        ..sort((a, b) => b.valoracion.compareTo(a.valoracion));
      if (_recetasMasValoradas.length > 5) {
        _recetasMasValoradas = _recetasMasValoradas.sublist(0, 5);
      }

      // Más nuevas
      _recetasMasNuevas = List<Recipe>.from(todasRecetas)
        ..sort((a, b) {
          final fechaA = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(1970);
          final fechaB = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(1970);
          return fechaB.compareTo(fechaA);
        });
      if (_recetasMasNuevas.length > 5) {
        _recetasMasNuevas = _recetasMasNuevas.sublist(0, 5);
      }

      // Actualizar estado de guardadas
      _actualizarEstadoGuardadas();
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
