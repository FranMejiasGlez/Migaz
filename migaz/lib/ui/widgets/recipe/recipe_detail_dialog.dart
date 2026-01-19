import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:migaz/core/config/api_config.dart';
import 'package:migaz/core/config/routes.dart';
import 'package:migaz/core/constants/recipe_constants.dart';
import 'package:migaz/core/utils/responsive_breakpoints.dart';
import 'package:migaz/core/utils/responsive_helper.dart';
import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/ui/views/pantalla_cargar_recetas_distinto_user.dart';
import 'package:migaz/ui/widgets/recipe/recipe_carousel.dart';
import 'package:migaz/ui/widgets/recipe/rating_stars.dart';
import 'package:migaz/ui/widgets/recipe/rating_display.dart';
import 'package:migaz/ui/widgets/recipe/recipe_image_widget.dart';
import 'package:migaz/ui/widgets/comentarios/comentarios_popup.dart';
import 'package:migaz/ui/widgets/recipe/ventana_editar_receta.dart';
import 'package:migaz/ui/widgets/recipe/youtube_player_widget.dart';
import 'package:migaz/viewmodels/biblioteca_viewmodel.dart';
import 'package:migaz/viewmodels/home_viewmodel.dart';
import 'package:migaz/viewmodels/auth_viewmodel.dart'; // Added
import 'package:migaz/viewmodels/recipe_list_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:migaz/ui/widgets/auth/user_credentials.dart';
import 'package:carousel_slider/carousel_slider.dart';

class RecipeDetailDialog {
  static Future<bool?> show(BuildContext context, Recipe recipe) {
    return showDialog<bool>(
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
  // bool _hasChanged = false;
  double _myRating = 0;
  bool _isRating = false;
  bool _showIngredients = false;
  String _currentUser = ApiConfig.currentUser;

  // 🎨 Para controlar el carrusel de imágenes
  int _currentImageIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // final credentials = Provider.of<UserCredentials>(context, listen: false);
      setState(() {
        _currentUser = ApiConfig.currentUser;
      });
    });
  }

  Widget _buildSaveButton() {
    if (_isCurrentUserRecipeOwner()) return const SizedBox.shrink();
    //print(!_isCurrentUserRecipeOwner());
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

    final authVM = context.read<AuthViewModel>(); // Get AuthViewModel
    final userId = authVM.currentUserId; // Get ID

    final exito = await homeViewModel.toggleGuardarReceta(
      _recipe.id!,
      _currentUser,
      userId: userId, // Pass userId
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
      ApiConfig.currentUser, //!
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
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final responsive = ResponsiveHelper(context);

    // Dimensiones del diálogo
    double dialogWidth = screenSize.width * 0.98;
    double dialogHeight = screenSize.height * 0.98;

    if (responsive.isDesktop) {
      dialogWidth = screenSize.width > 1400 ? 1200 : screenSize.width * 0.8;
      dialogHeight = screenSize.height * 0.9;
    } else if (responsive.isTablet) {
      dialogWidth = screenSize.width * 0.95;
      dialogHeight = screenSize.height * 0.95;
    }

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 2 : 24,
        vertical: isMobile ? 8 : 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        constraints: BoxConstraints(
          maxWidth: 1400,
          maxHeight: screenSize.height * 0.99,
          minWidth: isMobile ? 0 : 350,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // 1. CONTENIDO PRINCIPAL (Scrollable)
                Column(
                  children: [
                    _buildHeader(), // Imagen de cabecera
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(isMobile ? 12 : 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBasicInfo(),
                            const SizedBox(height: 16),

                            // --- 🔴 RESTAURADO: Botones de Acción ---
                            _buildSaveButton(),
                            const SizedBox(height: 12),
                            // Solo se muestran si es el dueño
                            _buildEditRecipeButton(),
                            _buildDeleteRecipeButton(),
                            const SizedBox(height: 16),

                            // ----------------------------------------
                            _buildRatingSection(),
                            const SizedBox(height: 16),
                            _buildCommentsButton(),

                            // (Eliminamos la lista de ingredientes inline anterior
                            // para forzar el uso del panel flotante en todos los casos)
                            const SizedBox(height: 24),
                            _buildDescription(),
                            const SizedBox(height: 24),
                            _buildInstructions(),
                            const SizedBox(height: 24),
                            _buildYoutubeLink(),
                          ],
                        ),
                      ),
                    ),
                    _buildFooter(),
                  ],
                ),

                // 2. PANEL DE INGREDIENTES FLOTANTE (Para TODOS los dispositivos)
                // Se muestra condicionalmente con _showIngredients
                if (_showIngredients)
                  Positioned(
                    top: 20, // 📍 Encima de la fotografía (parte superior)
                    right: 20,
                    // Usamos un ancho seguro para que en móviles muy estrechos no se salga
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth:
                            screenSize.width *
                            0.85, // Max 85% del ancho en móvil
                      ),
                      child: _buildIngredientsFloatingCard(
                        constraints.maxHeight,
                      ),
                    ),
                  ),

                // 3. BOTÓN FLOTANTE (FAB)
                // Siempre visible para poder abrir/cerrar los ingredientes
                Positioned(
                  bottom: 10,
                  left: 20,
                  child: FloatingActionButton(
                    backgroundColor: Colors.green[400],
                    // Más pequeño en desktop, normal en móvil para facilitar el toque
                    mini: responsive.isDesktop,
                    elevation: 6,
                    onPressed: () =>
                        setState(() => _showIngredients = !_showIngredients),
                    child: Icon(
                      _showIngredients
                          ? Icons.visibility_off
                          : Icons.restaurant_menu,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildIngredientsFloatingCard(double parentHeight) {
    // Obtenemos el ancho de pantalla para validar
    final screenWidth = MediaQuery.of(context).size.width;
    // Si la pantalla es muy pequeña (<320), ajustamos el ancho de la tarjeta
    final cardWidth = screenWidth < 320 ? screenWidth - 40 : 280.0;

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      color: Colors.transparent,
      child: Container(
        width: cardWidth, // ✅ Ancho adaptado
        constraints: BoxConstraints(
          maxHeight: parentHeight * 0.60, // Máximo 60% de la altura del diálogo
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(
            0.96,
          ), // Casi opaco para mejor lectura sobre fotos
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // CABECERA
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.restaurant_menu,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Ingredientes',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => setState(() => _showIngredients = false),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // LISTA DE INGREDIENTES
            Flexible(
              flex: 3,
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                shrinkWrap: true,
                itemCount: _recipe.ingredientes.length,
                separatorBuilder: (_, __) => const Divider(height: 12),
                itemBuilder: (context, index) {
                  final ingrediente = _recipe.ingredientes[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Icon(
                          Icons.circle,
                          size: 6,
                          color: Colors.green.shade400,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          ingrediente,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // PIE CON CONTADOR
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Center(
                child: Text(
                  '${_recipe.ingredientes.length} items',
                  style: TextStyle(fontSize: 12, color: Colors.green.shade700),
                ),
              ),
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
            InkWell(
              onTap: () {
                if (_recipe.user != null && _recipe.user!.isNotEmpty) {
                  _goToUserProfile(_recipe.user!);
                }
              },
              borderRadius: BorderRadius.circular(16), // Match chip radius
              child: _buildInfoChip(
                Icons.person,
                _recipe.user ?? 'Desconocido',
                Colors.teal,
                isAction: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _goToUserProfile(String user) {
    // Cerramos el diálogo actual
    Navigator.of(context).pop();

    // Navegamos a la pantalla del perfil del usuario
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaRecetasDistinctUser(nombreUsuario: user),
      ),
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
      // print('❌ Error al formatear fecha completa: $e');
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
      // print('❌ Error al formatear fecha relativa: $e');
      return 'Publicada recientemente';
    }
  }

  Widget _buildInfoChip(
    IconData icon,
    String label,
    Color color, {
    bool isAction = false,
  }) {
    return Chip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(
        label,
        style: isAction
            ? TextStyle(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationColor: color,
              )
            : null,
      ),
      backgroundColor: color.withOpacity(0.1),
      side: isAction
          ? BorderSide(color: color.withOpacity(0.5))
          : BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
    if (!_isCurrentUserRecipeOwner()) return const SizedBox.shrink();

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
    if (!_isCurrentUserRecipeOwner()) return const SizedBox.shrink();

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

  /// Devuelve true si el usuario actual es el creador original de la receta
  bool _isCurrentUserRecipeOwner() {
    // Compara el usuario actual con el campo user de la receta
    // (ajusta si el campo en la base de datos es diferente)
    return (_recipe.user != null && _recipe.user == _currentUser);
  }

  Future<void> _handleDeleteRecipe() async {
    final shouldDelete = await _confirmDelete();

    if (!shouldDelete) {
      // ignore: avoid_print
      // print('⚪ Eliminación cancelada por el usuario.');
      return;
    }

    try {
      final recipeVM = Provider.of<RecipeListViewModel>(context, listen: false);
      final exito = await recipeVM.eliminarReceta(_recipe.id!);

      if (!mounted) return;

      if (exito) {
        // Es buena práctica actualizar HomeViewModel también
        if (mounted) {
          await context.read<HomeViewModel>().cargarHome();
        }

        // 2️⃣ CLAVE: Cerramos el diálogo pasando 'true' para indicar éxito en la eliminación
        Navigator.of(context).pop(true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🗑️ Receta eliminada correctamente'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // print('❌ Error al eliminar: ${recipeVM.errorMessage}');
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
      // print('💥 ERROR INESPERADO en _handleDeleteRecipe: $e');
      // print('Stack trace: $stackTrace');

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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.withOpacity(0.3),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: RecipeConstants.buttonElevation,
                ),
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
      //print('🔵 Iniciando edición de receta...');

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
        // print('⚪ Edición cancelada por el usuario');
        return;
      }

      print('🟢 Datos recibidos del diálogo de edición');

      final Recipe recetaEditada = edited['receta'] as Recipe;
      final List<XFile>? imagenesNuevas =
          edited['imagenesNuevas'] as List<XFile>?;
      final List<String>? imagenesPrevias =
          edited['imagenesPrevias'] as List<String>?;

      //  print('📝 Receta editada: ${recetaEditada.nombre}');
      //  print('📸 Imágenes nuevas: ${imagenesNuevas?.length ?? 0}');
      // print('📸 Imágenes previas: ${imagenesPrevias?.length ?? 0}');

      // Manejo de imágenes nuevas: XFile -> File si no es web
      List<File>? imagenes;
      List<XFile>? imagenesWeb;

      if (imagenesNuevas != null && imagenesNuevas.isNotEmpty) {
        if (kIsWeb) {
          imagenesWeb = imagenesNuevas;
          //    print('🌐 Usando imágenes web: ${imagenesWeb.length}');
        } else {
          imagenes = imagenesNuevas.map((xfile) => File(xfile.path)).toList();
          //    print('📱 Usando imágenes móvil: ${imagenes.length}');
        }
      }

      // Llama al ViewModel
      final recipeVM = Provider.of<RecipeListViewModel>(context, listen: false);

      //  print('🚀 Llamando a actualizarReceta...');

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
        //  print('✅ Receta actualizada correctamente');

        // 🔴 CAMBIO CLAVE 3: Actualizamos el estado local del diálogo
        setState(() {
          _recipe =
              updatedRecipe; // Sincronizamos la receta con la nueva versión
        });
        if (mounted) {
          await context.read<HomeViewModel>().cargarHome();
          //   print('✅ HomeViewModel recargado');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Receta editada correctamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // La actualización falló, usamos el mensaje de error del ViewModel
        //   print('❌ Error al actualizar: ${recipeVM.errorMessage}');

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
      // print('💥 ERROR INESPERADO en _handleEditRecipe: $e');
      //  print('Stack trace: $stackTrace');

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
    //  final credentials = Provider.of<UserCredentials>(context, listen: false);
    final currentUser = ApiConfig.currentUser;

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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25CCAD),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: RecipeConstants.buttonElevation,
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  String? userOwner(Recipe recipe) {
    return _recipe.user;
  }
}
