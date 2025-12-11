import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:migaz/core/utils/app_theme.dart';
import 'package:migaz/data/models/recipe.dart'; // ✅ IMPORTAR

class RecipeCarousel extends StatelessWidget {
  final String title;
  final List<Recipe> recipes; // ✅ CAMBIADO: List<String> → List<Recipe>
  final Function(int)? onRecipeTap;
  final String? emptyMessage;
  final bool showEmptyState;

  const RecipeCarousel({
    Key? key,
    required this.title,
    required this.recipes,
    this.onRecipeTap,
    this.emptyMessage,
    this.showEmptyState = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

        if (recipes.isEmpty && showEmptyState)
          _buildEmptyState()
        else if (recipes.isNotEmpty)
          _buildCarousel(context),
      ],
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 500,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.grey[100]!, Colors.grey[200]!],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.restaurant_menu,
                        size: 60,
                        color: AppTheme.primaryYellow,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.coffee, size: 24, color: Colors.grey[400]),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.local_pizza,
                          size: 24,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.cake, size: 24, color: Colors.grey[400]),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                emptyMessage ?? 'No hay recetas disponibles',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '¡Agrega tu primera receta!',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarousel(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
          ),
          child: PageView.builder(
            physics: const BouncingScrollPhysics(),
            controller: PageController(viewportFraction: 0.5),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index]; // ✅ AHORA ES UN OBJETO Recipe

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // ✅ IMAGEN REAL DE LA RECETA
                      _buildRecipeImage(recipe),

                      // CAPA 2: CONTENIDO CON FONDO OSCURO
                      Center(
                        child: Container(
                          margin: const EdgeInsets.all(16.0),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                recipe.nombre, // ✅ NOMBRE DE LA RECETA
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(1, 1),
                                      blurRadius: 3.0,
                                      color: Colors.black26,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              // ✅ MOSTRAR CATEGORÍA
                              Text(
                                recipe.categoria,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // CAPA 3: INTERACCIÓN
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (onRecipeTap != null) {
                                onRecipeTap!(index);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ✅ NUEVO MÉTODO:  Construir imagen de la receta
  Widget _buildRecipeImage(Recipe recipe) {
    // Si tiene imágenes, usar la primera
    if (recipe.imagenes != null && recipe.imagenes!.isNotEmpty) {
      return Image.network(
        recipe.imagenes!.first,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
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
        },
        errorBuilder: (context, error, stackTrace) {
          // Si falla la carga, mostrar placeholder
          return _buildPlaceholderImage();
        },
      );
    }

    // Si no tiene imágenes, mostrar placeholder
    return _buildPlaceholderImage();
  }

  // ✅ IMAGEN PLACEHOLDER
  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[300]!, Colors.grey[400]!],
        ),
      ),
      child: Center(
        child: Icon(Icons.restaurant, size: 80, color: Colors.grey[500]),
      ),
    );
  }
}
