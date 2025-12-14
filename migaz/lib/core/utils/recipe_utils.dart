// lib/core/utils/recipe_utils.dart
import 'package:migaz/data/models/recipe.dart';

class RecipeUtils {
  /// Filtra recetas por nombre/usuario Y por categoría
  static List<Recipe> filterRecipes({
    required List<Recipe> recipes,
    required String searchQuery,
    required String selectedFilter,
  }) {
    return recipes.where((recipe) {
      // Filtro por categoría
      final matchesCategory =
          selectedFilter == 'Todos' ||
          recipe.categoria.toLowerCase() == selectedFilter.toLowerCase();

      // Si no hay query de búsqueda, solo aplicar filtro de categoría
      if (searchQuery.isEmpty) {
        return matchesCategory;
      }

      // Filtro por búsqueda (nombre, usuario o categoría)
      final query = searchQuery.toLowerCase();
      final matchesName = recipe.nombre.toLowerCase().contains(query);
      final matchesUser = recipe.user?.toLowerCase().contains(query) ?? false;
      final matchesCategoria = recipe.categoria.toLowerCase().contains(query);

      // Debe cumplir AMBOS: categoría seleccionada Y búsqueda
      return matchesCategory &&
          (matchesName || matchesUser || matchesCategoria);
    }).toList();
  }

  static bool hasActiveFilters({
    required String searchQuery,
    required String selectedFilter,
  }) {
    return searchQuery.isNotEmpty || selectedFilter != 'Todos';
  }
}
