import 'package:migaz/config/routes.dart';
import 'package:migaz/models/recipe.dart';
import 'package:migaz/utils/network.dart';
import 'package:migaz/widgets/recipe/user_avatar.dart';
import 'package:migaz/widgets/recipe/ventana_crear_receta.dart';
import 'package:flutter/material.dart';
import 'package:migaz/utils/app_theme.dart';
import 'package:migaz/viewmodels/recipe_list_viewmodel.dart';
import 'package:provider/provider.dart';
import '../widgets/recipe/recipe_filter_dropdown.dart';
import '../widgets/recipe/recipe_search_bar.dart';
import '../widgets/recipe/recipe_card.dart';
import '../widgets/recipe/recipe_carousel.dart';

class PantallaRecetas extends StatelessWidget {
  const PantallaRecetas({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecipeListViewModel(),
      child: const _PantallaRecetasView(),
    );
  }
}

class _PantallaRecetasView extends StatefulWidget {
  const _PantallaRecetasView({Key? key}) : super(key: key);

  @override
  State<_PantallaRecetasView> createState() => _PantallaRecetasViewState();
}

class _PantallaRecetasViewState extends State<_PantallaRecetasView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeListViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(gradient: AppTheme.appGradient),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, viewModel),
                  _buildSearchSection(viewModel),
                  const SizedBox(height: 16),
                  Expanded(
                    child: viewModel.searchQuery.isNotEmpty ||
                            viewModel.selectedFilter != 'Todos'
                        ? _buildSearchResults(viewModel)
                        : _buildHomeContent(),
                  ),
                  _buildCreateRecipeButton(context, viewModel),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, RecipeListViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // limitar ancho del botón para que no estire la fila
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: ElevatedButton(
              onPressed: () {
                print(
                  '📚 Navegando a biblioteca con ${viewModel.recipes.length} recetas',
                );
                // Pasar la lista de recetas cuando navegues a biblioteca
                Navigator.pushNamed(
                  context,
                  AppRoutes.biblioteca,
                  arguments: viewModel.recipes,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF25CCAD),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 5,
              ),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Biblioteca',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          // espacio flexible para el título (centrado y recortado si hace falta)
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Nombre Usuario',
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),

          // avatar con tamaño fijo
          UserAvatar(
            imageUrl:
                'https://raw.githubusercontent.com/FranMejiasGlez/TallerFlutter/main/sandbox_fran/imperativo/img/Logo.png',
            onTap: () => Navigator.pushNamed(context, AppRoutes.perfilUser),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(RecipeListViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          RecipeFilterDropdown(
            value: viewModel.selectedFilter,
            categories: viewModel.categories,
            onChanged: (newValue) {
              if (newValue != null) {
                viewModel.updateFilter(newValue);
              }
            },
          ),
          const SizedBox(height: 12),
          RecipeSearchBar(
            controller: _searchController,
            onChanged: (value) => viewModel.updateSearchQuery(value),
            onClear: () {
              _searchController.clear();
              viewModel.clearSearch();
            },
            showClearButton: viewModel.searchQuery.isNotEmpty,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(RecipeListViewModel viewModel) {
    if (viewModel.filteredRecipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            const Text('No se encontraron recetas'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: viewModel.filteredRecipes.length,
      itemBuilder: (context, index) {
        final receta = viewModel.filteredRecipes[index];
        return RecipeCard(
          nombre: receta['nombre'],
          categoria: receta['categoria'],
          valoracion: receta['valoracion'],
          onTap: () => print('Receta: ${receta['nombre']}'),
        );
      },
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          RecipeCarousel(
            title: 'Más valorado',
            recipes: List.generate(10, (i) => 'Receta $i'),
          ),
          RecipeCarousel(
            title: 'Más nuevo',
            recipes: List.generate(10, (i) => 'Receta $i'),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateRecipeButton(BuildContext context, RecipeListViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton(
          onPressed: () async {
            final Recipe? nueva = await showDialog<Recipe>(
              context: context,
              builder: (context) => DialogoCrearReceta(
                categorias: viewModel.categories.where((c) => c != 'Todos').toList(),
                dificultades: viewModel.difficultyLevels,
              ),
            );

            if (nueva == null) return; // usuario canceló

            // opcion A: guardar en servidor y en UI
            try {
              await saveRecipeToServer(
                nueva,
              ); // import in the header: utils/network.dart

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Receta guardada en servidor')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error guardando: $e')));
              }
            }
            viewModel.addRecipe(nueva);
            print('✅ Receta creada: ${nueva.nombre}'); // Debug
            print('📋 Total recetas en lista: ${viewModel.recipes.length}'); // Debug
          },

          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 5,
          ),
          child: const Text('Crear Receta'),
        ),
      ),
    );
  }
}
