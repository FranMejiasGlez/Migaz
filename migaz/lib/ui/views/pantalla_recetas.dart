import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:migaz/core/config/routes.dart';
import 'package:migaz/core/constants/recipe_constants.dart';
import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/ui/widgets/recipe/recipe_detail_dialog.dart';
import 'package:migaz/ui/widgets/recipe/recipe_grid_view.dart';
import 'package:migaz/ui/widgets/recipe/recipe_search_section.dart';
import 'package:migaz/ui/widgets/recipe/user_avatar.dart';
import 'package:migaz/ui/widgets/recipe/ventana_crear_receta.dart';
import 'package:flutter/material.dart';
import 'package:migaz/core/theme/app_theme.dart';
import 'package:migaz/core/utils/recipe_utils.dart';
import 'package:migaz/viewmodels/recipe_list_viewmodel.dart';
import 'package:migaz/viewmodels/home_viewmodel.dart';
import 'package:provider/provider.dart';
import '../widgets/recipe/recipe_carousel.dart';

class PantallaRecetas extends StatelessWidget {
  const PantallaRecetas({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => RecipeListViewModel())],
      child: const _PantallaRecetasView(),
    );
  }
}

class _PantallaRecetasView extends StatefulWidget {
  const _PantallaRecetasView({Key? key}) : super(key: key);

  @override
  State<_PantallaRecetasView> createState() => _PantallaRecetasViewState();
}

class _PantallaRecetasViewState extends State<_PantallaRecetasView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final homeViewModel = context.read<HomeViewModel>();
      await homeViewModel.cargarHome();
      await homeViewModel.cargarGuardadas('usuario_demo');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ✅ ACTUALIZADO: Filtrar sobre HomeViewModel.todasLasRecetas
  List<Recipe> _getFilteredRecipes(HomeViewModel homeViewModel) {
    return RecipeUtils.filterRecipes(
      recipes: homeViewModel.todasLasRecetas,
      searchQuery: _searchQuery,
      selectedFilter: _selectedFilter,
    );
  }

  bool _hasActiveFilters() {
    return RecipeUtils.hasActiveFilters(
      searchQuery: _searchQuery,
      selectedFilter: _selectedFilter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeListViewModel>(
      builder: (context, recipeListViewModel, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(gradient: AppTheme.appGradient),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
                  _buildSearchSection(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _hasActiveFilters()
                        ? _buildSearchResults()
                        : _buildHomeContent(),
                  ),
                  _buildCreateRecipeButton(context, recipeListViewModel),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    // Usamos LayoutBuilder o simplemente confiamos en el Expanded
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 16.0,
      ), // Reduje padding horizontal a 16 para móviles
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Mejor distribución
        children: [
          _buildLibraryButton(context),
          const SizedBox(width: 8), // Espaciado flexible
          // Expanded obliga al widget a ocupar solo el espacio sobrante
          Expanded(child: _buildUserNameDisplay()),
          const SizedBox(width: 8),
          UserAvatar(
            imageUrl: RecipeConstants.defaultAvatarUrl,
            onTap: () => Navigator.pushNamed(context, AppRoutes.perfilUser),
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryButton(BuildContext context) {
    // Agregamos constraints para que el botón no sea excesivamente ancho
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 120), // Límite máximo
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.biblioteca);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF25CCAD),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: RecipeConstants.buttonElevation,
        ),
        child: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Biblioteca',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildUserNameDisplay() {
    const String currentUser = 'usuario_demo';
    // ELIMINADO: width: 300
    // ELIMINADO: SizedBox wrapper con ancho fijo
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      alignment: Alignment.center,
      child: const FittedBox(
        // Escala el texto si no cabe
        fit: BoxFit.scaleDown,
        child: Text(
          currentUser,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return RecipeSearchSection(
      searchController: _searchController,
      selectedFilter: _selectedFilter,
      onSearchChanged: (value) => setState(() => _searchQuery = value),
      onClearSearch: () => setState(() {
        _searchController.clear();
        _searchQuery = '';
      }),
      onFilterChanged: (newValue) {
        if (newValue != null) {
          setState(() => _selectedFilter = newValue);
        }
      },
      showClearButton: _searchQuery.isNotEmpty,
    );
  }

  // ✅ ACTUALIZADO: Usar Consumer<HomeViewModel>
  Widget _buildSearchResults() {
    return Consumer<HomeViewModel>(
      builder: (context, homeViewModel, child) {
        if (homeViewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredRecipes = _getFilteredRecipes(homeViewModel);

        if (filteredRecipes.isEmpty) {
          return _buildEmptyState(
            icon: Icons.search_off,
            message: 'No se encontraron recetas',
          );
        }

        return RecipeGridView(recipes: filteredRecipes);
      },
    );
  }

  Widget _buildHomeContent() {
    return Consumer<HomeViewModel>(
      builder: (context, homeViewModel, child) {
        if (homeViewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (homeViewModel.hasError) {
          return _buildErrorState(homeViewModel);
        }

        return _buildRecipeSections(homeViewModel);
      },
    );
  }

  Widget _buildErrorState(HomeViewModel homeViewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              homeViewModel.errorMessage ?? 'Error desconocido',
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => homeViewModel.cargarHome(),
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

  Widget _buildRecipeSections(HomeViewModel homeViewModel) {
    return RefreshIndicator(
      onRefresh: homeViewModel.refrescarHome,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              _buildRecipeSection(
                title: 'Más Valoradas',
                recipes: homeViewModel.recetasMasValoradas,
                emptyMessage: 'No hay imagen',
              ),
              const SizedBox(height: 24),
              _buildRecipeSection(
                title: 'Mas Nuevas',
                recipes: homeViewModel.recetasMasNuevas,
                emptyMessage: 'No hay imagen',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeSection({
    required String title,
    required List<Recipe> recipes,
    required String emptyMessage,
  }) {
    return Column(
      children: [
        _buildSectionTitle(title),
        const SizedBox(height: 8),
        RecipeCarousel(
          title: '',
          recipes: recipes,
          emptyMessage: emptyMessage,
          onRecipeTap: (index) {
            RecipeDetailDialog.show(context, recipes[index]);
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Center(
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 243, 243, 243).withOpacity(0.5),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

  Widget _buildCreateRecipeButton(
    BuildContext context,
    RecipeListViewModel viewModel,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton(
          onPressed: () => _handleCreateRecipe(context, viewModel),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black,
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: _buildCreateRecipeButtonContent(),
        ),
      ),
    );
  }

  Widget _buildCreateRecipeButtonContent() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF25CCAD),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.add, color: Colors.black, size: 28),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFFFC107),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: const Text(
              'Crear nueva receta',
              style: TextStyle(
                fontSize: 16,
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
      usuario: 'usuario_demo',
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
