import 'package:migaz/core/config/routes.dart';
import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/ui/widgets/auth/user_credentials.dart';
import 'package:migaz/ui/widgets/comentarios/comentarios_popup.dart';
import 'package:migaz/ui/widgets/recipe/user_avatar.dart';
import 'package:migaz/ui/widgets/recipe/ventana_crear_receta.dart';
import 'package:flutter/material.dart';
import 'package:migaz/core/utils/app_theme.dart';
import 'package:migaz/viewmodels/recipe_list_viewmodel.dart';
import 'package:migaz/viewmodels/home_viewmodel.dart';
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
      providers: [ChangeNotifierProvider(create: (_) => RecipeListViewModel())],
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
    // Cargar datos al iniciar la pantalla
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
      builder: (context, recipeListViewModel, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(gradient: AppTheme.appGradient),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, recipeListViewModel),
                  _buildSearchSection(recipeListViewModel),
                  const SizedBox(height: 16),
                  Expanded(
                    child:
                        recipeListViewModel.searchQuery.isNotEmpty ||
                            recipeListViewModel.selectedFilter != 'Todos'
                        ? _buildSearchResults(recipeListViewModel)
                        : _buildHomeContent(),
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
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
          const SizedBox(width: 12),
          SizedBox(
            width: 300,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const Text(
                'Nombre de usuario',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
          nombre: receta.nombre,
          categoria: receta.categoria,
          valoracion: receta.valoracion,
          onTap: () => _mostrarDetallesReceta(context, receta),
        );
      },
    );
  }

  // Construir contenido de home usando HomeViewModel
  Widget _buildHomeContent() {
    return Consumer<HomeViewModel>(
      builder: (context, homeViewModel, child) {
        if (homeViewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (homeViewModel.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    homeViewModel.errorMessage ?? 'Error desconocido',
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => homeViewModel.cargarHome(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryYellow,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: homeViewModel.refrescarHome,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  // TODAS LAS RECETAS
                  _buildSectionTitle('📚 Todas las Recetas'),
                  const SizedBox(height: 8),
                  RecipeCarousel(
                    title: '',
                    recipes: homeViewModel.todasLasRecetas,
                    emptyMessage: 'No hay recetas en la base de datos',
                    onRecipeTap: (index) {
                      final receta = homeViewModel.todasLasRecetas[index];
                      print('Receta seleccionada: ${receta.nombre}');
                      _mostrarDetallesReceta(context, receta);
                    },
                  ),
                  const SizedBox(height: 24),

                  // MÁS VALORADAS
                  _buildSectionTitle('⭐ Más Valoradas'),
                  const SizedBox(height: 8),
                  RecipeCarousel(
                    title: '',
                    recipes: homeViewModel.recetasMasValoradas,
                    emptyMessage: 'No hay recetas valoradas aún',
                    onRecipeTap: (index) {
                      final receta = homeViewModel.recetasMasValoradas[index];
                      print('Receta seleccionada: ${receta.nombre}');
                      _mostrarDetallesReceta(context, receta);
                    },
                  ),
                  const SizedBox(height: 24),

                  // NUEVAS
                  _buildSectionTitle('🆕 Nuevas'),
                  const SizedBox(height: 8),
                  RecipeCarousel(
                    title: '',
                    recipes: homeViewModel.recetasMasNuevas,
                    emptyMessage: 'No hay recetas nuevas aún',
                    onRecipeTap: (index) {
                      final receta = homeViewModel.recetasMasNuevas[index];
                      print('Receta seleccionada:  ${receta.nombre}');
                      _mostrarDetallesReceta(context, receta);
                    },
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
          color: const Color.fromARGB(255, 243, 243, 243).withOpacity(0.5),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(),
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

  // Método para mostrar detalles de la receta
  void _mostrarDetallesReceta(BuildContext context, Recipe receta) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // IMAGEN REAL DE LA RECETA
                  _buildRecipeImage(receta),
                  const SizedBox(height: 16),

                  Text(
                    receta.nombre,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (receta.descripcion.isNotEmpty)
                    Text(
                      receta.descripcion,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _infoItem(
                              icon: Icons.schedule,
                              label: 'Tiempo',
                              valor: receta.tiempo,
                            ),
                            _infoItem(
                              icon: Icons.star,
                              label: 'Dificultad',
                              valor: receta.dificultadTexto,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _infoItem(
                              icon: Icons.people,
                              label: 'Comensales',
                              valor: '${receta.comensales}',
                            ),
                            _infoItem(
                              icon: Icons.restaurant,
                              label: 'Categoría',
                              valor: receta.categoria,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Ingredientes
                  if (receta.ingredientes.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Ingredientes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: receta.ingredientes
                          .map(
                            (ingrediente) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.circle,
                                    size: 6,
                                    color: Colors.teal,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(ingrediente)),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],

                  // Pasos
                  if (receta.pasos.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Pasos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        receta.pasos.length,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.teal,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(receta.pasos[index])),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Botón comentarios
                  ElevatedButton.icon(
                    onPressed: () {
                      final userCred = Provider.of<UserCredentials>(
                        context,
                        listen: false,
                      );

                      String currentUserName = 'Usuario';
                      if (userCred.email.isNotEmpty &&
                          userCred.email.contains('@')) {
                        currentUserName = userCred.email.split('@')[0];
                      }

                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (ctx) => ComentariosPopup(
                          recipe: receta,
                          currentUserName: currentUserName,
                        ),
                      );
                    },
                    icon: const Icon(Icons.comment),
                    label: const Text('Comentarios'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botón cerrar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Cerrar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Método para construir la imagen
  Widget _buildRecipeImage(Recipe receta) {
    // Si tiene imágenes, usar la primera
    if (receta.imagenes != null && receta.imagenes!.isNotEmpty) {
      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 250,
            height: 200,
            child: Image.network(
              receta.imagenes!.first,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 250,
                  height: 200,
                  color: Colors.grey[300],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholderImage();
              },
            ),
          ),
        ),
      );
    }

    return _buildPlaceholderImage();
  }

  // Método para el placeholder
  Widget _buildPlaceholderImage() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 250,
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.grey[300]!, Colors.grey[400]!],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant, size: 60, color: Colors.grey[600]),
              const SizedBox(height: 8),
              Text(
                'Sin imagen',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método para los info items
  Widget _infoItem({
    required IconData icon,
    required String label,
    required String valor,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.teal),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateRecipeButton(
    BuildContext context,
    RecipeListViewModel viewModel,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton(
          onPressed: () async {
            final Recipe? nueva = await showDialog<Recipe>(
              context: context,
              builder: (context) => DialogoCrearReceta(
                categorias: viewModel.categories
                    .where((c) => c != 'Todos')
                    .toList(),
                dificultades: viewModel.dificultadLabels,
              ),
            );

            if (nueva == null) return;

            final exito = await viewModel.crearReceta(nueva);

            if (context.mounted) {
              if (exito) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Receta guardada en servidor'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      viewModel.errorMessage ?? 'Error al guardar receta',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black,
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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
