import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:migaz/core/config/api_config.dart';
import 'package:migaz/core/config/routes.dart';
import 'package:migaz/core/constants/recipe_constants.dart';
import 'package:migaz/core/utils/recipe_utils.dart';
import 'package:migaz/core/utils/responsive_breakpoints.dart';
import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/data/repositories/receta_repository.dart';
import 'package:migaz/ui/widgets/recipe/recipe_detail_dialog.dart';
import 'package:migaz/ui/widgets/recipe/recipe_grid_view.dart';
import 'package:migaz/ui/widgets/recipe/recipe_search_section.dart';
import 'package:migaz/ui/widgets/recipe/user_avatar.dart';
import 'package:migaz/ui/widgets/recipe/ventana_crear_receta.dart';
import 'package:migaz/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:migaz/ui/widgets/recipe/recipe_carousel.dart';
import 'package:migaz/viewmodels/home_viewmodel.dart';
import 'package:migaz/viewmodels/recipe_list_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:migaz/core/utils/responsive_helper.dart';

class PantallaBiblioteca extends StatefulWidget {
  final List<Recipe>? listaRecetas;

  const PantallaBiblioteca({Key? key, this.listaRecetas}) : super(key: key);

  @override
  State<PantallaBiblioteca> createState() => _PantallaBibliotecaState();
}

class _PantallaBibliotecaState extends State<PantallaBiblioteca> {
  final TextEditingController _searchController = TextEditingController();
  final RecetaRepository _recetaRepository = RecetaRepository();

  List<Recipe> _misRecetas = [];
  List<Recipe> _recetasGuardadas = [];
  String _searchQuery = '';
  String _filtroSeleccionado = 'Todos';
  bool _isLoading = true;
  String? _errorMessage;

  final String _currentUser = ApiConfig.currentUser; //!!

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔥 Cargando recetas de: $_currentUser');

      final misRecetas = await _recetaRepository.obtenerPorUsuario(
        _currentUser,
      );

      if (mounted) {
        final homeViewModel = context.read<HomeViewModel>();
        await homeViewModel.cargarHome();
        await homeViewModel.cargarGuardadas(_currentUser);

        final recetasGuardadas = homeViewModel.recetasGuardadas;

        setState(() {
          _misRecetas = misRecetas;
          _recetasGuardadas = recetasGuardadas;
          _isLoading = false;
        });

        print('✅ Mis recetas cargadas: ${misRecetas.length}');
        print('✅ Recetas guardadas: ${recetasGuardadas.length}');
      }
    } catch (e) {
      print('❌ Error al cargar datos de biblioteca: $e');
      setState(() {
        _errorMessage = 'Error al cargar tu biblioteca';
        _isLoading = false;
      });
    }
  }

  List<Recipe> get _todasLasRecetas {
    return [..._misRecetas, ..._recetasGuardadas];
  }

  List<Recipe> get _recetasFiltradas {
    return RecipeUtils.filterRecipes(
      recipes: _todasLasRecetas,
      searchQuery: _searchQuery,
      selectedFilter: _filtroSeleccionado,
    );
  }

  bool get _hasActiveFilters {
    return RecipeUtils.hasActiveFilters(
      searchQuery: _searchQuery,
      selectedFilter: _filtroSeleccionado,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecipeListViewModel(),
      child: Consumer<RecipeListViewModel>(
        builder: (context, recipeListViewModel, child) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(gradient: AppTheme.appGradient),
              child: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildSearchSection(),
                    const SizedBox(height: 16),
                    _buildNavigationButtons(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _hasActiveFilters
                          ? _buildSearchResults()
                          : _buildHomeContent(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBackButton(),
          const SizedBox(width: 8),
          // El título ahora es flexible
          Expanded(child: _buildTitle()),
          const SizedBox(width: 8),
          UserAvatar(
            imageUrl: RecipeConstants.defaultAvatarUrl,
            onTap: () => Navigator.pushNamed(context, AppRoutes.perfilUser),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return SizedBox(
      child: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pushNamed(context, AppRoutes.home),
      ),
    );
  }

  Widget _buildTitle() {
    // ELIMINADO: SizedBox con width: 300
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEA7317).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        children: [
          const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Tu biblioteca',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          if (!_isLoading)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${_todasLasRecetas.length} ${_todasLasRecetas.length == 1 ? "receta" : "recetas"}',
                style: TextStyle(fontSize: 12, color: Colors.grey[800]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return RecipeSearchSection(
      searchController: _searchController,
      selectedFilter: _filtroSeleccionado,
      onSearchChanged: (value) => setState(() => _searchQuery = value),
      onClearSearch: () => setState(() {
        _searchController.clear();
        _searchQuery = '';
      }),
      onFilterChanged: (newValue) {
        if (newValue != null) {
          setState(() => _filtroSeleccionado = newValue);
        }
      },
      showClearButton: _searchQuery.isNotEmpty,
    );
  }

  Widget _buildNavigationButtons() {
    return Consumer<RecipeListViewModel>(
      builder: (context, viewModel, child) {
        // 1. Detectamos si es móvil usando tu clase existente
        final bool isMobile = ResponsiveBreakpoints.isMobile(context);

        // OPCIÓN A: Diseño para MÓVIL (2 filas)
        if (isMobile) {
          return Column(
            children: [
              // Fila 1: Botones de navegación
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildNavigationButton(
                    icon: Icons.bookmark,
                    label: 'Guardados',
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.guardados),
                  ),
                  const SizedBox(width: 16),
                  _buildNavigationButton(
                    icon: Icons.edit,
                    label: 'Mis Recetas',
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.misrecetas),
                  ),
                ],
              ),
              const SizedBox(height: 16), // Espacio vertical
              // Fila 2: Botón de crear receta (Centrado y completo)
              _buildCreateRecipeButtonInline(context, viewModel),
            ],
          );
        }

        // OPCIÓN B: Diseño para TABLET/PC (Todo en una fila)
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNavigationButton(
              icon: Icons.bookmark,
              label: 'Guardados',
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.guardados),
            ),
            const SizedBox(width: 16),
            _buildNavigationButton(
              icon: Icons.edit,
              label: 'Mis Recetas',
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.misrecetas),
            ),
            const SizedBox(width: 16),
            // En pantallas grandes, cabe al lado
            _buildCreateRecipeButtonInline(context, viewModel),
          ],
        );
      },
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEA7317).withOpacity(0.5),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              RecipeConstants.buttonBorderRadius,
            ),
          ),
          elevation: 0,
          minimumSize: const Size(80, 36),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [Text(label, style: const TextStyle(fontSize: 14))],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_recetasFiltradas.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off,
        message: 'No se encontraron recetas',
      );
    }

    return RecipeGridView(recipes: _recetasFiltradas);
  }

  Widget _buildHomeContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              _buildCarouselSection(
                title: 'Mis Recetas',
                recipes: _misRecetas,
                emptyMessage: 'No tienes recetas personales aún',
              ),
              const SizedBox(height: 24),
              _buildCarouselSection(
                title: 'Guardados',
                recipes: _recetasGuardadas,
                emptyMessage: 'No has guardado ninguna receta',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Error desconocido',
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _cargarDatos,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryYellow,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselSection({
    required String title,
    required List<Recipe> recipes,
    required String emptyMessage,
  }) {
    return Column(
      children: [
        _buildCarouselTitle(title, recipes.length),
        const SizedBox(height: 8),
        RecipeCarousel(
          title: '',
          recipes: recipes,
          emptyMessage: emptyMessage,
          // CORRECCIÓN AQUÍ:
          onRecipeTap: (index) async {
            if (recipes.isNotEmpty) {
              // 1. Esperamos a que se cierre el diálogo (sin importar lo que devuelva)
              await RecipeDetailDialog.show(context, recipes[index]);

              // 2. Al volver, recargamos los datos SIEMPRE
              if (mounted) {
                // Esto refresca tanto "Mis Recetas" como "Guardados"
                await _cargarDatos();
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildCarouselTitle(String title, int count) {
    return Center(
      child: Container(
        // ELIMINADO: width: 600 -> Cambiado a constraints o width relativo
        constraints: const BoxConstraints(maxWidth: 600),
        width: double.infinity,
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
        ), // Margen para que no toque bordes
        decoration: BoxDecoration(
          color: const Color(0xFFEA7317).withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }

  // ✅ NUEVO: Botón de crear receta inline (debajo de navegación)
  Widget _buildCreateRecipeButtonInline(
    BuildContext context,
    RecipeListViewModel viewModel,
  ) {
    // Obtenemos el helper para calcular escalas
    final responsive = ResponsiveHelper(context);
    final double scale = responsive.scale;

    return Center(
      child: Transform.scale(
        // Opcional: un pequeño ajuste extra si quieres que todo el botón crezca más
        scale: 0.7,
        child: ElevatedButton(
          onPressed: () => _handleCreateRecipe(context, viewModel),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black,
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30 * scale),
            ),
          ),
          // Pasamos el scale al contenido
          child: _buildCreateRecipeButtonContent(context, scale),
        ),
      ),
    );
  }

  Widget _buildCreateRecipeButtonContent(BuildContext context, double scale) {
    // Tamaños base
    const double baseIconSize = 28.0;
    const double baseContainerSize = 50.0;
    const double baseFontSize = 16.0;
    const double basePaddingH = 24.0;
    const double basePaddingV = 12.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Círculo del icono (Responsive)
          Container(
            width: baseContainerSize * scale,
            height: baseContainerSize * scale,
            decoration: BoxDecoration(
              color: const Color(0xFF25CCAD),
              borderRadius: BorderRadius.circular(30 * scale),
            ),
            child: Icon(
              Icons.add,
              color: Colors.black,
              size: baseIconSize * scale,
            ),
          ),
          // Texto y fondo amarillo (Responsive)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: basePaddingH * scale,
              vertical: basePaddingV * scale,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30 * scale),
                bottomRight: Radius.circular(30 * scale),
              ),
            ),
            child: Text(
              'Crear nueva receta',
              style: TextStyle(
                fontSize: baseFontSize * scale,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCreateRecipe(
    BuildContext context,
    RecipeListViewModel viewModel,
  ) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) =>
          DialogoCrearReceta(dificultades: RecipeConstants.dificultadLabels),
    );

    if (result == null) return;

    final Recipe nueva = result['receta'] as Recipe;
    final String? youtube = result['youtube'] as String?;
    final List<XFile> imagenesXFile = result['imagenes'] as List<XFile>? ?? [];

    List<File>? imagenes;
    List<XFile>? imagenesWeb;

    if (imagenesXFile.isNotEmpty) {
      if (kIsWeb) {
        imagenesWeb = imagenesXFile;
      } else {
        imagenes = imagenesXFile.map((xfile) => File(xfile.path)).toList();
      }
    }

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    final exito = await viewModel.crearReceta(
      nueva,
      usuario: _currentUser,
      youtube: youtube?.isNotEmpty == true ? youtube : null,
      imagenes: imagenes,
      imagenesXFile: imagenesWeb,
    );

    if (context.mounted) {
      Navigator.pop(context);
    }

    if (context.mounted) {
      _showCreateRecipeResult(context, exito, viewModel.errorMessage);

      if (exito) {
        await context.read<HomeViewModel>().cargarHome();
        await _cargarDatos(); // ✅ Recargar datos de la biblioteca
      }
    }
  }

  void _showCreateRecipeResult(
    BuildContext context,
    bool success,
    String? errorMessage,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '✅ Receta creada exitosamente'
              : '❌ ${errorMessage ?? "Error al crear receta"}',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
