import 'package:migaz/config/routes.dart';
import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/core/utils/network. dart';
import 'package: migaz/ui/widgets/recipe/user_avatar.dart';
import 'package:migaz/ui/widgets/recipe/ventana_crear_receta.dart';
import 'package:flutter/material.dart';
import 'package:migaz/core/utils/app_theme.dart';
import 'package:migaz/viewmodels/recipe_list_viewmodel.dart';
import 'package:migaz/viewmodels/home_viewmodel.dart'; // ✅ NUEVO
import 'package:provider/provider.dart';
import '../widgets/recipe/recipe_filter_dropdown.dart';
import '../widgets/recipe/recipe_search_bar.dart';
import '../widgets/recipe/recipe_card.dart';
import '../widgets/recipe/recipe_carousel.dart';

class PantallaRecetas extends StatelessWidget {
  const PantallaRecetas({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecipeListViewModel()),
        // ✅ Usar el HomeViewModel del provider global
        // Ya no necesitamos crearlo aquí porque está en main.dart
      ],
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
  void initState() {
    super.initState();
    // ✅ Cargar datos al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().cargarHome();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeListViewModel>(
      builder:  (context, recipeListViewModel, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(gradient: AppTheme.appGradient),
            child:  SafeArea(
              child:  Column(
                children: [
                  _buildHeader(context, recipeListViewModel),
                  _buildSearchSection(recipeListViewModel),
                  const SizedBox(height: 16),
                  Expanded(
                    child: recipeListViewModel.searchQuery.isNotEmpty ||
                            recipeListViewModel. selectedFilter != 'Todos'
                        ? _buildSearchResults(recipeListViewModel)
                        : _buildHomeContent(), // ✅ Aquí mostramos las secciones
                  ),
                  _buildCreateRecipeButton(context, recipeListViewModel),
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
      padding: const EdgeInsets.symmetric(horizontal: 24. 0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            child: ElevatedButton(
              onPressed: () {
                print(
                  '📚 Navegando a biblioteca con ${viewModel.recipes.length} recetas',
                );
                Navigator.pushNamed(
                  context,
                  AppRoutes.biblioteca,
                  arguments: viewModel.recipes,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25CCAD),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                shape:  RoundedRectangleBorder(
                  borderRadius:  BorderRadius.circular(20),
                ),
                elevation: 5,
              ),
              child:  const FittedBox(
                fit:  BoxFit.scaleDown,
                child: Text(
                  'Biblioteca',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 300,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const Text(
                'Nombre de usuario',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
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
        child:  Column(
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
      itemCount: viewModel. filteredRecipes.length,
      itemBuilder: (context, index) {
        final receta = viewModel.filteredRecipes[index];
        return RecipeCard(
          nombre: receta['nombre'],
          categoria: receta['categoria'],
          valoracion: receta['valoracion'],
          onTap: () => print('Receta:  ${receta['nombre']}'),
        );
      },
    );
  }

  // ✅ NUEVO: Construir contenido de home usando HomeViewModel
  Widget _buildHomeContent() {
    return Consumer<HomeViewModel>(
      builder: (context, homeViewModel, child) {
        // Mostrar loading
        if (homeViewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Mostrar error
        if (homeViewModel.hasError) {
          return Center(
            child:  Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors. red,
                  ),
                  const SizedBox(height:  16),
                  Text(
                    homeViewModel.errorMessage ??  'Error desconocido',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton. icon(
                    onPressed:  () => homeViewModel.cargarHome(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style:  ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryYellow,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Mostrar contenido
        return RefreshIndicator(
          onRefresh: homeViewModel.refrescarHome,
          child:  SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child:  Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  // --- SECCIÓN:  MÁS VALORADAS ---
                  _buildSectionTitle('Más Valoradas'),
                  const SizedBox(height: 8),
                  _buildRecipeCarousel(
                    homeViewModel.recetasMasValoradas,
                    emptyMessage: 'No hay recetas valoradas aún',
                  ),
                  const SizedBox(height: 24),

                  // --- SECCIÓN:  NUEVAS ---
                  _buildSectionTitle('Nuevas'),
                  const SizedBox(height: 8),
                  _buildRecipeCarousel(
                    homeViewModel.recetasMasNuevas,
                    emptyMessage: 'No hay recetas nuevas aún',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Center(
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: const Color. fromARGB(255, 243, 243, 243).withOpacity(0.5),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildRecipeCarousel(List<Recipe> recetas, {String? emptyMessage}) {
    if (recetas.isEmpty) {
      return Center(
        child:  Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            emptyMessage ?? 'No hay recetas disponibles',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return RecipeCarousel(
      title: '',
      recipes: recetas. map((recipe) => recipe.nombre).toList(),
      onRecipeTap: (index) {
        final receta = recetas[index];
        print('Receta seleccionada: ${receta.nombre}');
        // TODO: Navegar a detalle de receta
        // Navigator.pushNamed(context, AppRoutes.detalleReceta, arguments: receta);
      },
    );
  }

  Widget _buildCreateRecipeButton(
    BuildContext context,
    RecipeListViewModel viewModel,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child:  Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton(
          onPressed:  () async {
            final Recipe?  nueva = await showDialog<Recipe>(
              context: context,
              builder: (context) => DialogoCrearReceta(
                categorias: viewModel.categories
                    .where((c) => c != 'Todos')
                    .toList(),
                dificultades: viewModel.difficultyLevels,
              ),
            );

            if (nueva == null) return;

            try {
              await saveRecipeToServer(nueva);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Receta guardada en servidor')),
                );
                
                // ✅ Refrescar home después de crear receta
                context.read<HomeViewModel>().refrescarHome();
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger. of(context).showSnackBar(
                  SnackBar(content: Text('Error guardando:  $e')),
                );
              }
            }
            viewModel.addRecipe(nueva);
          },
          style:  ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black,
            elevation: 0,
            padding:  EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius:  BorderRadius.circular(30),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow:  [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius:  8,
                  offset:  const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF25CCAD),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(Icons.add, color: Colors.black, size: 28),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFC107),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Crear nueva receta',
                    style:  TextStyle(
                      fontSize:  16,
                      fontWeight: FontWeight.bold,
                      color: Colors. black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}