import 'package:flutter/material.dart';

/// Widget de estrellas interactivo para valorar recetas
class RatingStars extends StatefulWidget {
  final double initialRating;
  final ValueChanged<double> onRatingChanged;
  final double size;
  final Color color;
  final bool enabled;

  const RatingStars({
    Key? key,
    this.initialRating = 0,
    required this.onRatingChanged,
    this.size = 32,
    this.color = Colors.amber,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<RatingStars> createState() => _RatingStarsState();
}

class _RatingStarsState extends State<RatingStars> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  void _handleTap(int starIndex) {
    if (!widget.enabled) return;

    setState(() {
      // Si hace clic en la misma estrella, quita la valoración
      if (_currentRating == starIndex + 1.0) {
        _currentRating = 0;
      } else {
        _currentRating = (starIndex + 1).toDouble();
      }
    });

    widget.onRatingChanged(_currentRating);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: widget.enabled ? () => _handleTap(index) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              index < _currentRating ? Icons.star : Icons.star_border,
              size: widget.size,
              color: widget.enabled ? widget.color : Colors.grey[400],
            ),
          ),
        );
      }),
    );
  }
}
