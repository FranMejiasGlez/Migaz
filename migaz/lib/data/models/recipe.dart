class Recipe {
  final String? id;
  final String nombre;
  final String categoria;
  final String descripcion;
  final int dificultad; // ✅ CAMBIADO: String → int (1-5)
  final String tiempo;
  final int comensales;
  final List<String> pasos;
  final List<String> ingredientes;
  final List<String>? imagenes;
  final List<dynamic> comentarios;
  final double valoracion;

  Recipe({
    this.id,
    required this.nombre,
    required this.categoria,
    required this.descripcion,
    required this.dificultad, // ✅ int
    required this.tiempo,
    required this.comensales,
    required this.pasos,
    required this.ingredientes,
    this.imagenes,
    this.comentarios = const [],
    this.valoracion = 0,
  });

  // ✅ MÉTODO AUXILIAR: Convertir dificultad texto a número
  static int dificultadToInt(dynamic value) {
    if (value == null) return 1;

    // Si ya es un número
    if (value is int) {
      return value.clamp(1, 5); // Asegurar que esté entre 1-5
    }

    // Si es String, convertir
    if (value is String) {
      // Intentar parsear directamente
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed.clamp(1, 5);

      // Convertir texto a número
      final lower = value.toLowerCase().trim();
      switch (lower) {
        case 'muy fácil':
        case 'muy facil':
        case 'fácil':
        case 'facil':
          return 1;
        case 'fácil-medio':
        case 'facil-medio':
          return 2;
        case 'medio':
        case 'intermedio':
          return 3;
        case 'medio-difícil':
        case 'medio-dificil':
          return 4;
        case 'difícil':
        case 'dificil':
        case 'muy difícil':
        case 'muy dificil':
          return 5;
        default:
          return 3; // Por defecto:  medio
      }
    }

    return 3; // Por defecto
  }

  // ✅ MÉTODO AUXILIAR:  Convertir número a texto para mostrar
  static String dificultadToString(int nivel) {
    switch (nivel) {
      case 1:
        return 'Muy Fácil';
      case 2:
        return 'Fácil';
      case 3:
        return 'Medio';
      case 4:
        return 'Difícil';
      case 5:
        return 'Muy Difícil';
      default:
        return 'Medio';
    }
  }

  // ✅ GETTER: Para mostrar dificultad como texto
  String get dificultadTexto => dificultadToString(dificultad);

  // ✅ GETTER: Para mostrar estrellas/emojis
  String get dificultadEstrellas {
    return '⭐' * dificultad;
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['_id'] ?? json['id'],
      nombre: json['nombre'] ?? '',
      categoria: json['categoria'] ?? '',
      descripcion: json['descripcion'] ?? '',
      dificultad: dificultadToInt(json['dificultad']), // ✅ CONVERTIR
      tiempo: json['tiempo'] ?? '',
      comensales: _parseIntSafely(json['servings'] ?? json['comensales']),
      pasos: List<String>.from(json['pasos'] ?? []),
      ingredientes: List<String>.from(json['ingredientes'] ?? []),
      imagenes: json['imagenes'] != null
          ? List<String>.from(json['imagenes'])
          : null,
      comentarios: json['comentarios'] ?? [],
      valoracion: (json['valoracion'] ?? 0).toDouble(),
    );
  }

  static int _parseIntSafely(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is double) return value.toInt();
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'nombre': nombre,
      'categoria': categoria,
      'descripcion': descripcion,
      'dificultad': dificultad, // ✅ Enviar como número
      'tiempo': tiempo,
      'servings': comensales,
      'pasos': pasos,
      'ingredientes': ingredientes,
      if (imagenes != null) 'imagenes': imagenes,
      'comentarios': comentarios,
      'valoracion': valoracion,
    };
  }

  Recipe copyWith({
    String? id,
    String? nombre,
    String? categoria,
    String? descripcion,
    int? dificultad, // ✅ int
    String? tiempo,
    int? comensales,
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
      comensales: comensales ?? this.comensales,
      pasos: pasos ?? this.pasos,
      ingredientes: ingredientes ?? this.ingredientes,
      imagenes: imagenes ?? this.imagenes,
      comentarios: comentarios ?? this.comentarios,
      valoracion: valoracion ?? this.valoracion,
    );
  }
}
