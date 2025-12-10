import 'comentario.dart';

class Recipe {
  final String nombre;
  final String categoria;
  final String descripcion;
  final String dificultad;
  final String tiempo;
  final int servings;
  final List<String> pasos;
  final List<String> ingredientes;
  final String? youtubeUrl;
  final String? imageUrl;

  // Nuevos campos
  final List<Comentario> comentarios;
  final double valoracion;

  Recipe({
    required this.nombre,
    required this.categoria,
    this.descripcion = '',
    this.dificultad = 'Todos los niveles',
    this.tiempo = '',
    this.servings = 1,
    List<String>? pasos,
    List<String>? ingredientes,
    this.youtubeUrl,
    this.imageUrl,
    List<Comentario>? comentarios,
    this.valoracion = 0.0,
  }) : pasos = pasos ?? const [],
       ingredientes = ingredientes ?? const [],
       comentarios = comentarios ?? const [];

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    nombre: json['nombre'] as String,
    categoria: json['categoria'] as String,
    descripcion: json['descripcion'] as String? ?? '',
    dificultad: json['dificultad'] as String? ?? 'Todos los niveles',
    tiempo: json['tiempo'] as String? ?? '',
    servings: (json['servings'] is int)
        ? json['servings'] as int
        : (json['servings'] is num ? (json['servings'] as num).toInt() : 1),
    pasos: List<String>.from(json['pasos'] ?? []),
    ingredientes: List<String>.from(json['ingredientes'] ?? []),
    youtubeUrl: json['youtubeUrl'] as String?,
    imageUrl: json['imageUrl'] as String?,
    comentarios: (json['comentarios'] is List)
        ? List<Map<String, dynamic>>.from(
            json['comentarios'],
          ).map((m) => Comentario.fromJson(m)).toList()
        : const [],
    valoracion: (json['valoracion'] is num)
        ? (json['valoracion'] as num).toDouble()
        : 0.0,
  );

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'categoria': categoria,
    'descripcion': descripcion,
    'dificultad': dificultad,
    'tiempo': tiempo,
    'servings': servings,
    'pasos': pasos,
    'ingredientes': ingredientes,
    'youtubeUrl': youtubeUrl,
    'imageUrl': imageUrl,
    'comentarios': comentarios.map((c) => c.toJson()).toList(),
    'valoracion': valoracion,
  };

  Map<String, dynamic> toMap() => toJson();

  @override
  String toString() {
    return 'Recipe(nombre: $nombre, categoria: $categoria,dificultad: $dificultad,tiempo: $tiempo, servings: $servings, pasos:${pasos.length}, ingredientes: ${ingredientes.length}, youtubeUrl: $youtubeUrl, imageUrl: $imageUrl, comentarios:${comentarios.length}, valoracion:$valoracion)';
  }

  factory Recipe.fromMap(Map<String, dynamic> m) => Recipe.fromJson(m);
}
