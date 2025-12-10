class Comentario {
  final String author;
  final String text;
  final DateTime createdAt;

  Comentario({required this.author, required this.text, DateTime? createdAt})
    : createdAt = createdAt ?? DateTime.now();

  factory Comentario.fromJson(Map<String, dynamic> json) => Comentario(
    author: json['author'] as String? ?? 'Anónimo',
    text: json['text'] as String? ?? '',
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'author': author,
    'text': text,
    'createdAt': createdAt.toIso8601String(),
  };
}
