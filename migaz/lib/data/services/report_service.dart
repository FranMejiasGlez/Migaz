// lib/data/services/report_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:migaz/core/config/api_config.dart';

class ReportService {
  /// Obtener todas las recetas para calcular estadísticas localmente
  Future<List<dynamic>> obtenerTodasRecetas() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/recetas');
      final response = await http.get(uri, headers: ApiConfig.headers);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('❌ Error obtenerTodasRecetas: $e');
      return [];
    }
  }

  /// Obtener todas las categorías
  Future<List<dynamic>> obtenerCategorias() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/categorias');
      final response = await http.get(uri, headers: ApiConfig.headers);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('❌ Error obtenerCategorias: $e');
      return [];
    }
  }

  /// Obtener todos los usuarios (solo para admin)
  Future<List<dynamic>> obtenerTodosUsuarios() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/usuarios');
      final response = await http.get(uri, headers: ApiConfig.headers);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('❌ Error obtenerTodosUsuarios: $e');
      return [];
    }
  }

  /// Obtener perfil de usuario con seguidores/seguidos
  Future<Map<String, dynamic>?> obtenerPerfilUsuario(String userId) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/usuarios/$userId');
      final response = await http.get(uri, headers: ApiConfig.headers);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('❌ Error obtenerPerfilUsuario: $e');
      return null;
    }
  }

  /// Calcular recetas por mes a partir de lista de recetas
  Map<String, int> calcularRecetasPorMes(List<dynamic> recetas) {
    final Map<String, int> porMes = {};
    
    for (var receta in recetas) {
      final createdAt = receta['createdAt'];
      if (createdAt != null) {
        final fecha = DateTime.tryParse(createdAt.toString());
        if (fecha != null) {
          final key = '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}';
          porMes[key] = (porMes[key] ?? 0) + 1;
        }
      }
    }
    
    // Ordenar por fecha
    final sorted = Map.fromEntries(
      porMes.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
    );
    
    return sorted;
  }

  /// Calcular usuarios por mes a partir de lista de usuarios
  Map<String, int> calcularUsuariosPorMes(List<dynamic> usuarios) {
    final Map<String, int> porMes = {};
    
    for (var usuario in usuarios) {
      final createdAt = usuario['createdAt'];
      if (createdAt != null) {
        final fecha = DateTime.tryParse(createdAt.toString());
        if (fecha != null) {
          final key = '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}';
          porMes[key] = (porMes[key] ?? 0) + 1;
        }
      }
    }
    
    final sorted = Map.fromEntries(
      porMes.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
    );
    
    return sorted;
  }

  /// Calcular categorías más populares
  Map<String, int> calcularCategoriasPopulares(List<dynamic> recetas) {
    final Map<String, int> porCategoria = {};
    
    for (var receta in recetas) {
      final categoria = receta['categoria']?.toString() ?? 'Sin categoría';
      final categoriaCapitalized = categoria.isNotEmpty 
          ? categoria[0].toUpperCase() + categoria.substring(1)
          : 'Sin categoría';
      porCategoria[categoriaCapitalized] = (porCategoria[categoriaCapitalized] ?? 0) + 1;
    }
    
    // Ordenar por cantidad descendente
    final sorted = Map.fromEntries(
      porCategoria.entries.toList()..sort((a, b) => b.value.compareTo(a.value))
    );
    
    return sorted;
  }
}
