// lib/ui/widgets/recipe/recipe_detail_dialog.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/ui/widgets/recipe/rating_stars.dart';
import 'package:migaz/ui/widgets/recipe/rating_display.dart';
import 'package:migaz/ui/widgets/recipe/recipe_image_widget.dart';
import 'package:migaz/ui/widgets/comentarios/comentarios_popup.dart';
import 'package:migaz/ui/widgets/recipe/ventana_editar_receta.dart';
import 'package:migaz/ui/widgets/recipe/youtube_player_widget.dart';
import 'package:migaz/viewmodels/home_viewmodel.dart';
import 'package:migaz/viewmodels/recipe_list_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:migaz/ui/widgets/auth/user_credentials.dart';
import 'package:carousel_slider/carousel_slider.dart';

class RecipeDetailDialog {
  static void show(BuildContext context, Recipe recipe) {
    showDialog(
      context: context,
      builder: (context) => _RecipeDetailDialogContent(recipe: recipe),
    );
  }
}

class _RecipeDetailDialogContent extends StatefulWidget {
  final Recipe recipe;

  const _RecipeDetailDialogContent({required this.recipe});

  @override
  State<_RecipeDetailDialogContent> createState() =>
      _RecipeDetailDialogContentState();
}

class _RecipeDetailDialogContentState
    extends State<_RecipeDetailDialogContent> {
  late Recipe _recipe;
  double _myRating = 0;
  bool _isRating = false;
  bool _showIngredients = false;
  String _currentUser = 'usuario_demo';

  // 🎨 Para controlar el carrusel de imágenes
  int _currentImageIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final credentials = Provider.of<UserCredentials>(context, listen: false);
      setState(() {
        _currentUser = credentials.email.isNotEmpty
            ? credentials.email.split('@').first
            : 'usuario_demo';
      });
    });
  }

  Widget _buildSaveButton() {
    if (_recipe.esMia(_currentUser)) {
      return const SizedBox.shrink();
    }

    return Consumer<HomeViewModel>(
      builder: (context, homeViewModel, child) {
        final isGuardada = _recipe.isGuardada;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isGuardada
                ? Colors.amber.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isGuardada
                  ? Colors.amber.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.3),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _handleSaveRecipe(homeViewModel),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isGuardada ? Colors.amber : Colors.grey[400],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isGuardada ? Icons.bookmark : Icons.bookmark_border,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isGuardada
                                ? 'Guardada en favoritos'
                                : 'Guardar receta',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isGuardada
                                ? 'Toca para quitar de favoritos'
                                : 'Guarda esta receta para verla después',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isGuardada
                          ? Icons.check_circle
                          : Icons.add_circle_outline,
                      color: isGuardada ? Colors.amber : Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSaveRecipe(HomeViewModel homeViewModel) async {
    if (_recipe.id == null) return;

    final wasGuardada = _recipe.isGuardada;

    final exito = await homeViewModel.toggleGuardarReceta(
      _recipe.id!,
      _currentUser,
    );

    if (mounted && exito) {
      setState(() {
        _recipe.isGuardada = !wasGuardada;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _recipe.isGuardada
                ? '✅ Receta guardada en favoritos'
                : '✅ Receta eliminada de favoritos',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleRating(double rating) async {
    if (_isRating) return;

    setState(() {
      _isRating = true;
      _myRating = rating;
    });

    final homeViewModel = context.read<HomeViewModel>();

    final success = await homeViewModel.valorarReceta(
      _recipe.id!,
      rating,
      'usuario_demo',
    );

    if (success) {
      final updatedRecipes = homeViewModel.todasLasRecetas
          .where((r) => r.id == _recipe.id)
          .toList();

      if (updatedRecipes.isNotEmpty) {
        setState(() {
          _recipe = updatedRecipes.first;
          _isRating = false;
        });
      } else {
        setState(() {
          _isRating = false;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Valoración guardada:  ${rating.toInt()} estrellas',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      setState(() {
        _isRating = false;
        _myRating = 0;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al guardar valoración'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 📐 NUEVO: Obtener dimensiones de la pantalla
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = screenSize.width > 1400
        ? 1400.0
        : screenSize.width * 0.9;
    final dialogHeight = screenSize.height * 0.9;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        // 📐 MODIFICADO: Nuevo tamaño del diálogo más grande y responsive
        width: dialogWidth,
        height: dialogHeight,
        constraints: BoxConstraints(
          maxWidth: 1400,
          maxHeight: dialogHeight,
          minWidth: 800,
        ),
        child: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildHeader(),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildBasicInfo(),
                              const SizedBox(height: 24),
                              _buildRatingSection(),
                              const SizedBox(height: 16),
                              _buildCommentsButton(),
                              const SizedBox(height: 24),
                              _buildEditRecipeButton(),
                              const SizedBox(height: 24),
                              _buildDeleteRecipeButton(),
                              const SizedBox(height: 24),
                              _buildSaveButton(),
                              _buildDescription(),
                              const SizedBox(height: 24),
                              _buildIngredientsToggleButton(),
                              const SizedBox(height: 24),
                              _buildInstructions(),
                              if (_recipe.youtube != null &&
                                  _recipe.youtube!.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                _buildYoutubeLink(),
                              ],
                            ],
                          ),
                        ),
                      ),
                      _buildFooter(),
                    ],
                  ),
                ),
                if (_showIngredients) _buildIngredientsSidePanel(),
              ],
            ),
            Positioned(
              right: _showIngredients ? 310 : 16,
              top: 520, // 📐 AJUSTADO: Nueva posición para carrusel más grande
              child: _buildFloatingIngredientsButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingIngredientsButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        setState(() {
          _showIngredients = !_showIngredients;
        });
      },
      backgroundColor: Colors.green,
      icon: Icon(
        _showIngredients ? Icons.close : Icons.restaurant_menu,
        color: Colors.white,
      ),
      label: Text(
        _showIngredients ? 'Ocultar' : 'Ingredientes',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildIngredientsSidePanel() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 300,
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border(
          left: BorderSide(color: Colors.green.shade300, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(-5, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.restaurant_menu, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Ingredientes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${_recipe.ingredientes.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _recipe.ingredientes.length,
              itemBuilder: (context, index) {
                final ingrediente = _recipe.ingredientes[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          ingrediente,
                          style: const TextStyle(fontSize: 14, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsToggleButton() {
    return InkWell(
      onTap: () {
        setState(() {
          _showIngredients = !_showIngredients;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_menu,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ver ingredientes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${_recipe.ingredientes.length} ingredientes necesarios',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(
              _showIngredients ? Icons.visibility_off : Icons.visibility,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  // 🎨 MODIFICADO: Header con altura responsive
  Widget _buildHeader() {
    if (_recipe.imagenes == null || _recipe.imagenes!.isEmpty) {
      return _buildSimpleHeader(null);
    }

    if (_recipe.imagenes!.length == 1) {
      return _buildSimpleHeader(_recipe.imagenes!.first);
    }

    return _buildCarouselHeader();
  }

  // 📐 MODIFICADO: Header simple con altura de 500px
  Widget _buildSimpleHeader(String? imageUrl) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: RecipeImageWidget(
            imageUrl: imageUrl,
            width: double.infinity,
            height: 300, //!!
            fit: BoxFit.contain,
          ),
        ),
        Container(
          height: 300, //!!
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
              stops: const [0.0, 0.6, 1.0], // 📐 NUEVO: Gradiente más suave
            ),
          ),
        ),
        Positioned(
          bottom: 24, // 📐 AJUSTADO: Más espacio desde el borde
          left: 24,
          right: 24,
          child: Text(
            _recipe.nombre,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32, // 📐 AUMENTADO: Texto más grande
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black, blurRadius: 10)],
            ),
          ),
        ),
      ],
    );
  }

  // 📐 MODIFICADO: Carrusel con drag habilitado
  // 📐 MODIFICADO: Carrusel con drag personalizado habilitado
  Widget _buildCarouselHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final carouselHeight = 300.0;
        double _dragStartX = 0;
        double _dragDistance = 0;

        return Stack(
          children: [
            // 🎯 NUEVO: GestureDetector para capturar drag en desktop/web
            GestureDetector(
              onHorizontalDragStart: (details) {
                _dragStartX = details.globalPosition.dx;
                _dragDistance = 0;
              },
              onHorizontalDragUpdate: (details) {
                _dragDistance = details.globalPosition.dx - _dragStartX;
              },
              onHorizontalDragEnd: (details) {
                // Si el drag es mayor a 50 pixels, cambiar de imagen
                if (_dragDistance > 50) {
                  // Drag hacia la derecha -> imagen anterior
                  if (_currentImageIndex > 0) {
                    _carouselController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                } else if (_dragDistance < -50) {
                  // Drag hacia la izquierda -> imagen siguiente
                  if (_currentImageIndex < _recipe.imagenes!.length - 1) {
                    _carouselController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                }
              },
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  height: carouselHeight,
                  color: Colors.grey[900],
                  child: CarouselSlider(
                    carouselController: _carouselController,
                    options: CarouselOptions(
                      height: carouselHeight,
                      viewportFraction: 1.0,
                      enableInfiniteScroll:
                          false, // 🎯 Deshabilitado para mejor UX
                      autoPlay: false,
                      enlargeCenterPage: false,
                      scrollDirection: Axis.horizontal,
                      pageSnapping: true,
                      // 🎯 IMPORTANTE: Deshabilitar scroll physics para que solo funcione el drag manual
                      disableCenter: true,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                    ),
                    items: _recipe.imagenes!.map((imageUrl) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: constraints.maxWidth,
                            child: RecipeImageWidget(
                              imageUrl: imageUrl,
                              width: double.infinity,
                              height: carouselHeight,
                              fit: BoxFit.contain,
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            // Gradiente oscuro para el texto (NO debe capturar eventos)
            IgnorePointer(
              child: Container(
                height: carouselHeight,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),

            // Título de la receta (NO debe capturar eventos)
            IgnorePointer(
              child: Positioned(
                bottom: 70,
                left: 24,
                right: 24,
                child: Text(
                  _recipe.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                  ),
                ),
              ),
            ),

            // 🎨 Indicadores de página (dots) - DEBEN capturar eventos
            if (_recipe.imagenes!.length > 1)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _recipe.imagenes!.asMap().entries.map((entry) {
                    return GestureDetector(
                      onTap: () {
                        _carouselController.animateToPage(
                          entry.key,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: _currentImageIndex == entry.key ? 14 : 10,
                        height: _currentImageIndex == entry.key ? 14 : 10,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentImageIndex == entry.key
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            // 🎨 Contador de imágenes (NO debe capturar eventos)
            if (_recipe.imagenes!.length > 1)
              IgnorePointer(
                child: Positioned(
                  top: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.image, color: Colors.white, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          '${_currentImageIndex + 1}/${_recipe.imagenes!.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 🎯 NUEVO: Flechas de navegación para desktop (aparecen al hover)
            if (_recipe.imagenes!.length > 1) ...[
              // Flecha izquierda
              if (_currentImageIndex > 0)
                Positioned(
                  left: 16,
                  top: carouselHeight / 2 - 24,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        _carouselController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),

              // Flecha derecha
              if (_currentImageIndex < _recipe.imagenes!.length - 1)
                Positioned(
                  right: 16,
                  top: carouselHeight / 2 - 24,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        _carouselController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_recipe.createdAt != null) _buildCreatedAtBanner(),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildInfoChip(Icons.category, _recipe.categoria, Colors.blue),
            _buildInfoChip(
              Icons.people,
              '${_recipe.comensales} personas',
              Colors.green,
            ),
            _buildInfoChip(Icons.timer, _recipe.tiempo, Colors.orange),
            _buildInfoChip(
              Icons.signal_cellular_alt,
              _getDifficultyLabel(_recipe.dificultad),
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCreatedAtBanner() {
    if (_recipe.createdAt == null) return const SizedBox.shrink();

    final fechaCompleta = _formatearFechaCompleta(_recipe.createdAt!);
    final fechaRelativa = _formatearFechaRelativa(_recipe.createdAt!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade400, Colors.teal.shade600],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today, size: 18, color: Colors.white),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fechaCompleta,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                fechaRelativa,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatearFechaCompleta(String fechaString) {
    try {
      final fecha = DateTime.parse(fechaString);

      final meses = [
        '',
        'enero',
        'febrero',
        'marzo',
        'abril',
        'mayo',
        'junio',
        'julio',
        'agosto',
        'septiembre',
        'octubre',
        'noviembre',
        'diciembre',
      ];

      final dia = fecha.day;
      final mes = meses[fecha.month];
      final anios = fecha.year;
      final hora = fecha.hour.toString().padLeft(2, '0');
      final minuto = fecha.minute.toString().padLeft(2, '0');

      return '$dia de $mes de $anios a las $hora: $minuto';
    } catch (e) {
      print('❌ Error al formatear fecha completa: $e');
      return 'Fecha desconocida';
    }
  }

  String _formatearFechaRelativa(String fechaString) {
    try {
      final fecha = DateTime.parse(fechaString);
      final ahora = DateTime.now();
      final diferencia = ahora.difference(fecha);

      if (diferencia.inSeconds < 60) {
        return 'Publicada hace unos segundos';
      }

      if (diferencia.inMinutes < 60) {
        final minutos = diferencia.inMinutes;
        return 'Publicada hace $minutos ${minutos == 1 ? "minuto" : "minutos"}';
      }

      if (diferencia.inHours < 24) {
        final horas = diferencia.inHours;
        return 'Publicada hace $horas ${horas == 1 ? "hora" : "horas"}';
      }

      if (diferencia.inDays < 7) {
        final dias = diferencia.inDays;
        return 'Publicada hace $dias ${dias == 1 ? "día" : "días"}';
      }

      if (diferencia.inDays < 30) {
        final semanas = (diferencia.inDays / 7).floor();
        return 'Publicada hace $semanas ${semanas == 1 ? "semana" : "semanas"}';
      }

      if (diferencia.inDays < 365) {
        final meses = (diferencia.inDays / 30).floor();
        return 'Publicada hace $meses ${meses == 1 ? "mes" : "meses"}';
      }

      final anios = (diferencia.inDays / 365).floor();
      return 'Publicada hace $anios ${anios == 1 ? "año" : "años"}';
    } catch (e) {
      print('❌ Error al formatear fecha relativa: $e');
      return 'Publicada recientemente';
    }
  }

  String _formatearFecha(String fechaString) {
    try {
      final fecha = DateTime.parse(fechaString);
      final ahora = DateTime.now();
      final diferencia = ahora.difference(fecha);

      if (diferencia.inSeconds < 60) {
        return 'hace unos segundos';
      }

      if (diferencia.inMinutes < 60) {
        final minutos = diferencia.inMinutes;
        return 'hace $minutos ${minutos == 1 ? "minuto" : "minutos"}';
      }

      if (diferencia.inHours < 24) {
        final horas = diferencia.inHours;
        return 'hace $horas ${horas == 1 ? "hora" : "horas"}';
      }

      if (diferencia.inDays < 7) {
        final dias = diferencia.inDays;
        return 'hace $dias ${dias == 1 ? "día" : "días"}';
      }

      if (diferencia.inDays < 30) {
        final semanas = (diferencia.inDays / 7).floor();
        return 'hace $semanas ${semanas == 1 ? "semana" : "semanas"}';
      }

      if (diferencia.inDays < 365) {
        final meses = (diferencia.inDays / 30).floor();
        return 'hace $meses ${meses == 1 ? "mes" : "meses"}';
      }

      final anios = (diferencia.inDays / 365).floor();
      return 'hace $anios ${anios == 1 ? "año" : "años"}';
    } catch (e) {
      print('❌ Error al formatear fecha:  $e');
      return 'Fecha desconocida';
    }
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Chip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
    );
  }

  String _getDifficultyLabel(int dificultad) {
    switch (dificultad) {
      case 1:
        return 'Muy Fácil';
      case 2:
        return 'Fácil';
      case 3:
        return 'Medio';
      case 4:
        return 'Difícil';
      case 5:
        return 'Muy Difícil';
      default:
        return 'Medio';
    }
  }

  Widget _buildRatingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Valoración',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Promedio:  ',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 12),
              RatingDisplay(
                rating: _recipe.valoracion,
                totalVotes: _recipe.cantidadVotos,
                size: 24,
                showNumber: true,
                showVotes: true,
              ),
            ],
          ),
          const Divider(height: 24),
          const Text(
            '¿Qué te ha parecido?',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              RatingStars(
                initialRating: _myRating,
                onRatingChanged: _handleRating,
                size: 36,
                enabled: !_isRating,
              ),
              if (_isRating) ...[
                const SizedBox(width: 16),
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditRecipeButton() {
    final esCreador = _recipe.esMia(_currentUser);
    if (!esCreador) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _handleEditRecipe, // A continuación implementamos esta función
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Editar receta',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteRecipeButton() {
    final esCreador = _recipe.esMia(_currentUser);
    if (!esCreador) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap:
              _handleDeleteRecipe, // A continuación implementamos esta función
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 0, 0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Eliminar receta',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleDeleteRecipe() async {
    final shouldDelete = await _confirmDelete();

    if (!shouldDelete) {
      print('⚪ Eliminación cancelada por el usuario.');
      return;
    }

    try {
      print('🚀 Llamando a eliminarReceta...');

      final recipeVM = Provider.of<RecipeListViewModel>(context, listen: false);

      final exito = await recipeVM.eliminarReceta(_recipe.id!);

      if (!mounted) return;

      if (exito) {
        print('✅ Receta eliminada correctamente');

        // Cierra el diálogo de detalle de la receta
        Navigator.of(context).pop();

        // Muestra un mensaje de éxito en la pantalla principal
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🗑️ Receta eliminada correctamente'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        print('❌ Error al eliminar: ${recipeVM.errorMessage}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ ${recipeVM.errorMessage ?? "No se pudo eliminar la receta"}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('💥 ERROR INESPERADO en _handleDeleteRecipe: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error inesperado: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<bool> _confirmDelete() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar Eliminación'),
            content: Text(
              '¿Estás seguro de que quieres eliminar la receta "${_recipe.nombre}"? Esta acción es irreversible.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _handleEditRecipe() async {
    try {
      print('🔵 Iniciando edición de receta...');

      final edited = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => DialogoEditarReceta(
          recetaOriginal: _recipe,
          dificultades: [
            'Muy Fácil',
            'Fácil',
            'Medio',
            'Difícil',
            'Muy Difícil',
          ],
        ),
      );

      if (edited == null) {
        print('⚪ Edición cancelada por el usuario');
        return;
      }

      print('🟢 Datos recibidos del diálogo de edición');

      final Recipe recetaEditada = edited['receta'] as Recipe;
      final List<XFile>? imagenesNuevas =
          edited['imagenesNuevas'] as List<XFile>?;
      final List<String>? imagenesPrevias =
          edited['imagenesPrevias'] as List<String>?;

      print('📝 Receta editada: ${recetaEditada.nombre}');
      print('📸 Imágenes nuevas: ${imagenesNuevas?.length ?? 0}');
      print('📸 Imágenes previas: ${imagenesPrevias?.length ?? 0}');

      // Manejo de imágenes nuevas: XFile -> File si no es web
      List<File>? imagenes;
      List<XFile>? imagenesWeb;

      if (imagenesNuevas != null && imagenesNuevas.isNotEmpty) {
        if (kIsWeb) {
          imagenesWeb = imagenesNuevas;
          print('🌐 Usando imágenes web: ${imagenesWeb.length}');
        } else {
          imagenes = imagenesNuevas.map((xfile) => File(xfile.path)).toList();
          print('📱 Usando imágenes móvil: ${imagenes.length}');
        }
      }

      // Llama al ViewModel
      final recipeVM = Provider.of<RecipeListViewModel>(context, listen: false);

      print('🚀 Llamando a actualizarReceta...');

      // 🔴 CAMBIO CLAVE 1: Capturamos la receta actualizada (Recipe?)
      final Recipe? updatedRecipe = await recipeVM.actualizarReceta(
        _recipe.id!,
        recetaEditada,
        usuarioActual: _currentUser,
        imagenes: imagenes,
        imagenesXFile: imagenesWeb,
        imagenesPrevias: imagenesPrevias,
      );

      if (!mounted) return;

      // 🔴 CAMBIO CLAVE 2: Comprobamos si el resultado NO es nulo (éxito)
      if (updatedRecipe != null) {
        print('✅ Receta actualizada correctamente');

        // 🔴 CAMBIO CLAVE 3: Actualizamos el estado local del diálogo
        setState(() {
          _recipe =
              updatedRecipe; // Sincronizamos la receta con la nueva versión
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Receta editada correctamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // La actualización falló, usamos el mensaje de error del ViewModel
        print('❌ Error al actualizar: ${recipeVM.errorMessage}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ ${recipeVM.errorMessage ?? "No se pudo editar la receta"}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('💥 ERROR INESPERADO en _handleEditRecipe: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error inesperado: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildCommentsButton() {
    final comentariosCount = _recipe.comentarios.length;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _showComments,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.comment,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Comentarios',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        comentariosCount == 0
                            ? 'Sé el primero en comentar'
                            : '$comentariosCount ${comentariosCount == 1 ? "comentario" : "comentarios"}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComments() {
    final credentials = Provider.of<UserCredentials>(context, listen: false);
    final currentUser = credentials.email.isNotEmpty
        ? credentials.email.split('@').first
        : 'usuario_demo';

    ComentariosPopup.show(
      context: context,
      recipe: _recipe,
      currentUserName: currentUser,
    );
  }

  Widget _buildDescription() {
    if (_recipe.descripcion.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          _recipe.descripcion,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Instrucciones',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._recipe.pasos.asMap().entries.map((entry) {
          final index = entry.key;
          final paso = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    paso,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildYoutubeLink() {
    // Validar que la URL existe y no está vacía
    if (_recipe.youtube == null || _recipe.youtube!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return YoutubePlayerWidget(youtubeUrl: _recipe.youtube!);
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
