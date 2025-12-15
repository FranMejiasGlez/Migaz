// lib/ui/views/pantalla_guardados.dart
import 'package:migaz/core/config/api_config.dart';
import 'package:migaz/core/config/routes.dart';
import 'package:migaz/core/constants/recipe_constants.dart';
import 'package:migaz/core/utils/recipe_utils.dart';
import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/ui/widgets/recipe/recipe_search_section.dart';
import 'package:migaz/ui/widgets/recipe/user_avatar.dart';
import 'package:migaz/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:migaz/viewmodels/home_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:migaz/ui/widgets/recipe/recipe_grid_view.dart';

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
  final String _currentUser = ApiConfig.currentUser; //!!

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

      /*print(
        '✅ Recetas guardadas cargadas:  ${homeViewModel.recetasGuardadas.length}',
      );*/
    } catch (e) {
      //print('❌ Error al cargar guardadas: $e');
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
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.pop(context),
    );
  }

  Widget _buildTitle() {
    // 1. Usar Consumer para escuchar cambios en HomeViewModel
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        // 2. Obtener el conteo y el estado de carga del ViewModel
        final int count =
            viewModel.recetasGuardadas.length; // ✅ Conteo de recetas guardadas
        final bool isLoading = viewModel
            .isLoading; // Asumimos que isLoading viene del BaseViewModel/HomeViewModel

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
                  // ✅ Título actualizado para reflejar la pantalla de guardados
                  'Recetas Guardadas',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              // 3. Mostrar el conteo solo si no está cargando
              if (!isLoading)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    // ✅ Usamos la variable 'count' obtenida del ViewModel
                    '$count ${count == 1 ? "receta" : "recetas"}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                  ),
                ),

              // Opcional: Mostrar un indicador de carga si los datos se están cargando
              if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
            ],
          ),
        );
      },
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
    return RecipeGridView(recipes: recetas, onRefresh: _cargarGuardadas);
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
