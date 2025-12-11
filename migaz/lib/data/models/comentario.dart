// lib/data/models/comentario.dart
class Comentario {
  final String? id;
  final String recetaId; // En backend es 'receta'
  final String usuario;
  final String texto; // En backend es 'contenido'
  final DateTime? fecha; // En backend es 'createdAt'

  Comentario({
    this.id,
    required this.recetaId,
    required this.usuario,
    required this.texto,
    this.fecha,
  });

  factory Comentario.fromJson(Map<String, dynamic> json) {
    return Comentario(
      id: json['_id'] ?? json['id'],
      recetaId: json['receta'] ?? json['recetaId'] ?? '', // ✅ Soporta ambos
      usuario: json['usuario'] ?? '',
      texto: json['contenido'] ?? json['texto'] ?? '', // ✅ Soporta ambos
      fecha:
          json['createdAt'] !=
              null // ✅ CORREGIDO: usar createdAt
          ? DateTime.parse(json['createdAt'])
          : (json['fecha'] != null ? DateTime.parse(json['fecha']) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'receta': recetaId, // ✅ CAMBIADO: usar 'receta'
      'usuario': usuario,
      'contenido': texto, // ✅ CAMBIADO: usar 'contenido'
      if (fecha != null) 'createdAt': fecha!.toIso8601String(),
    };
  }
}
