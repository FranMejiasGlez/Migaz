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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePageController();
    });
  }

  @override
  void didUpdateWidget(RecipeCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recipes.length != widget.recipes.length) {
      _initializePageController();
    }
  }

  void _initializePageController() {
    if (!mounted) return;

    final viewportFraction = _getViewportFraction(context);

    if (widget.recipes.isNotEmpty && _needsInfiniteScroll) {
      final initialPage = _infiniteMultiplier * widget.recipes.length;
      _pageController = PageController(
        viewportFraction: viewportFraction,
        initialPage: initialPage,
      );
    } else if (widget.recipes.isNotEmpty) {
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

  double _getViewportFraction(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 360) {
      return 0.95;
    }
    if (width < ResponsiveBreakpoints.mobile) {
      return 0.85;
    }
    if (width < ResponsiveBreakpoints.desktop) {
      return 0.5;
    }
    return 0.33;
  }

  double _getCarouselHeight() {
    final responsive = ResponsiveHelper(context);
    final width = MediaQuery.of(context).size.width;

    if (responsive.isDesktop) return 320.0;
    if (responsive.isTablet) return 300.0;

    final cardWidth = width * 0.85;
    return (cardWidth * 1.2).clamp(280.0, 360.0);
  }

  bool get _needsInfiniteScroll => widget.recipes.length > 1;

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
                      _buildRecipeImage(recipe),

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

  // ✅ CORREGIDO: Construcción correcta de la URL
  Widget _buildRecipeImage(Recipe recipe) {
    // Verificar si la receta tiene imágenes
    if (recipe.imagenes == null || recipe.imagenes!.isEmpty) {
      print('⚠️ Receta "${recipe.nombre}" sin imágenes');
      return _buildPlaceholder();
    }

    final firstImage = recipe.imagenes!.first;

    // ✅ Construir URL correctamente usando serverUrl (sin /api)
    String imageUrl = 'http://localhost:3000/img';
    if (firstImage.startsWith('http://') || firstImage.startsWith('https://')) {
      // Ya es una URL completa
      imageUrl = firstImage;
    } else if (firstImage.startsWith('/')) {
      // Ruta absoluta desde el servidor (sin /api)
      imageUrl = '${ApiConfig.baseUrl}$firstImage';
    } else {
      // Ruta relativa
      imageUrl = '${ApiConfig.baseUrl}/$firstImage';
    }

    print('🖼️ Cargando imagen: $imageUrl');

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
        print('❌ Error cargando imagen de "${recipe.nombre}": $imageUrl');
        print('   Error: $error');
        return _buildPlaceholder();
      },
    );
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
