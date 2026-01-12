// lib/viewmodels/report_viewmodel.dart
import 'package:migaz/data/services/report_service.dart';
import 'package:migaz/data/services/guardados_service.dart';
import 'package:migaz/viewmodels/base_viewmodel.dart';

class ReportViewModel extends BaseViewModel {
  final ReportService _reportService = ReportService();
  final GuardadosService _guardadosService = GuardadosService();

  // Datos del usuario
  int _seguidores = 0;
  int _seguidos = 0;
  int _misRecetas = 0;
  int _recetasGuardadas = 0;

  // Datos globales
  int _recetasTotales = 0;
  int _usuariosTotales = 0;
  Map<String, int> _recetasPorMes = {};
  Map<String, int> _usuariosPorMes = {};
  Map<String, int> _categoriasPopulares = {};

  // Getters
  int get seguidores => _seguidores;
  int get seguidos => _seguidos;
  int get misRecetas => _misRecetas;
  int get recetasGuardadas => _recetasGuardadas;
  int get recetasTotales => _recetasTotales;
  int get usuariosTotales => _usuariosTotales;
  Map<String, int> get recetasPorMes => _recetasPorMes;
  Map<String, int> get usuariosPorMes => _usuariosPorMes;
  Map<String, int> get categoriasPopulares => _categoriasPopulares;

  /// Cargar todas las estadísticas del usuario
  Future<void> cargarEstadisticasUsuario(String userId, String username) async {
    await runAsync(() async {
      // 1. Cargar perfil del usuario (seguidores/seguidos)
      final perfil = await _reportService.obtenerPerfilUsuario(userId);
      if (perfil != null) {
        _seguidores = (perfil['seguidores'] as List?)?.length ?? 0;
        _seguidos = (perfil['siguiendo'] as List?)?.length ?? 0;
      }

      // 2. Cargar todas las recetas para estadísticas
      final todasRecetas = await _reportService.obtenerTodasRecetas();
      _recetasTotales = todasRecetas.length;

      // 3. Filtrar mis recetas
      final misRecetasList = todasRecetas.where((r) {
        final user = r['user'];
        if (user is Map) {
          return user['_id'] == userId || user['username'] == username;
        }
        return user?.toString() == userId || user?.toString() == username;
      }).toList();
      _misRecetas = misRecetasList.length;

      // 4. Cargar recetas guardadas
      final guardadasIds = await _guardadosService.obtenerGuardadas(username);
      _recetasGuardadas = guardadasIds.length;

      // 5. Calcular recetas por mes
      _recetasPorMes = _reportService.calcularRecetasPorMes(todasRecetas);

      // 6. Calcular categorías populares
      _categoriasPopulares = _reportService.calcularCategoriasPopulares(todasRecetas);

      return true;
    });
  }

  /// Cargar estadísticas de admin (usuarios)
  Future<void> cargarEstadisticasAdmin() async {
    await runAsync(() async {
      // Cargar todos los usuarios
      final usuarios = await _reportService.obtenerTodosUsuarios();
      _usuariosTotales = usuarios.length;
      
      // Calcular usuarios por mes
      _usuariosPorMes = _reportService.calcularUsuariosPorMes(usuarios);

      return true;
    });
  }

  /// Cargar todo (usuario + admin)
  Future<void> cargarTodo(String userId, String username, {bool isAdmin = false}) async {
    await cargarEstadisticasUsuario(userId, username);
    if (isAdmin) {
      await cargarEstadisticasAdmin();
    }
  }
}
