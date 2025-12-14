import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:migaz/core/utils/responsive_breakpoints.dart';
import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/core/config/api_config.dart';
import 'package:migaz/core/utils/responsive_helper.dart';

class RecipeCarousel extends StatefulWidget {
  final String title;
  final List<Recipe> recipes;
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
  State<RecipeCarousel> createState() => _RecipeCarouselState();
}

class _RecipeCarouselState extends State<RecipeCarousel> {
  PageController? _pageController;
  static const int _infiniteMultiplier = 10000;

  @override
  void initState() {
    super.initState();
    // Inicializamos después del primer frame para tener acceso seguro al context/mediaquery
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePageController();
    });
  }

  @override
  void didUpdateWidget(RecipeCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si la lista cambia o el tamaño de pantalla cambia drásticamente, reinicializamos
    if (oldWidget.recipes.length != widget.recipes.length) {
      _initializePageController();
    }
  }

  void _initializePageController() {
    if (!mounted) return;

    final viewportFraction = _getViewportFraction(context);

    // Si hay más de 1 receta, usamos scroll infinito
    if (widget.recipes.isNotEmpty && _needsInfiniteScroll) {
      final initialPage = _infiniteMultiplier * widget.recipes.length;
      _pageController = PageController(
        viewportFraction: viewportFraction,
        initialPage: initialPage,
      );
    } else if (widget.recipes.isNotEmpty) {
      // Si hay pocas recetas o 1 sola, scroll normal
      _pageController = PageController(
        viewportFraction: viewportFraction,
        initialPage: 0,
      );
    }

    setState(() {});
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // LÓGICA RESPONSIVE
  // ---------------------------------------------------------------------------

  /// Calcula qué porcentaje de la pantalla ocupa cada tarjeta.
  /// - En móviles: 85% para ver la actual y un trozo ("hint") de la siguiente.
  /// - En Tablets: 50% (2 tarjetas).
  /// - En Desktop: 33% (3 tarjetas).
  double _getViewportFraction(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 360) {
      return 0.95; // Pantallas muy pequeñas: casi pantalla completa
    }
    if (width < ResponsiveBreakpoints.mobile) {
      return 0.85; // Móvil estándar: deja ver un borde de la siguiente
    }
    if (width < ResponsiveBreakpoints.desktop) {
      return 0.5; // Tablet: 2 tarjetas
    }
    return 0.33; // Desktop: 3 tarjetas
  }

  /// Calcula la altura del carrusel para mantener la proporción de las tarjetas
  double _getCarouselHeight() {
    final responsive = ResponsiveHelper(context);
    final width = MediaQuery.of(context).size.width;

    if (responsive.isDesktop) return 320.0;
    if (responsive.isTablet) return 300.0;

    // Para móvil, calculamos altura basada en el ancho de la tarjeta
    // Ancho tarjeta = Ancho pantalla * Viewport (0.85)
    final cardWidth = width * 0.85;
    // Relación de aspecto aprox 1.2 (alto = ancho * 1.2)
    return (cardWidth * 1.2).clamp(280.0, 360.0);
  }

  bool get _needsInfiniteScroll => widget.recipes.length > 1;

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (widget.recipes.isEmpty) {
      if (!widget.showEmptyState) return const SizedBox.shrink();
      return _buildEmptyState();
    }

    return SizedBox(
      height: _getCarouselHeight(),
      child: PageView.builder(
        controller: _pageController,
        // Permite arrastrar con el ratón en Web/Desktop
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
        ),
        itemCount: _needsInfiniteScroll ? null : widget.recipes.length,
        itemBuilder: (context, index) {
          final int recipeIndex = _needsInfiniteScroll
              ? index % widget.recipes.length
              : index;

          return _buildRecipeCard(widget.recipes[recipeIndex], recipeIndex);
        },
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe, int index) {
    return AnimatedBuilder(
      animation: _pageController ?? AlwaysStoppedAnimation(0),
      builder: (context, child) {
        return Center(
          child: Container(
            // Margen para separar las tarjetas entre sí
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Material(
                color: Colors.white,
                child: InkWell(
                  onTap: () => widget.onRecipeTap?.call(index),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Imagen
                      _buildRecipeImage(recipe),

                      // Gradiente Oscuro para el texto
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                            stops: const [0.6, 1.0],
                          ),
                        ),
                      ),

                      // Título
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Text(
                          recipe.nombre,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecipeImage(Recipe recipe) {
    const baseUrl = ApiConfig.baseUrl;

    if (recipe.imagenes != null && recipe.imagenes!.isNotEmpty) {
      final imageUrl = recipe.imagenes!.first.startsWith('http')
          ? recipe.imagenes!.first
          : baseUrl + recipe.imagenes!.first;

      return Image.network(
        imageUrl,
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
          print('❌ Error cargando imagen: $imageUrl');
          return _buildPlaceholder();
        },
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    final responsive = ResponsiveHelper(context);
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Icon(
          Icons.restaurant_menu,
          size: responsive.isDesktop ? 100 : 80,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Text(
        widget.emptyMessage ?? '',
        style: TextStyle(color: Colors.grey[600], fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }
}
