import 'package:migaz/models/recipe.dart';
import 'package:migaz/viewmodels/base_viewmodel.dart';

/// ViewModel para la lista de recetas
/// Maneja el estado y lógica de negocio de la pantalla de recetas
class RecipeListViewModel extends BaseViewModel {
  List<Recipe> _recipes = [];
  String _searchQuery = '';
  String _selectedFilter = 'Todos';

  // Categorías disponibles
  final List<String> categories = [
    'Todos',
    'Española',
    'Italiana',
    'Japonesa',
    'Mexicana',
  ];

  // Niveles de dificultad
  final List<String> difficultyLevels = [
    'Todos los niveles',
    'fácil',
    'Medio',
    'Difícil',
  ];

  // Datos de ejemplo (en producción vendría de un servicio/repositorio)
  final List<Map<String, dynamic>> _allRecipesData = [
    {'nombre': 'Paella Valenciana', 'categoria': 'Española', 'valoracion': 4.8},
    {'nombre': 'Tortilla de Patatas', 'categoria': 'Española', 'valoracion': 4.5},
    {'nombre': 'Pizza Margarita', 'categoria': 'Italiana', 'valoracion': 4.7},
    {'nombre': 'Sushi Roll', 'categoria': 'Japonesa', 'valoracion': 4.9},
    {'nombre': 'Tacos al Pastor', 'categoria': 'Mexicana', 'valoracion': 4.6},
    {'nombre': 'Lasaña Boloñesa', 'categoria': 'Italiana', 'valoracion': 4.4},
    {'nombre': 'Ramen', 'categoria': 'Japonesa', 'valoracion': 4.8},
    {'nombre': 'Gazpacho', 'categoria': 'Española', 'valoracion': 4.3},
  ];

  // Getters
  List<Recipe> get recipes => _recipes;
  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedFilter;

  /// Recetas filtradas según búsqueda y filtro
  List<Map<String, dynamic>> get filteredRecipes {
    return _allRecipesData.where((recipe) {
      final matchesSearch = recipe['nombre']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final matchesFilter =
          _selectedFilter == 'Todos' || recipe['categoria'] == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  /// Actualiza la consulta de búsqueda
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Actualiza el filtro seleccionado
  void updateFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  /// Limpia la búsqueda
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  /// Agrega una nueva receta
  void addRecipe(Recipe recipe) {
    _recipes.add(recipe);
    _allRecipesData.add(recipe.toJson());
    notifyListeners();
  }

  /// Carga recetas desde un servicio (simulado)
  Future<void> loadRecipes() async {
    await runAsync(() async {
      // Simular carga de datos
      await Future.delayed(const Duration(milliseconds: 500));
      // En producción, aquí se llamaría a un servicio/repositorio
    }, errorPrefix: 'Error al cargar recetas');
  }
}
