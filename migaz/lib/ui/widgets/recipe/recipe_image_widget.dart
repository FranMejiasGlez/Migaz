import 'package:flutter/material.dart';
import 'package:migaz/data/models/recipe.dart';

class RecipeImageWidget extends StatelessWidget {
  final Recipe recipe;
  final double width;
  final double height;
  final double borderRadius;
  final BoxFit fit;

  const RecipeImageWidget({
    Key? key,
    required this.recipe,
    this.width = 250,
    this.height = 200,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Si tiene imágenes, usar la primera
    if (recipe.imagenes != null && recipe.imagenes!.isNotEmpty) {
      return _buildNetworkImage(recipe.imagenes!.first);
    }

    // Si no tiene imagen, mostrar placeholder
    return _buildPlaceholder();
  }

  Widget _buildNetworkImage(String imageUrl) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: SizedBox(
          width: width,
          height: height,
          child: Image.network(
            imageUrl,
            fit: fit,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildLoadingIndicator(loadingProgress);
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(ImageChunkEvent loadingProgress) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
              : null,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.grey[300]!, Colors.grey[400]!],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant, size: 60, color: Colors.grey[600]),
              const SizedBox(height: 8),
              Text(
                'Sin imagen',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
