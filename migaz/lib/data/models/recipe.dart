class Recipe {
  final String? id; // ID desde el backend
  final String nombre;
  final String categoria;
  final String descripcion;
  final String dificultad;
  final String tiempo;
  final int servings;
  final List<String> pasos;
  final List<String> ingredientes;
  final List<String>? imagenes; // URLs de las imágenes
  final List<dynamic> comentarios;
  final double valoracion;

  Recipe({
    this.id,
    required this.nombre,
    required this.categoria,
    required this.descripcion,
    required this.dificultad,
    required this.tiempo,
    required this.servings,
    required this.pasos,
    required this.ingredientes,
    this.imagenes,
    this.comentarios = const [],
    this.valoracion = 0,
  });

  // Crear Recipe desde JSON (respuesta de API)
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['_id'] ?? json['id'],
      nombre: json['nombre'] ?? '',
      categoria: json['categoria'] ?? '',
      descripcion: json['descripcion'] ?? '',
      dificultad: json['dificultad'] ?? '',
      tiempo: json['tiempo'] ?? '',
      servings: json['servings'] ?? 0,
      pasos: List<String>.from(json['pasos'] ?? []),
      ingredientes: List<String>.from(json['ingredientes'] ?? []),
      imagenes: json['imagenes'] != null
          ? List<String>.from(json['imagenes'])
          : null,
      comentarios: json['comentarios'] ?? [],
      valoracion: (json['valoracion'] ?? 0).toDouble(),
    );
  }

  // Convertir Recipe a JSON (para enviar a API)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'nombre': nombre,
      'categoria': categoria,
      'descripcion': descripcion,
      'dificultad': dificultad,
      'tiempo': tiempo,
      'servings': servings,
      'pasos': pasos,
      'ingredientes': ingredientes,
      if (imagenes != null) 'imagenes': imagenes,
      'comentarios': comentarios,
      'valoracion': valoracion,
    };
  }

  // Método copyWith para crear copias modificadas
  Recipe copyWith({
    String? id,
    String? nombre,
    String? categoria,
    String? descripcion,
    String? dificultad,
    String? tiempo,
    int? servings,
    List<String>? pasos,
    List<String>? ingredientes,
    List<String>? imagenes,
    List<dynamic>? comentarios,
    double? valoracion,
  }) {
    return Recipe(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      categoria: categoria ?? this.categoria,
      descripcion: descripcion ?? this.descripcion,
      dificultad: dificultad ?? this.dificultad,
      tiempo: tiempo ?? this.tiempo,
      servings: servings ?? this.servings,
      pasos: pasos ?? this.pasos,
      ingredientes: ingredientes ?? this.ingredientes,
      imagenes: imagenes ?? this.imagenes,
      comentarios: comentarios ?? this.comentarios,
      valoracion: valoracion ?? this.valoracion,
    );
  }
}
