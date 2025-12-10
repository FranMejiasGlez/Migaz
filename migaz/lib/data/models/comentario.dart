class Comentario {
  final String autor;
  final String texto;
  final DateTime creadoEn;

  Comentario({required this.autor, required this.texto, DateTime? creadoEn})
    : creadoEn = creadoEn ?? DateTime.now();

  factory Comentario.fromJson(Map<String, dynamic> json) => Comentario(
    autor: json['autor'] as String? ?? 'Anónimo',
    texto: json['texto'] as String? ?? '',
    creadoEn: json['creadoEn'] != null
        ? DateTime.parse(json['creadoEn'] as String)
        : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'autor': autor,
    'texto': texto,
    'creadoEn': creadoEn.toIso8601String(),
  };

  @override
  String toString() =>
      'Comentario(autor: $autor, texto: $texto, creadoEn: $creadoEn)';
}
