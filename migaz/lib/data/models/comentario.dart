class Comentario {
  final String? id;
  final String recetaId;
  final String usuario;
  final String texto;
  final DateTime? fecha;

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
      recetaId: json['recetaId'] ?? '',
      usuario: json['usuario'] ?? '',
      texto: json['texto'] ?? '',
      fecha: json['fecha'] != null ? DateTime.parse(json['fecha']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'recetaId': recetaId,
      'usuario': usuario,
      'texto': texto,
      if (fecha != null) 'fecha': fecha!.toIso8601String(),
    };
  }
}
