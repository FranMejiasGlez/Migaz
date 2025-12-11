import 'package:migaz/core/config/routes.dart';
import 'package:migaz/core/constants/recipe_constants.dart';
import 'package:migaz/core/utils/recipe_utils.dart';
import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/ui/widgets/recipe/recipe_carousel.dart';
import 'package:migaz/ui/widgets/recipe/recipe_detail_dialog.dart';
import 'package:migaz/ui/widgets/recipe/recipe_search_section.dart';
import 'package:migaz/ui/widgets/recipe/user_avatar.dart';
import 'package:migaz/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:migaz/ui/widgets/recipe/recipe_card.dart';
import 'package:migaz/viewmodels/home_viewmodel.dart';
import 'package:provider/provider.dart';

class PantallaMisRecetas extends StatefulWidget {
  const PantallaMisRecetas({Key? key}) : super(key: key);

  @override
  State<PantallaMisRecetas> createState() => _PantallaMisRecetasState();
}

class _PantallaMisRecetasState extends State<PantallaMisRecetas> {
  bool _dialogoAbiertoGuardados = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filtroSeleccionado = 'Todos';

  final List<Recipe> _misRecetas = [];

  // Recetas filtradas usando utilidad compartida
  List<Recipe> get _recetasFiltradas {
    return RecipeUtils.filterRecipes(
      recipes: _misRecetas,
      searchQuery: _searchQuery,
      selectedFilter: _filtroSeleccionado,
    );
  }

  // Verificar si hay filtros activos
  bool get _hasActiveFilters {
    return RecipeUtils.hasActiveFilters(
      searchQuery: _searchQuery,
      selectedFilter: _filtroSeleccionado,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;

    // Si viene un nombre de receta para abrir directamente
    if (args is String && !_dialogoAbiertoGuardados) {
      _openRecipeByName(args);
    }
  }

  void _openRecipeByName(String recipeName) {
    try {
      final receta = _misRecetas.firstWhere((r) => r.nombre == recipeName);
      _dialogoAbiertoGuardados = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        RecipeDetailDialog.show(context, receta);
      });
    } catch (e) {
      // Si no se encuentra, simplemente mostrar la lista
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.appGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchSection(),
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
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _buildBackButton(),
          const SizedBox(width: 12),
          _buildTitle(),
          const SizedBox(width: 12),
          UserAvatar(
            imageUrl: RecipeConstants.defaultAvatarUrl,
            onTap: () => Navigator.pushNamed(context, AppRoutes.perfilUser),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 140),
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFEC601),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              RecipeConstants.buttonBorderRadius,
            ),
          ),
          elevation: RecipeConstants.buttonElevation,
        ),
        child: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Icon(Icons.arrow_back),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Expanded(
      child: Text(
        'Mis Recetas',
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSearchSection() {
    return RecipeSearchSection(
      searchController: _searchController,
      selectedFilter: _filtroSeleccionado,
      categories: RecipeConstants.categories,
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

  Widget _buildSearchResults() {
    if (_recetasFiltradas.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off,
        message: 'No se encontraron recetas',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final cardWidth = (screenWidth - 100) / 4;
        final cardHeight = cardWidth * 1.2;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: RecipeConstants.gridCrossAxisCount,
              crossAxisSpacing: RecipeConstants.gridCrossAxisSpacing,
              mainAxisSpacing: RecipeConstants.gridMainAxisSpacing,
              childAspectRatio: cardWidth / cardHeight,
            ),
            itemCount: _recetasFiltradas.length,
            itemBuilder: (context, index) {
              final receta = _recetasFiltradas[index];
              return RecipeCard(
                nombre: receta.nombre,
                categoria: receta.categoria,
                valoracion: 4.5,
                onTap: () => RecipeDetailDialog.show(context, receta),
              );
            },
          ),
        );
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
                title: '📚 Todas las Recetas',
                recipes: homeViewModel.todasLasRecetas,
                emptyMessage: 'No hay recetas en la base de datos',
              ),
              const SizedBox(height: 24),
              _buildRecipeSection(
                title: '⭐ Más Valoradas',
                recipes: homeViewModel.recetasMasValoradas,
                emptyMessage: 'No hay recetas valoradas aún',
              ),
              const SizedBox(height: 24),
              _buildRecipeSection(
                title: '🆕 Nuevas',
                recipes: homeViewModel.recetasMasNuevas,
                emptyMessage: 'No hay recetas nuevas aún',
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
}
