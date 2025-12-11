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
import 'package:migaz/ui/widgets/recipe/recipe_carousel.dart';

class PantallaBiblioteca extends StatefulWidget {
  final List<Recipe>? listaRecetas;

  const PantallaBiblioteca({Key? key, this.listaRecetas}) : super(key: key);

  @override
  State<PantallaBiblioteca> createState() => _PantallaBibliotecaState();
}

class _PantallaBibliotecaState extends State<PantallaBiblioteca> {
  List<Recipe>? _recetasLocales;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filtroSeleccionado = 'Todos';

  final List<Recipe> _todasLasRecetasCompletas = [];

  // Recetas filtradas usando utilidad compartida
  List<Recipe> get _recetasFiltradas {
    return RecipeUtils.filterRecipes(
      recipes: _todasLasRecetasCompletas,
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
    _loadRecipesFromArguments();
  }

  void _loadRecipesFromArguments() {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is List<Recipe>) {
      setState(() => _recetasLocales = args);
    } else if (args is List) {
      setState(() => _recetasLocales = List<Recipe>.from(args));
    } else if (widget.listaRecetas != null) {
      setState(() => _recetasLocales = widget.listaRecetas);
    }
  }

  @override
  void initState() {
    super.initState();
    _recetasLocales = widget.listaRecetas ?? [];
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
        child: const Text(
          'Tu biblioteca',
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
          onPressed: () => Navigator.pushNamed(
            context,
            AppRoutes.misrecetas,
            arguments: _recetasLocales,
          ),
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
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
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
                nombre: receta.nombre,
                categoria: receta.categoria,
                valoracion: 4.5,
                cantidadComentarios: receta.cantidadComentarios,
                onTap: () => RecipeDetailDialog.show(context, receta),
                recipe: receta,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            _buildCarouselSection(
              title: 'Mis Recetas',
              recipes: _recetasLocales ?? [],
              emptyMessage: 'No tienes recetas personales aún',
            ),
            const SizedBox(height: 24),
            _buildCarouselSection(
              title: 'Guardados',
              recipes: _todasLasRecetasCompletas,
              emptyMessage: 'No has guardado ninguna receta',
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
        _buildCarouselTitle(title),
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

  Widget _buildCarouselTitle(String title) {
    return Center(
      child: Container(
        width: 600,
        decoration: BoxDecoration(
          color: const Color(0xFFEA7317).withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
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
