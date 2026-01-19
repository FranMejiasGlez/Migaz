import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:migaz/core/config/api_config.dart';

class GuardadosService {
  static const String _key = 'recetas_guardadas';

  /// Obtener IDs de recetas guardadas
  Future<List<String>> obtenerGuardadas(String usuario) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final guardadasJson = prefs.getString('${_key}_$usuario');

      if (guardadasJson == null) return [];

      final List<dynamic> guardadasList = json.decode(guardadasJson);
      return guardadasList.cast<String>();
    } catch (e) {
      //print('❌ Error al obtener guardadas: $e');
      return [];
    }
  }

  /// Guardar una receta (Local + Backend)
  Future<bool> guardarReceta(String usuario, String recetaId, {String? userId}) async {
    try {
      // 1. Local (SharedPreferences)
      final guardadas = await obtenerGuardadas(usuario);

      if (!guardadas.contains(recetaId)) {
        guardadas.add(recetaId);
        await _guardarLista(usuario, guardadas);
      }
      
      // 2. Backend (Sync)
      if (userId != null && userId.isNotEmpty) {
        await _syncBackend(userId, recetaId);
      }
      
      return true;
    } catch (e) {
      print('❌ Error al guardar receta: $e');
      return false;
    }
  }

  /// Quitar una receta guardada (Local + Backend)
  Future<bool> quitarGuardada(String usuario, String recetaId, {String? userId}) async {
    try {
      // 1. Local
      final guardadas = await obtenerGuardadas(usuario);

      if (guardadas.contains(recetaId)) {
        guardadas.remove(recetaId);
        await _guardarLista(usuario, guardadas);
      }
      
      // 2. Backend (Sync - Toggle works same way)
      if (userId != null && userId.isNotEmpty) {
        await _syncBackend(userId, recetaId);
      }
      
      return true;
    } catch (e) {
      print('❌ Error al quitar guardada: $e');
      return false;
    }
  }

  Future<void> _syncBackend(String userId, String recetaId) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/usuarios/$userId/guardar-receta');
      await http.post(
        uri,
        headers: ApiConfig.headers,
        body: jsonEncode({'recetaId': recetaId}),
      );
    } catch (e) {
      print('⚠️ Error syncing with backend: $e');
    }
  }

  /// Sincronizar guardados desde el backend (Al inicio de la app)
  Future<void> sincronizarDesdeBackend(String usuario, String userId) async {
    try {
      if (userId.isEmpty) return;
      
      final uri = Uri.parse('${ApiConfig.baseUrl}/usuarios/$userId');
      final response = await http.get(uri, headers: ApiConfig.headers);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> recetasGuardadasObj = data['recetas_guardadas'] ?? [];
        
        // Extraer IDs (pueden venir como strings o como objetos si están populados)
        final List<String> serverIds = [];
        for (var item in recetasGuardadasObj) {
          if (item is String) {
            serverIds.add(item);
          } else if (item is Map && item.containsKey('_id')) {
            serverIds.add(item['_id']);
          }
        }
        
        // Actualizar localmente
        await _guardarLista(usuario, serverIds);
      }
    } catch (e) {
      print('❌ Error al sincronizar desde backend: $e');
    }
  }

  /// Verificar si una receta está guardada
  Future<bool> estaGuardada(String usuario, String recetaId) async {
    final guardadas = await obtenerGuardadas(usuario);
    return guardadas.contains(recetaId);
  }

  /// Guardar lista en SharedPreferences
  Future<void> _guardarLista(String usuario, List<String> guardadas) async {
    final prefs = await SharedPreferences.getInstance();
    final guardadasJson = json.encode(guardadas);
    await prefs.setString('${_key}_$usuario', guardadasJson);
  }
}
