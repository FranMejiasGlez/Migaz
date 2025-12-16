import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/data/repositories/receta_repository.dart';
import 'package:migaz/data/services/guardados_service.dart';
import 'package:migaz/viewmodels/base_viewmodel.dart';

class BibliotecaViewModel extends BaseViewModel {
  final RecetaRepository _recetaRepository;
  final GuardadosService _guardadosService;

  // Listas de datos
  List<Recipe> _misRecetas = [];
  List<Recipe> _recetasGuardadas = [];

  // Getters
  List<Recipe> get misRecetas => _misRecetas;
  List<Recipe> get recetasGuardadas => _recetasGuardadas;

  /// Total de recetas en la biblioteca (creadas + guardadas únicas)
  int get totalRecetas {
    final idsCreadas = _misRecetas.map((r) => r.id).toSet();
    final idsGuardadas = _recetasGuardadas.map((r) => r.id).toSet();
    return idsCreadas.union(idsGuardadas).length;
  }

  // Constructor
  BibliotecaViewModel({
    RecetaRepository? recetaRepository,
    GuardadosService? guardadosService,
  }) : _recetaRepository = recetaRepository ?? RecetaRepository(),
       _guardadosService = guardadosService ?? GuardadosService();

  /// Carga inicial de datos: recetas creadas + recetas guardadas
  Future<void> cargarDatos(String usuarioId) async {
    if (usuarioId.isEmpty) return;

    await runAsync(() async {
      // 1. Cargar recetas creadas por el usuario
      final recetasCreadas = await _recetaRepository.obtenerPorUsuario(
        usuarioId,
      );

      // Ordenar por fecha (más nuevas primero)
      recetasCreadas.sort((a, b) {
        final fechaA = a.fechaCreacion ?? DateTime(2000);
        final fechaB = b.fechaCreacion ?? DateTime(2000);
        return fechaB.compareTo(fechaA);
      });

      _misRecetas = recetasCreadas;

      // 2. Cargar recetas guardadas
      await _cargarRecetasGuardadas(usuarioId);
    }, errorPrefix: 'Error al cargar tu biblioteca');
  }

  /// Carga las recetas guardadas del usuario
  Future<void> _cargarRecetasGuardadas(String usuarioId) async {
    try {
      // Obtener IDs de recetas guardadas desde SharedPreferences
      final idsGuardadas = await _guardadosService.obtenerGuardadas(usuarioId);

      if (idsGuardadas.isEmpty) {
        _recetasGuardadas = [];
        return;
      }

      // Cargar cada receta por su ID en paralelo
      final futures = idsGuardadas.map((id) => _cargarRecetaSegura(id));
      final resultados = await Future.wait(futures);

      // Filtrar los nulls (recetas que no se pudieron cargar)
      _recetasGuardadas = resultados
          .where((r) => r != null)
          .cast<Recipe>()
          .map((r) => r.copyWith(isGuardada: true))
          .toList();
    } catch (e) {}
  }

  /// Carga una receta de forma segura (devuelve null si falla)
  Future<Recipe?> _cargarRecetaSegura(String id) async {
    try {
      final receta = await _recetaRepository.obtenerPorId(id);
      return receta;
    } catch (e) {
      return null;
    }
  }

  /// Guardar una receta en favoritos
  Future<bool> guardarReceta(String usuarioId, String recetaId) async {
    try {
      final resultado = await _guardadosService.guardarReceta(
        usuarioId,
        recetaId,
      );
      if (resultado) {
        await _cargarRecetasGuardadas(usuarioId);
        notifyListeners();
      }
      return resultado;
    } catch (e) {
      print('❌ Error al guardar receta: $e');
      return false;
    }
  }

  /// Quitar una receta de favoritos
  Future<bool> quitarGuardada(String usuarioId, String recetaId) async {
    try {
      final resultado = await _guardadosService.quitarGuardada(
        usuarioId,
        recetaId,
      );
      if (resultado) {
        _recetasGuardadas.removeWhere((r) => r.id == recetaId);
        notifyListeners();
      }
      return resultado;
    } catch (e) {
      print('❌ Error al quitar receta guardada: $e');
      return false;
    }
  }

  /// Verificar si una receta está guardada
  Future<bool> estaGuardada(String usuarioId, String recetaId) async {
    return await _guardadosService.estaGuardada(usuarioId, recetaId);
  }

  /// Método público para refrescar manualmente
  Future<void> refrescar(String usuarioId) async {
    await cargarDatos(usuarioId);
  }

  /// Solo recargar las recetas guardadas (más ligero)
  Future<void> refrescarGuardadas(String usuarioId) async {
    await _cargarRecetasGuardadas(usuarioId);
    notifyListeners();
  }
}
