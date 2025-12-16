// lib/ui/widgets/recipe/recipe_image_widget.dart
import 'package:flutter/material.dart';
import 'package:migaz/core/config/api_config.dart';

class RecipeImageWidget extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const RecipeImageWidget({
    Key? key,
    this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Si no hay URL de imagen, mostrar placeholder
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildNoImagePlaceholder();
    }

    // Construir URL completa del servidor
    final fullUrl = _buildImageUrl(imageUrl!);

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.network(
        fullUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

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
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          //print('❌ Error cargando imagen: $fullUrl');
          //print('   Error: $error');
          // Si falla la carga, mostrar placeholder de error
          return _buildErrorPlaceholder();
        },
      ),
    );
  }

  /// Construir URL completa de la imagen
  String _buildImageUrl(String imagePath) {
    // ✅ Usar el método centralizado de ApiConfig para consistencia
    return ApiConfig.getImageUrl(imagePath);
  }

  /// ✅ NUEVO: Placeholder cuando NO hay imagen
  Widget _buildNoImagePlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[200]!, Colors.grey[300]!],
        ),
        borderRadius: borderRadius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, size: 48, color: Colors.grey[500]),
          const SizedBox(height: 8),
          Text(
            'No existe imagen',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ NUEVO: Placeholder cuando hay ERROR al cargar
  Widget _buildErrorPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red[50]!, Colors.red[100]!],
        ),
        borderRadius: borderRadius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, size: 48, color: Colors.red[300]),
          const SizedBox(height: 8),
          Text(
            'Error al cargar',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red[400],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
