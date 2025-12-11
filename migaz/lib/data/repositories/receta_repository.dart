import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/data/services/receta_service.dart';

class RecetaRepository {
  final RecetaService _recetaService;

  RecetaRepository({RecetaService? recetaService})
    : _recetaService = recetaService ?? RecetaService();

  Future<List<Recipe>> obtenerTodas() async {
    try {
      final jsonList = await _recetaService.obtenerTodas();
      return jsonList.map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener recetas: $e');
    }
  }

  Future<List<Recipe>> obtenerMasValoradas({int limit = 10}) async {
    try {
      final jsonList = await _recetaService.obtenerMasValoradas(limit: limit);
      return jsonList.map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener recetas más valoradas: $e');
    }
  }

  Future<List<Recipe>> obtenerMasNuevas({int limit = 10}) async {
    try {
      final jsonList = await _recetaService.obtenerMasNuevas(limit: limit);
      return jsonList.map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener recetas más nuevas: $e');
    }
  }

  /// ✅ NUEVO: Obtener recetas de un usuario
  Future<List<Recipe>> obtenerPorUsuario(String usuario) async {
    try {
      final jsonList = await _recetaService.obtenerPorUsuario(usuario);
      return jsonList.map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener recetas del usuario: $e');
    }
  }

  Future<Recipe> obtenerPorId(String id) async {
    try {
      final json = await _recetaService.obtenerPorId(id);
      return Recipe.fromJson(json);
    } catch (e) {
      throw Exception('Error al obtener receta:  $e');
    }
  }

  Future<Recipe> crear(
    Recipe receta, {
    List<File>? imagenes,
    List<XFile>? imagenesXFile,
    required String usuario,
    String? youtube,
  }) async {
    try {
      final json = await _recetaService.crear(
        nombre: receta.nombre,
        categoria: receta.categoria,
        descripcion: receta.descripcion,
        dificultad: receta.dificultad,
        tiempo: receta.tiempo,
        comensales: receta.comensales,
        instrucciones: receta.pasos,
        ingredientes: receta.ingredientes,
        user: usuario,
        youtube: youtube,
        imagenes: imagenes,
        imagenesXFile: imagenesXFile,
      );

      return Recipe.fromJson(json);
    } catch (e) {
      throw Exception('Error al crear receta: $e');
    }
  }

  Future<Recipe> actualizar(
    String id,
    Recipe receta, {
    List<File>? imagenes,
  }) async {
    try {
      final campos = {
        'nombre': receta.nombre,
        'categoria': receta.categoria.toLowerCase(),
        'descripcion': receta.descripcion,
        'dificultad': receta.dificultad.toString(),
        'tiempo': receta.tiempo,
        'comensales': receta.comensales.toString(),
        'instrucciones': receta.pasos.join(','),
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

  Future<void> eliminar(String id) async {
    try {
      await _recetaService.eliminar(id);
    } catch (e) {
      throw Exception('Error al eliminar receta: $e');
    }
  }

  Future<Recipe> valorar(String id, double puntuacion, String usuario) async {
    try {
      final json = await _recetaService.valorar(id, puntuacion, usuario);
      return Recipe.fromJson(json);
    } catch (e) {
      throw Exception('Error al valorar receta: $e');
    }
  }
}
