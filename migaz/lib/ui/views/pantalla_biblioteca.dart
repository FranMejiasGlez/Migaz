import 'package:migaz/core/config/routes.dart';
import 'package:migaz/ui/widgets/auth/user_credentials.dart';
import 'package:migaz/ui/widgets/comentarios/comentarios_popup.dart';
import 'package:migaz/ui/widgets/recipe/user_avatar.dart';
import 'package:migaz/data/models/recipe.dart';
import 'package:flutter/material.dart';
import 'package:migaz/core/utils/app_theme.dart';
import 'package:provider/provider.dart';
import '../widgets/recipe/recipe_filter_dropdown.dart';
import '../widgets/recipe/recipe_search_bar.dart';
import '../widgets/recipe/recipe_card.dart';
import '../widgets/recipe/recipe_carousel.dart';

class PantallaBiblioteca extends StatefulWidget {
  final List<Recipe>? listaRecetas;
  const PantallaBiblioteca({
    Key? key,
    this.listaRecetas, // Recibe la lista de PantallaRecetas
  }) : super(key: key);

  @override
  State<PantallaBiblioteca> createState() => _PantallaBibliotecaState();
}

class _PantallaBibliotecaState extends State<PantallaBiblioteca> {
  List<Recipe>? _recetasLocales;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filtroSeleccionado = 'Todos';

  final List<String> _categorias = [
    'Todos',
    'Española',
    'Italiana',
    'Japonesa',
    'Mexicana',
  ];

  // ignore: unused_field
  final List<String> _dificultad = ['fácil', 'Medio', 'Difícil'];
  final List<Recipe> _todasLasRecetasCompletas = [];
  void _mostrarDetallesReceta(Recipe receta) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                  // ✅ IMAGEN REAL DE LA RECETA
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
                              valor: receta.dificultadTexto, // ✅ MEJORADO
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
                      onPressed: () => Navigator.pop(context),
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

  // ✅ AÑADIR ESTE MÉTODO PARA CONSTRUIR LA IMAGEN
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
              receta.imagenes!.first, // ✅ USAR LA IMAGEN REAL
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
                // Si falla, mostrar placeholder
                return _buildPlaceholderImage();
              },
            ),
          ),
        ),
      );
    }

    // Si no tiene imagen, mostrar placeholder
    return _buildPlaceholderImage();
  }

  // ✅ AÑADIR ESTE MÉTODO PARA EL PLACEHOLDER
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

  List<Recipe> get _recetasFiltradas {
    return _todasLasRecetasCompletas.where((receta) {
      final matchesSearch = receta.nombre.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesFilter =
          _filtroSeleccionado == 'Todos' ||
          receta.categoria == _filtroSeleccionado;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Intentamos recuperar la lista desde los argumentos de la navegación
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is List<Recipe>) {
      setState(() {
        _recetasLocales = args;
      });
    }
    // Si viene como una lista genérica (a veces pasa en Flutter)
    else if (args is List) {
      setState(() {
        _recetasLocales = List<Recipe>.from(args);
      });
    }
    // Fallback: Si no hay argumentos, usamos lo del constructor
    else if (widget.listaRecetas != null) {
      setState(() {
        _recetasLocales = widget.listaRecetas;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Inicializamos la lista local con la que viene del constructor
    if (widget.listaRecetas != null) {
      _recetasLocales = widget.listaRecetas;
    } else {
      // O inicializa con una lista vacía o datos de prueba para que funcione
      _recetasLocales = [];
    }
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.guardados);
                      },
                      icon: const Icon(Icons.bookmark),
                      label: const Text('Guardados'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFEA7317).withOpacity(0.5),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        minimumSize: const Size(80, 36),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            print(
                              '📖 Navegando a Mis Recetas con ${_recetasLocales?.length ?? 0} recetas',
                            );
                            Navigator.pushNamed(
                              context,
                              AppRoutes.misrecetas,
                              arguments: _recetasLocales,
                            );
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Mis Recetas'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFEA7317).withOpacity(0.5),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            minimumSize: const Size(80, 36),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _searchQuery.isNotEmpty || _filtroSeleccionado != 'Todos'
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
          SizedBox(
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.home);
              },
            ),
          ),

          const SizedBox(width: 10),
          SizedBox(
            width: 300,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEA7317).withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Tu biblioteca',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          UserAvatar(
            imageUrl:
                'https://raw.githubusercontent.com/FranMejiasGlez/TallerFlutter/main/sandbox_fran/imperativo/img/Logo.png',
            onTap: () => Navigator.pushNamed(context, AppRoutes.perfilUser),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          RecipeFilterDropdown(
            value: _filtroSeleccionado,
            categories: _categorias,
            onChanged: (newValue) {
              if (newValue != null) {
                setState(() => _filtroSeleccionado = newValue);
              }
            },
          ),
          const SizedBox(height: 12),
          RecipeSearchBar(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            onClear: () => setState(() {
              _searchController.clear();
              _searchQuery = '';
            }),
            showClearButton: _searchQuery.isNotEmpty,
          ),
        ],
      ),
    );
  }

  //!
  Widget _buildSearchResults() {
    if (_recetasFiltradas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text('No se encontraron recetas'),
          ],
        ),
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
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: cardWidth / cardHeight,
            ),
            itemCount: _recetasFiltradas.length,
            itemBuilder: (context, index) {
              final receta = _recetasFiltradas[index];
              return RecipeCard(
                nombre: receta.nombre,
                categoria: receta.categoria,
                valoracion: 4.5, // O añade valoracion al modelo Recipe
                onTap: () => _mostrarDetallesReceta(receta),
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
            // --- CARRUSEL 1: MIS RECETAS ---
            Center(
              child: Container(
                width: 600,
                decoration: BoxDecoration(
                  color: const Color(0xFFEA7317).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: const Text(
                  'Mis Recetas',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // ✅ CORREGIDO: Pasar List<Recipe> en lugar de List<String>
            RecipeCarousel(
              title: '',
              recipes:
                  _recetasLocales ?? [], // ✅ Pasar objetos Recipe completos
              emptyMessage: 'No tienes recetas personales aún',
              onRecipeTap: (index) {
                if (_recetasLocales != null && _recetasLocales!.isNotEmpty) {
                  print(
                    "Click en mis recetas:  ${_recetasLocales![index].nombre}",
                  );
                  _mostrarDetallesReceta(_recetasLocales![index]);
                }
              },
            ),

            const SizedBox(height: 24),

            // --- CARRUSEL 2: GUARDADOS ---
            Center(
              child: Container(
                width: 600,
                decoration: BoxDecoration(
                  color: const Color(0xFFEA7317).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: const Text(
                  'Guardados',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // ✅ CORREGIDO:  Pasar List<Recipe> en lugar de List<String>
            RecipeCarousel(
              title: '',
              recipes:
                  _todasLasRecetasCompletas, // ✅ Pasar objetos Recipe completos
              emptyMessage: 'No has guardado ninguna receta',
              onRecipeTap: (index) {
                print(
                  "Click en receta guardada: ${_todasLasRecetasCompletas[index].nombre}",
                );
                _mostrarDetallesReceta(_todasLasRecetasCompletas[index]);
              },
            ),
          ],
        ),
      ),
    );
  }
}
