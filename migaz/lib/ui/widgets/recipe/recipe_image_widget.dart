// lib/ui/widgets/recipe/recipe_image_widget.dart
import 'package:flutter/material.dart';

class RecipeImageWidget extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const RecipeImageWidget({
    Key? key,
    this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Si no hay URL de imagen, mostrar placeholder
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    // ✅ Construir URL completa del servidor
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
          print('❌ Error cargando imagen: $fullUrl');
          print('   Error: $error');
          return errorWidget ?? _buildPlaceholder();
        },
      ),
    );
  }

  /// ✅ Construir URL completa de la imagen
  String _buildImageUrl(String imagePath) {
    // Si ya es una URL completa (http/https), devolverla
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    // Si es una ruta relativa del servidor, añadir base URL
    // ⚠️ IMPORTANTE: Cambia 'localhost: 3000' por tu URL de producción cuando despliegues
    const baseUrl = 'http://localhost:3000';

    // Asegurarse de que no haya doble slash
    final cleanPath = imagePath.startsWith('/') ? imagePath : '/$imagePath';

    return '$baseUrl$cleanPath';
  }

  Widget _buildPlaceholder() {
    if (placeholder != null) return placeholder!;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[300]!, Colors.grey[400]!],
        ),
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Icon(Icons.restaurant_menu, size: 48, color: Colors.grey[500]),
      ),
    );
  }
}
