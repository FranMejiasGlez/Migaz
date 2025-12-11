import 'dart:io';
import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/data/services/receta_service.dart';

class RecetaRepository {
  final RecetaService _recetaService;

  RecetaRepository({RecetaService? recetaService})
    : _recetaService = recetaService ?? RecetaService();

  /// Obtener todas las recetas
  Future<List<Recipe>> obtenerTodas() async {
    try {
      final jsonList = await _recetaService.obtenerTodas();
      return jsonList.map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener recetas:  $e');
    }
  }

  /// Obtener recetas más valoradas
  Future<List<Recipe>> obtenerMasValoradas({int limit = 10}) async {
    try {
      final jsonList = await _recetaService.obtenerMasValoradas(limit: limit);
      return jsonList.map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener recetas más valoradas: $e');
    }
  }

  /// Obtener recetas más nuevas
  Future<List<Recipe>> obtenerMasNuevas({int limit = 10}) async {
    try {
      final jsonList = await _recetaService.obtenerMasNuevas(limit: limit);
      return jsonList.map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener recetas más nuevas: $e');
    }
  }

  /// Obtener receta por ID
  Future<Recipe> obtenerPorId(String id) async {
    try {
      final json = await _recetaService.obtenerPorId(id);
      return Recipe.fromJson(json);
    } catch (e) {
      throw Exception('Error al obtener receta: $e');
    }
  }

  /// Crear nueva receta
  Future<Recipe> crear(Recipe receta, {List<File>? imagenes}) async {
    try {
      final json = await _recetaService.crear(
        nombre: receta.nombre,
        categoria: receta.categoria,
        descripcion: receta.descripcion,
        dificultad: receta.dificultad,
        tiempo: receta.tiempo,
        servings: receta.servings,
        pasos: receta.pasos,
        ingredientes: receta.ingredientes,
        imagenes: imagenes,
      );

      return Recipe.fromJson(json);
    } catch (e) {
      throw Exception('Error al crear receta: $e');
    }
  }

  /// Actualizar receta
  Future<Recipe> actualizar(
    String id,
    Recipe receta, {
    List<File>? imagenes,
  }) async {
    try {
      final campos = {
        'nombre': receta.nombre,
        'categoria': receta.categoria,
        'descripcion': receta.descripcion,
        'dificultad': receta.dificultad,
        'tiempo': receta.tiempo,
        'servings': receta.servings.toString(),
        'pasos': receta.pasos.join(','),
        'ingredientes': receta.ingredientes.join(','),
      };

      final json = await _recetaService.actualizar(
        id: id,
        campos: campos,
        imagenes: imagenes,
      );
      return Recipe.fromJson(json);
    } catch (e) {
      throw Exception('Error al actualizar receta: $e');
    }
  }

  /// Eliminar receta
  Future<void> eliminar(String id) async {
    try {
      await _recetaService.eliminar(id);
    } catch (e) {
      throw Exception('Error al eliminar receta: $e');
    }
  }

  /// Valorar receta
  Future<Recipe> valorar(String id, double valoracion) async {
    try {
      final json = await _recetaService.valorar(id, valoracion);
      return Recipe.fromJson(json);
    } catch (e) {
      throw Exception('Error al valorar receta: $e');
    }
  }
}
