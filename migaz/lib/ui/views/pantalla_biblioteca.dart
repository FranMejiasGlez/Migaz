import 'package:migaz/core/config/routes.dart';
import 'package:migaz/core/constants/recipe_constants.dart';
import 'package:migaz/core/utils/recipe_utils.dart';
import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/data/repositories/receta_repository.dart';
import 'package:migaz/ui/widgets/recipe/recipe_detail_dialog.dart';
import 'package:migaz/ui/widgets/recipe/recipe_search_section.dart';
import 'package:migaz/ui/widgets/recipe/user_avatar.dart';
import 'package:migaz/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:migaz/ui/widgets/recipe/recipe_card.dart';
import 'package:migaz/ui/widgets/recipe/recipe_carousel.dart';
import 'package:migaz/viewmodels/home_viewmodel.dart';
import 'package:provider/provider.dart';

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

  // ✅ Usuario actual (temporal, luego vendrá de autenticación)
  final String _currentUser = 'usuario_demo';

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

  // En el método _cargarDatos(), después de cargar las recetas:
  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('📥 Cargando recetas de:  $_currentUser');

      final misRecetas = await _recetaRepository.obtenerPorUsuario(
        _currentUser,
      );

      setState(() {
        _misRecetas = misRecetas;
        _recetasGuardadas = [];
        _isLoading = false;
      });

      // ✅ NUEVO: Actualizar también el HomeViewModel
      if (mounted) {
        final homeViewModel = context.read<HomeViewModel>();
        await homeViewModel.cargarHome();
      }

      print('✅ Mis recetas cargadas:  ${misRecetas.length}');
    } catch (e) {
      print('❌ Error al cargar datos de biblioteca: $e');
      setState(() {
        _errorMessage = 'Error al cargar tu biblioteca';
        _isLoading = false;
      });
    }
  }

  // Todas las recetas para filtrar
  List<Recipe> get _todasLasRecetas {
    return [..._misRecetas, ..._recetasGuardadas];
  }

  // Recetas filtradas
  List<Recipe> get _recetasFiltradas {
    return RecipeUtils.filterRecipes(
      recipes: _todasLasRecetas,
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.appGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchSection(),
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
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBackButton(),
          const SizedBox(width: 10),
          _buildTitle(),
          const SizedBox(width: 10),
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
    return SizedBox(
      width: 300,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEA7317).withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            const Text(
              'Tu biblioteca',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (!_isLoading)
              Text(
                '${_todasLasRecetas.length} ${_todasLasRecetas.length == 1 ? "receta" : "recetas"}',
                style: TextStyle(fontSize: 12, color: Colors.grey[800]),
              ),
          ],
        ),
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

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildNavigationButton(
          icon: Icons.bookmark,
          label: 'Guardados',

          onPressed: () => Navigator.pushNamed(context, AppRoutes.guardados),
        ),
        _buildNavigationButton(
          icon: Icons.edit,
          label: 'Mis Recetas',

          onPressed: () => Navigator.pushNamed(context, AppRoutes.misrecetas),
        ),
      ],
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final cardWidth = (screenWidth - 36) / 2;
        final cardHeight = cardWidth * 1.2;

        return Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: RecipeConstants.gridCrossAxisSpacing,
              mainAxisSpacing: RecipeConstants.gridMainAxisSpacing,
              childAspectRatio: cardWidth / cardHeight,
            ),
            itemCount: _recetasFiltradas.length,
            itemBuilder: (context, index) {
              final receta = _recetasFiltradas[index];
              return RecipeCard(
                recipe: receta,
                onTap: () => RecipeDetailDialog.show(context, receta),
              );
            },
          ),
        );
      },
    );
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
              // ✅ ACTUALIZADO: Mis Recetas del usuario
              _buildCarouselSection(
                title: 'Mis Recetas',
                recipes: _misRecetas,
                emptyMessage: 'No tienes recetas personales aún',
              ),
              const SizedBox(height: 24),
              // ✅ Guardados (por implementar)
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
          onRecipeTap: (index) {
            if (recipes.isNotEmpty) {
              RecipeDetailDialog.show(context, recipes[index]);
            }
          },
        ),
      ],
    );
  }

  Widget _buildCarouselTitle(String title, int count) {
    return Center(
      child: Container(
        width: 600,
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
}
