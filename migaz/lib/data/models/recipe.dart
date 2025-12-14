class Recipe {
  final String? id;
  final String nombre;
  final String categoria;
  final String descripcion;
  final int dificultad;
  final String tiempo;
  final int comensales;
  final List<String>
  pasos; // En Flutter usamos "pasos", pero se envía como "instrucciones"
  final List<String> ingredientes;
  final List<String>? imagenes;
  final List<dynamic> comentarios;
  final double valoracion; // Mapea a "promedio" en backend
  final String? user; // ✅ AÑADIDO
  final String? youtube; // ✅ AÑADIDO
  final int? cantidadVotos; // ✅ AÑADIDO
  final String? createdAt;
  bool isGuardada;

  Recipe({
    this.id,
    required this.nombre,
    required this.categoria,
    required this.descripcion,
    required this.dificultad,
    required this.tiempo,
    required this.comensales,
    required this.pasos,
    required this.ingredientes,
    this.imagenes,
    this.comentarios = const [],
    this.valoracion = 0,
    this.user, // ✅ AÑADIDO
    this.youtube, // ✅ AÑADIDO
    this.cantidadVotos, // ✅ AÑADIDO
    this.createdAt,
    this.isGuardada = false,
  });
  //GETTER: Conversión segura a DateTime
  DateTime? get fechaCreacion {
    if (createdAt == null) {
      return null;
    }
    try {
      // Asume que createdAt es un String en formato ISO 8601 (el estándar de Firestore/MongoDB)
      return DateTime.tryParse(createdAt!);
    } catch (e) {
      print('Error al parsear fecha $createdAt: $e');
      return null;
    }
  }

  // ✅ MÉTODO AUXILIAR: Convertir dificultad texto a número
  static int dificultadToInt(dynamic value) {
    if (value == null) return 1;

    if (value is int) {
      return value.clamp(1, 5);
    }

    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed.clamp(1, 5);

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
          return 3;
      }
    }

    return 3;
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

  String get dificultadTexto => dificultadToString(dificultad);
  int get cantidadComentarios => comentarios.length;
  String get dificultadEstrellas {
    return '⭐' * dificultad;
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['_id'] ?? json['id'],
      nombre: json['nombre'] ?? '',
      categoria: json['categoria'] ?? '',
      descripcion: json['descripcion'] ?? '',
      dificultad: dificultadToInt(json['dificultad']),
      tiempo: json['tiempo'] ?? '',
      comensales: _parseIntSafely(json['comensales']),
      // ✅ CORREGIDO: Backend usa "instrucciones"
      pasos: json['instrucciones'] != null
          ? List<String>.from(json['instrucciones'])
          : (json['pasos'] != null ? List<String>.from(json['pasos']) : []),
      ingredientes: List<String>.from(json['ingredientes'] ?? []),
      imagenes: json['imagenes'] != null
          ? List<String>.from(json['imagenes'])
          : null,
      comentarios: json['comentarios'] ?? [],
      valoracion: (json['promedio'] ?? json['valoracion'] ?? 0)
          .toDouble(), // ✅ CORREGIDO
      user: json['user'], // ✅ AÑADIDO
      youtube: json['youtube'], // ✅ AÑADIDO
      cantidadVotos: json['cantidadVotos'], // ✅ AÑADIDO
      createdAt: json['createdAt'],
      isGuardada: false, //Se actualizara despues
    );
  }
  // ✅ NUEVO:  Método para verificar si es del usuario actual
  bool esMia(String currentUser) {
    return user?.toLowerCase() == currentUser.toLowerCase();
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
      'categoria': categoria.toLowerCase(), // ✅ Backend usa lowercase
      'descripcion': descripcion,
      'dificultad': dificultad,
      'tiempo': tiempo,
      'comensales': comensales, // ✅ CORREGIDO
      'instrucciones': pasos, // ✅ CORREGIDO
      'ingredientes': ingredientes,
      if (imagenes != null) 'imagenes': imagenes,
      'comentarios': comentarios,
      'promedio': valoracion, // ✅ CORREGIDO
      if (user != null) 'user': user, // ✅ AÑADIDO
      if (youtube != null) 'youtube': youtube, // ✅ AÑADIDO
      if (createdAt != null) 'createdAt': createdAt,
    };
  }

  Recipe copyWith({
    String? id,
    String? nombre,
    String? categoria,
    String? descripcion,
    int? dificultad,
    String? tiempo,
    int? comensales,
    List<String>? pasos,
    List<String>? ingredientes,
    List<String>? imagenes,
    List<dynamic>? comentarios,
    double? valoracion,
    String? user,
    String? youtube,
    int? cantidadVotos,
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
      user: user ?? this.user,
      youtube: youtube ?? this.youtube,
      cantidadVotos: cantidadVotos ?? this.cantidadVotos,
    );
  }
}
