import 'dart:io';
import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/data/repositories/receta_repository.dart';
import 'package:migaz/viewmodels/base_viewmodel.dart';

class RecipeListViewModel extends BaseViewModel {
  final RecetaRepository _recetaRepository;

  List<Recipe> _recipes = [];
  String _searchQuery = '';
  String _selectedFilter = 'Todos';

  RecipeListViewModel({RecetaRepository? recetaRepository})
    : _recetaRepository = recetaRepository ?? RecetaRepository();

  // Categorías disponibles
  final List<String> categories = [
    'Todos',
    'Española',
    'Italiana',
    'Japonesa',
    'Mexicana',
  ];

  // ✅ ACTUALIZAR: Dificultades como números
  final List<Map<String, dynamic>> dificultadOptions = [
    {'value': 1, 'label': 'Muy Fácil', 'emoji': '⭐'},
    {'value': 2, 'label': 'Fácil', 'emoji': '⭐⭐'},
    {'value': 3, 'label': 'Medio', 'emoji': '⭐⭐⭐'},
    {'value': 4, 'label': 'Difícil', 'emoji': '⭐⭐⭐⭐'},
    {'value': 5, 'label': 'Muy Difícil', 'emoji': '⭐⭐⭐⭐⭐'},
  ];

  // ✅ AÑADIR: Helper para obtener labels
  List<String> get dificultadLabels =>
      dificultadOptions.map((d) => d['label'] as String).toList();

  // Getters
  List<Recipe> get recipes => _recipes;
  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedFilter;

  // ...  resto del código sin cambios

  List<Recipe> get filteredRecipes {
    return _recipes.where((recipe) {
      final matchesSearch = recipe.nombre.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesFilter =
          _selectedFilter == 'Todos' || recipe.categoria == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  Future<void> loadRecipes() async {
    await runAsync(() async {
      _recipes = await _recetaRepository.obtenerTodas();
    }, errorPrefix: 'Error al cargar recetas');
  }

  Future<bool> crearReceta(Recipe receta, {List<File>? imagenes}) async {
    final result = await runAsync(() async {
      final nuevaReceta = await _recetaRepository.crear(
        receta,
        imagenes: imagenes,
      );
      _recipes.add(nuevaReceta);
      return true;
    }, errorPrefix: 'Error al crear receta');

    return result ?? false;
  }

  Future<bool> actualizarReceta(
    String id,
    Recipe receta, {
    List<File>? imagenes,
  }) async {
    final result = await runAsync(() async {
      final recetaActualizada = await _recetaRepository.actualizar(
        id,
        receta,
        imagenes: imagenes,
      );

      final index = _recipes.indexWhere((r) => r.id == id);
      if (index != -1) {
        _recipes[index] = recetaActualizada;
      }
      return true;
    }, errorPrefix: 'Error al actualizar receta');

    return result ?? false;
  }

  Future<bool> eliminarReceta(String id) async {
    final result = await runAsync(() async {
      await _recetaRepository.eliminar(id);
      _recipes.removeWhere((r) => r.id == id);
      return true;
    }, errorPrefix: 'Error al eliminar receta');

    return result ?? false;
  }

  Future<bool> valorarReceta(String id, double valoracion) async {
    final result = await runAsync(() async {
      final recetaValorada = await _recetaRepository.valorar(id, valoracion);

      final index = _recipes.indexWhere((r) => r.id == id);
      if (index != -1) {
        _recipes[index] = recetaValorada;
      }
      return true;
    }, errorPrefix: 'Error al valorar receta');

    return result ?? false;
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void updateFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}
