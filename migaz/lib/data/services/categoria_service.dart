// lib/data/services/categoria_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:migaz/core/config/api_config.dart';

class CategoriaService {
  Future<List<String>> obtenerCategorias() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/categorias'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // Asumiendo que tu API retorna [{ nombre: "Postre" }, { nombre: "Ensalada" }]
        final categorias = data.map((cat) => cat['nombre'] as String).toList();
        return ['Todos', ...categorias]; // Agregar "Todos" al inicio
      } else {
        throw Exception('Error al obtener categorías');
      }
    } catch (e) {
      //print('❌ Error en obtenerCategorias: $e');
      return ['Todos']; // Fallback
    }
  }
}
