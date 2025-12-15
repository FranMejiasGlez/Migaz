// lib/data/services/guardados_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

  /// Guardar una receta
  Future<bool> guardarReceta(String usuario, String recetaId) async {
    try {
      final guardadas = await obtenerGuardadas(usuario);

      if (!guardadas.contains(recetaId)) {
        guardadas.add(recetaId);
        await _guardarLista(usuario, guardadas);
        //print('✅ Receta $recetaId guardada para $usuario');
        return true;
      }

      return false;
    } catch (e) {
      //print('❌ Error al guardar receta: $e');
      return false;
    }
  }

  /// Quitar una receta guardada
  Future<bool> quitarGuardada(String usuario, String recetaId) async {
    try {
      final guardadas = await obtenerGuardadas(usuario);

      if (guardadas.contains(recetaId)) {
        guardadas.remove(recetaId);
        await _guardarLista(usuario, guardadas);
        //print('✅ Receta $recetaId eliminada de guardadas para $usuario');
        return true;
      }

      return false;
    } catch (e) {
      //print('❌ Error al quitar guardada: $e');
      return false;
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
