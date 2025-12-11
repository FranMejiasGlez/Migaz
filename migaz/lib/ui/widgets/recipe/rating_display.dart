import 'package:flutter/material.dart';

/// Widget para mostrar valoración (solo lectura)
class RatingDisplay extends StatelessWidget {
  final double rating;
  final int? totalVotes;
  final double size;
  final Color color;
  final bool showNumber;
  final bool showVotes;

  const RatingDisplay({
    Key? key,
    required this.rating,
    this.totalVotes,
    this.size = 20,
    this.color = Colors.amber,
    this.showNumber = true,
    this.showVotes = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Estrellas visuales
        ...List.generate(5, (index) {
          if (index < rating.floor()) {
            // Estrella completa
            return Icon(Icons.star, size: size, color: color);
          } else if (index < rating && rating % 1 != 0) {
            // Media estrella
            return Icon(Icons.star_half, size: size, color: color);
          } else {
            // Estrella vacía
            return Icon(Icons.star_border, size: size, color: color);
          }
        }),

        // Número de valoración
        if (showNumber) ...[
          const SizedBox(width: 8),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(fontSize: size * 0.8, fontWeight: FontWeight.bold),
          ),
        ],

        // Cantidad de votos
        if (showVotes && totalVotes != null) ...[
          const SizedBox(width: 4),
          Text(
            '($totalVotes)',
            style: TextStyle(fontSize: size * 0.7, color: Colors.grey[600]),
          ),
        ],
      ],
    );
  }
}
