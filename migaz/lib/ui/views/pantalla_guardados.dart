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

class PantallaGuardados extends StatefulWidget {
  const PantallaGuardados({Key? key}) : super(key: key);

  @override
  State<PantallaGuardados> createState() => _PantallaGuardadosState();
}

class _PantallaGuardadosState extends State<PantallaGuardados> {
  bool _dialogoAbiertoGuardados = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filtroSeleccionado = 'Todos';

  final List<Recipe> _recetasGuardadas = [];

  // Recetas filtradas usando utilidad compartida
  List<Recipe> get _recetasFiltradas {
    return RecipeUtils.filterRecipes(
      recipes: _recetasGuardadas,
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
      final receta = _recetasGuardadas.firstWhere(
        (r) => r.nombre == recipeName,
      );
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
        'Recetas Guardadas',
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
    if (_recetasGuardadas.isEmpty) {
      return _buildEmptyState(
        icon: Icons.bookmark_outline,
        message: 'No hay recetas guardadas',
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
            itemCount: _recetasGuardadas.length,
            itemBuilder: (context, index) {
              final receta = _recetasGuardadas[index];
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
          ),
        ],
      ),
    );
  }
}
