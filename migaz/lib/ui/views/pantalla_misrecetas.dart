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
import 'package:migaz/viewmodels/home_viewmodel.dart';
import 'package:provider/provider.dart';

class PantallaMisRecetas extends StatefulWidget {
  const PantallaMisRecetas({Key? key}) : super(key: key);

  @override
  State<PantallaMisRecetas> createState() => _PantallaMisRecetasState();
}

class _PantallaMisRecetasState extends State<PantallaMisRecetas> {
  final TextEditingController _searchController = TextEditingController();
  final RecetaRepository _recetaRepository = RecetaRepository();

  String _searchQuery = '';
  String _filtroSeleccionado = 'Todos';
  List<Recipe> _misRecetas = [];
  bool _isLoading = true;
  String? _errorMessage;

  // ✅ Usuario actual (temporal, luego vendrá de autenticación)
  final String _currentUser = 'usuario_demo';

  @override
  void initState() {
    super.initState();
    _cargarMisRecetas();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // En el método _cargarMisRecetas():
  Future<void> _cargarMisRecetas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('📥 Cargando recetas de: $_currentUser');
      final recetas = await _recetaRepository.obtenerPorUsuario(_currentUser);

      setState(() {
        _misRecetas = recetas;
        _isLoading = false;
      });

      // ✅ NUEVO: Actualizar también el HomeViewModel
      if (mounted) {
        final homeViewModel = context.read<HomeViewModel>();
        await homeViewModel.cargarHome();
      }

      print('✅ Recetas cargadas: ${recetas.length}');
    } catch (e) {
      print('❌ Error al cargar mis recetas: $e');
      setState(() {
        _errorMessage = 'Error al cargar tus recetas';
        _isLoading = false;
      });
    }
  }

  // Recetas filtradas
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
    return SizedBox(
      child: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pushNamed(context, AppRoutes.home),
      ),
    );
  }

  Widget _buildTitle() {
    return Expanded(
      child: Column(
        children: [
          const Text(
            'Mis Recetas',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          if (!_isLoading)
            Text(
              '${_misRecetas.length} ${_misRecetas.length == 1 ? "receta" : "recetas"}',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
        ],
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

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return _buildGridView();
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
              onPressed: _cargarMisRecetas,
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

  /// ✅ NUEVO: Grid de recetas del usuario
  Widget _buildGridView() {
    final recetasAMostrar = _hasActiveFilters ? _recetasFiltradas : _misRecetas;

    if (recetasAMostrar.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _cargarMisRecetas,
      child: LayoutBuilder(
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
              itemCount: recetasAMostrar.length,
              itemBuilder: (context, index) {
                final receta = recetasAMostrar[index];
                return RecipeCard(
                  recipe: receta,
                  onTap: () => RecipeDetailDialog.show(context, receta),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final bool hasFilters = _hasActiveFilters;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilters ? Icons.search_off : Icons.restaurant_menu,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters
                ? 'No se encontraron recetas'
                : 'Aún no has creado ninguna receta',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          if (!hasFilters) ...[
            const SizedBox(height: 8),
            Text(
              '¡Crea tu primera receta!',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
  }
}
