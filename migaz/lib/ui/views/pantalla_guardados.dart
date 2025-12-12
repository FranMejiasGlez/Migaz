// lib/ui/views/pantalla_guardados.dart
import 'package:migaz/core/config/routes.dart';
import 'package:migaz/core/constants/recipe_constants.dart';
import 'package:migaz/core/utils/recipe_utils.dart';
import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/ui/widgets/recipe/recipe_detail_dialog.dart';
import 'package:migaz/ui/widgets/recipe/recipe_search_section.dart';
import 'package:migaz/ui/widgets/recipe/user_avatar.dart';
import 'package:migaz/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:migaz/ui/widgets/recipe/recipe_card.dart';
import 'package:migaz/viewmodels/home_viewmodel.dart';
import 'package:provider/provider.dart';

class PantallaGuardados extends StatefulWidget {
  const PantallaGuardados({Key? key}) : super(key: key);

  @override
  State<PantallaGuardados> createState() => _PantallaGuardadosState();
}

class _PantallaGuardadosState extends State<PantallaGuardados> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filtroSeleccionado = 'Todos';
  bool _isLoading = true;

  // ✅ Usuario actual
  final String _currentUser = 'usuario_demo'; 

  @override
  void initState() {
    super.initState();
    _cargarGuardadas();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ✅ NUEVO: Cargar recetas guardadas
  Future<void> _cargarGuardadas() async {
    setState(() => _isLoading = true);

    try {
      final homeViewModel = context.read<HomeViewModel>();
      await homeViewModel.cargarHome();
      await homeViewModel.cargarGuardadas(_currentUser);

      setState(() => _isLoading = false);

      print(
        '✅ Recetas guardadas cargadas:  ${homeViewModel.recetasGuardadas.length}',
      );
    } catch (e) {
      print('❌ Error al cargar guardadas: $e');
      setState(() => _isLoading = false);
    }
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
              Expanded(child: _buildContent()),
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
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.pop(context),
    );
  }

  Widget _buildTitle() {
    return Expanded(
      child: Consumer<HomeViewModel>(
        builder: (context, homeViewModel, child) {
          final count = homeViewModel.recetasGuardadas.length;
          return Column(
            children: [
              const Text(
                'Recetas Guardadas',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (!_isLoading)
                Text(
                  '$count ${count == 1 ? "receta" : "recetas"}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
            ],
          );
        },
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

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Consumer<HomeViewModel>(
      builder: (context, homeViewModel, child) {
        final recetasGuardadas = homeViewModel.recetasGuardadas;

        // Aplicar filtros si hay
        final recetasFiltradas = _hasActiveFilters
            ? RecipeUtils.filterRecipes(
                recipes: recetasGuardadas,
                searchQuery: _searchQuery,
                selectedFilter: _filtroSeleccionado,
              )
            : recetasGuardadas;

        if (recetasFiltradas.isEmpty) {
          return _buildEmptyState(
            icon: _hasActiveFilters ? Icons.search_off : Icons.bookmark_outline,
            message: _hasActiveFilters
                ? 'No se encontraron recetas'
                : 'No has guardado ninguna receta aún',
          );
        }

        return RefreshIndicator(
          onRefresh: _cargarGuardadas,
          child: _buildGridView(recetasFiltradas),
        );
      },
    );
  }

  Widget _buildGridView(List<Recipe> recetas) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final cardWidth = (screenWidth - 100) / 4;
        final cardHeight = cardWidth * 1.2;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: RecipeConstants.gridCrossAxisCount,
              crossAxisSpacing: RecipeConstants.gridCrossAxisSpacing,
              mainAxisSpacing: RecipeConstants.gridMainAxisSpacing,
              childAspectRatio: cardWidth / cardHeight,
            ),
            itemCount: recetas.length,
            itemBuilder: (context, index) {
              final receta = recetas[index];
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

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          if (!_hasActiveFilters) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.home),
              icon: const Icon(Icons.explore),
              label: const Text('Explorar recetas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryYellow,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool get _hasActiveFilters {
    return RecipeUtils.hasActiveFilters(
      searchQuery: _searchQuery,
      selectedFilter: _filtroSeleccionado,
    );
  }
}
