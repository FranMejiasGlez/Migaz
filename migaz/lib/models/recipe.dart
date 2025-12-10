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
    required String id,
    required double valoracion,
  }) : pasos = pasos ?? const [],
       ingredientes = ingredientes ?? const [];

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    id: json['id'] as String,
    nombre: json['nombre'] as String,
    categoria: json['categoria'] as String,
    descripcion: json['descripcion'] as String,
    dificultad: json['dificultad'] as String,
    tiempo: json['tiempo'] as String,
    servings: json['servings'] as int,
    pasos: List<String>.from(json['pasos'] ?? []),
    ingredientes: List<String>.from(json['ingredientes'] ?? []),
    valoracion: 0,
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
  };

  Map<String, dynamic> toMap() => {
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
  };

  @override
  String toString() {
    return 'Recipe(nombre: $nombre, categoria: $categoria,dificultad: $dificultad,tiempo: $tiempo, servings: $servings, pasos:${pasos.length}, ingredientes: ${ingredientes.length}, youtubeUrl: $youtubeUrl, imageUrl: $imageUrl)';
  }

  factory Recipe.fromMap(Map<String, dynamic> m) => Recipe(
    nombre: m['nombre'] as String? ?? '',
    categoria: m['categoria'] as String? ?? 'Otros',
    descripcion: m['descripcion'] as String? ?? '',
    dificultad: m['dificultad'] as String? ?? 'Todos los niveles',
    tiempo: m['tiempo'] as String? ?? '',
    servings: (m['servings'] is int)
        ? m['servings'] as int
        : (m['servings'] is num ? (m['servings'] as num).toInt() : 1),
    pasos: (m['pasos'] is List) ? List<String>.from(m['pasos']) : const [],
    ingredientes: (m['ingredientes'] is List)
        ? List<String>.from(m['ingredientes'])
        : const [],
    youtubeUrl: m['youtubeUrl'] as String?,
    imageUrl: m['imageUrl'] as String?,
    id: '',
    valoracion: 0,
  );
}
