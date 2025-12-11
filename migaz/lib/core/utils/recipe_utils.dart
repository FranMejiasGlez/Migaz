import 'package:migaz/data/models/recipe.dart';

class RecipeUtils {
  /// Filtrar recetas por búsqueda y categoría
  static List<Recipe> filterRecipes({
    required List<Recipe> recipes,
    required String searchQuery,
    required String selectedFilter,
  }) {
    return recipes.where((recipe) {
      final matchesSearch = recipe.nombre.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      final matchesFilter =
          selectedFilter == 'Todos' || recipe.categoria == selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  /// Verificar si hay filtros activos
  static bool hasActiveFilters({
    required String searchQuery,
    required String selectedFilter,
  }) {
    return searchQuery.isNotEmpty || selectedFilter != 'Todos';
  }
}
