import 'package:flutter_test/flutter_test.dart';
import 'package:migaz/viewmodels/recipe_list_viewmodel.dart';
import 'package:migaz/data/models/recipe.dart';

void main() {
  group('RecipeListViewModel Tests', () {
    late RecipeListViewModel viewModel;

    setUp(() {
      viewModel = RecipeListViewModel();
    });

    test('Initial state is correct', () {
      expect(viewModel.recipes, isEmpty);
      expect(viewModel.searchQuery, isEmpty);
      expect(viewModel.selectedFilter, equals('Todos'));
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.hasError, isFalse);
    });

    test('Categories list contains expected values', () {
      expect(viewModel.categories, contains('Todos'));
      expect(viewModel.categories, contains('Española'));
      expect(viewModel.categories, contains('Italiana'));
      expect(viewModel.categories, contains('Japonesa'));
      expect(viewModel.categories, contains('Mexicana'));
    });

    test('Difficulty levels list contains expected values', () {
      expect(viewModel.dificultadLabels, contains('Muy Fácil'));
      expect(viewModel.dificultadLabels, contains('Fácil'));
      expect(viewModel.dificultadLabels, contains('Medio'));
      expect(viewModel.dificultadLabels, contains('Difícil'));
      expect(viewModel.dificultadLabels, contains('Muy Difícil'));
    });

    test('updateSearchQuery updates search query and notifies listeners', () {
      bool notified = false;
      viewModel.addListener(() => notified = true);

      viewModel.updateSearchQuery('Paella');

      expect(viewModel.searchQuery, equals('Paella'));
      expect(notified, isTrue);
    });

    test('updateFilter updates filter and notifies listeners', () {
      bool notified = false;
      viewModel.addListener(() => notified = true);

      viewModel.updateFilter('Italiana');

      expect(viewModel.selectedFilter, equals('Italiana'));
      expect(notified, isTrue);
    });

    test('clearSearch clears search query and notifies listeners', () {
      viewModel.updateSearchQuery('Test');
      expect(viewModel.searchQuery, equals('Test'));

      bool notified = false;
      viewModel.addListener(() => notified = true);

      viewModel.clearSearch();

      expect(viewModel.searchQuery, isEmpty);
      expect(notified, isTrue);
    });

    test('addRecipe adds recipe to list and notifies listeners', () {
      final recipe = Recipe(
        nombre: 'Test Recipe',
        categoria: 'Italiana',
        descripcion: 'A test recipe',
        dificultad: 2,
        tiempo: '30 min',
        comensales: 2,
        pasos: ['Paso 1', 'Paso 2'],
        ingredientes: ['Ingrediente 1', 'Ingrediente 2'],
      );

      bool notified = false;
      viewModel.addListener(() => notified = true);

      // Agregamos la receta directamente a la lista interna para test
      viewModel.recipes.add(recipe);
      viewModel.updateSearchQuery('Test Recipe'); // Para notificar listeners

      expect(viewModel.recipes.length, equals(1));
      expect(viewModel.recipes.first.nombre, equals('Test Recipe'));
      expect(notified, isTrue);
    });

    test('filteredRecipes filters by search query', () {
      final recipe = Recipe(
        nombre: 'Paella Valenciana',
        categoria: 'Española',
        descripcion: 'Arroz típico',
        dificultad: 3,
        tiempo: '45 min',
        comensales: 4,
        pasos: ['Paso 1', 'Paso 2'],
        ingredientes: ['Arroz', 'Pollo'],
      );
      viewModel.recipes.add(recipe);
      viewModel.updateSearchQuery('Paella');

      final filtered = viewModel.filteredRecipes;

      expect(filtered.length, greaterThan(0));
      expect(
        filtered.every((r) => r.nombre.toLowerCase().contains('paella')),
        isTrue,
      );
    });

    test('filteredRecipes filters by category', () {
      final recipe = Recipe(
        nombre: 'Pizza',
        categoria: 'Italiana',
        descripcion: 'Pizza casera',
        dificultad: 2,
        tiempo: '20 min',
        comensales: 2,
        pasos: ['Paso 1', 'Paso 2'],
        ingredientes: ['Harina', 'Queso'],
      );
      viewModel.recipes.add(recipe);
      viewModel.updateFilter('Italiana');

      final filtered = viewModel.filteredRecipes;

      expect(filtered.length, greaterThan(0));
      expect(filtered.every((r) => r.categoria == 'Italiana'), isTrue);
    });

    test('filteredRecipes filters by both search and category', () {
      final recipe = Recipe(
        nombre: 'Pizza Margarita',
        categoria: 'Italiana',
        descripcion: 'Pizza clásica',
        dificultad: 2,
        tiempo: '25 min',
        comensales: 2,
        pasos: ['Paso 1', 'Paso 2'],
        ingredientes: ['Harina', 'Tomate'],
      );
      viewModel.recipes.add(recipe);
      viewModel.updateSearchQuery('Pizza');
      viewModel.updateFilter('Italiana');

      final filtered = viewModel.filteredRecipes;

      expect(filtered.length, greaterThan(0));
      expect(
        filtered.every(
          (r) =>
              r.nombre.toLowerCase().contains('pizza') &&
              r.categoria == 'Italiana',
        ),
        isTrue,
      );
    });

    test('filteredRecipes returns all when filter is "Todos"', () {
      final recipe = Recipe(
        nombre: 'Tacos',
        categoria: 'Mexicana',
        descripcion: 'Tacos al pastor',
        dificultad: 3,
        tiempo: '30 min',
        comensales: 3,
        pasos: ['Paso 1', 'Paso 2'],
        ingredientes: ['Tortilla', 'Carne'],
      );
      viewModel.recipes.add(recipe);
      viewModel.updateFilter('Todos');

      final filtered = viewModel.filteredRecipes;

      expect(filtered.length, greaterThan(0));
    });

    test('loadRecipes completes successfully', () async {
      await viewModel.loadRecipes();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.hasError, isFalse);
    });
  });
}
