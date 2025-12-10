import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:migaz/data/models/comentario.dart';
import 'package:migaz/data/models/recipe.dart';

// Ejemplo: enviar una receta (requiere que exista un id o identificador)
Future<bool> saveRecipeToServer(Recipe recipe) async {
  final uri = Uri.parse(
    'https://localhost:3000/api/recetas',
  ); // usa HTTPS en producción
  final resp = await http.post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(recipe.toMap()),
  );
  if (resp.statusCode == 201) return true;
  throw Exception('Error guardando receta: ${resp.statusCode} ${resp.body}');
}

// Ejemplo: enviar un comentario (requiere que exista un id o identificador)
Future<bool> postCommentToServer(String recetaId, Comentario comentario) async {
  final uri = Uri.parse(
    'https://localhost:3000/api/recetas/$recetaId/comentarios',
  );
  final resp = await http.post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(comentario.toJson()),
  );
  if (resp.statusCode == 201) return true;
  throw Exception(
    'Error guardando comentario: ${resp.statusCode} ${resp.body}',
  );
}
