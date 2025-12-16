import 'package:migaz/core/config/api_config.dart';
import 'package:migaz/core/config/routes.dart';
import 'package:migaz/core/constants/recipe_constants.dart';
import 'package:migaz/core/utils/recipe_utils.dart';
import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/data/repositories/receta_repository.dart';
import 'package:migaz/ui/widgets/recipe/recipe_detail_dialog.dart';
import 'package:migaz/ui/widgets/recipe/recipe_grid_view.dart';
import 'package:migaz/ui/widgets/recipe/recipe_search_section.dart';
import 'package:migaz/ui/widgets/recipe/user_avatar.dart';
import 'package:migaz/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:migaz/ui/widgets/recipe/recipe_carousel.dart';
import 'package:provider/provider.dart';
import 'package:migaz/viewmodels/user_viewmodel.dart';
import 'package:migaz/viewmodels/auth_viewmodel.dart';

/// Pantalla para ver el perfil/biblioteca de OTRO usuario (no el actual).
/// Muestra las recetas creadas por ese usuario.
class PantallaRecetasDistinctUser extends StatefulWidget {
  /// Nombre/ID del usuario cuyo perfil se va a mostrar
  final String nombreUsuario;

  const PantallaRecetasDistinctUser({Key? key, required this.nombreUsuario})
    : super(key: key);

  @override
  State<PantallaRecetasDistinctUser> createState() =>
      _PantallaRecetasDistinctUserState();
}

class _PantallaRecetasDistinctUserState
    extends State<PantallaRecetasDistinctUser> {
  final TextEditingController _searchController = TextEditingController();
  final RecetaRepository _recetaRepository = RecetaRepository();

  List<Recipe> _recetasDelUsuario = [];
  String _searchQuery = '';
  String _filtroSeleccionado = 'Todos';
  bool _isLoading = true;
  String? _errorMessage;
  String? _targetUserId; // ID del usuario que estamos viendo
  bool _isFollowing = false;
  String? _targetUserImage;

  /// Usuario actual logueado (para comparar)
  String get _currentUser => ApiConfig.currentUser;

  /// Verifica si estamos viendo nuestro propio perfil
  bool get _esMiPerfil => widget.nombreUsuario == _currentUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatos();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔥 Cargando recetas del usuario: ${widget.nombreUsuario}');

      // 1. Cargar Recetas
      final recetasFuture = _recetaRepository.obtenerPorUsuario(
        widget.nombreUsuario,
      );

      // 2. Cargar Info del Usuario (para obtener ID y Foto)
      final userVM = context.read<UserViewModel>();
      final authVM = context.read<AuthViewModel>();

      final publicProfileFuture = userVM.getPublicProfileByUsername(
        widget.nombreUsuario,
      );

      final results = await Future.wait([recetasFuture, publicProfileFuture]);
      final recetas = results[0] as List<Recipe>;
      final profile = results[1] as Map<String, dynamic>?;

      recetas.sort((a, b) {
        final fechaA = a.fechaCreacion ?? DateTime(2000);
        final fechaB = b.fechaCreacion ?? DateTime(2000);
        return fechaB.compareTo(fechaA);
      });

      if (mounted) {
        String? targetId;
        String? targetImg;
        bool isSiguiendo = false;

        if (profile != null) {
          targetId = profile['_id'];
          targetImg = profile['profile_image'];

          // Verificar si lo sigo
          if (authVM.currentUserId.isNotEmpty && targetId != null) {
            // Asegurar cargar mi perfil para verificar follow status
            if (userVM.following.isEmpty) {
              await userVM.loadUserProfile(authVM.currentUserId);
            }
            isSiguiendo = userVM.following.any((u) => u['_id'] == targetId);
          }
        }

        setState(() {
          _recetasDelUsuario = recetas;
          _targetUserId = targetId;
          _targetUserImage = targetImg;
          _isFollowing = isSiguiendo;
          _isLoading = false;
        });

        print('✅ Recetas cargadas: ${recetas.length}');
      }
    } catch (e) {
      print('❌ Error al cargar datos del usuario: $e');
      if (mounted) {
        setState(() {
          _errorMessage =
              'Error al cargar el perfil de ${widget.nombreUsuario}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleFollow() async {
    if (_targetUserId == null) return;

    final authVM = context.read<AuthViewModel>();
    final userVM = context.read<UserViewModel>();

    if (authVM.currentUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para seguir a usuarios'),
        ),
      );
      return;
    }

    final exito = await userVM.toggleFollow(
      authVM.currentUserId,
      _targetUserId!,
    );

    if (exito && mounted) {
      // Actualizamos estado localmente invirtiendo el valor actual
      // (aunque toggleFollow recarga el perfil, aquí solo necesitamos cambiar el bool visual)
      setState(() {
        _isFollowing = !_isFollowing;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFollowing
                ? 'Ahora sigues a ${widget.nombreUsuario}'
                : 'Dejaste de seguir a ${widget.nombreUsuario}',
          ),
          backgroundColor: _isFollowing ? Colors.green : Colors.redAccent,
        ),
      );
    }
  }

  List<Recipe> get _recetasFiltradas {
    return RecipeUtils.filterRecipes(
      recipes: _recetasDelUsuario,
      searchQuery: _searchQuery,
      selectedFilter: _filtroSeleccionado,
    );
  }

  bool get _hasActiveFilters {
    return RecipeUtils.hasActiveFilters(
      searchQuery: _searchQuery,
      selectedFilter: _filtroSeleccionado,
    );
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
              _buildUserInfoBanner(),
              _buildSearchSection(),
              const SizedBox(height: 16),
              Expanded(
                child: _hasActiveFilters
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBackButton(),
          const SizedBox(width: 8),
          Expanded(child: _buildTitle()),
          const SizedBox(width: 8),
          UserAvatar(
            imageUrl: _targetUserImage ?? RecipeConstants.defaultAvatarUrl,
            onTap: () {
              if (_esMiPerfil) {
                Navigator.pushNamed(context, AppRoutes.perfilUser);
              }
            },
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
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: _esMiPerfil
                ? const Color(0xFFEA7317).withOpacity(0.5)
                : Colors.blue.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Column(
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_esMiPerfil) ...[
                      const Icon(Icons.person, size: 20),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      _esMiPerfil
                          ? 'Tu biblioteca'
                          : 'Perfil de ${widget.nombreUsuario}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (!_isLoading)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${_recetasDelUsuario.length} ${_recetasDelUsuario.length == 1 ? "receta" : "recetas"}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                  ),
                ),
            ],
          ),
        ),
        // BOTÓN SEGUIR
        if (!_esMiPerfil && _targetUserId != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              height: 32,
              child: ElevatedButton.icon(
                onPressed: _toggleFollow,
                icon: Icon(
                  _isFollowing ? Icons.check : Icons.person_add,
                  size: 16,
                ),
                label: Text(_isFollowing ? 'Siguiendo' : 'Seguir'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFollowing
                      ? Colors.green.shade100
                      : Colors.blue.shade100,
                  foregroundColor: _isFollowing
                      ? Colors.green.shade900
                      : Colors.blue.shade900,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Banner que indica claramente que es otro usuario
  Widget _buildUserInfoBanner() {
    if (_esMiPerfil) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.visibility, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estás viendo el perfil de otro usuario',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Solo puedes ver sus recetas públicas',
                  style: TextStyle(color: Colors.blue[600], fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildSearchResults() {
    if (_recetasFiltradas.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off,
        message: 'No se encontraron recetas',
      );
    }

    return RecipeGridView(recipes: _recetasFiltradas);
  }

  Widget _buildHomeContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_recetasDelUsuario.isEmpty) {
      return _buildEmptyState(
        icon: Icons.restaurant_menu,
        message: '${widget.nombreUsuario} no tiene recetas publicadas',
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              _buildCarouselSection(
                title: 'Recetas de ${widget.nombreUsuario}',
                recipes: _recetasDelUsuario,
                emptyMessage: 'Este usuario no tiene recetas',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Error desconocido',
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _cargarDatos,
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

  Widget _buildCarouselSection({
    required String title,
    required List<Recipe> recipes,
    required String emptyMessage,
  }) {
    return Column(
      children: [
        _buildCarouselTitle(title, recipes.length),
        const SizedBox(height: 8),
        RecipeCarousel(
          title: '',
          recipes: recipes,
          emptyMessage: emptyMessage,
          onRecipeTap: (index) async {
            if (recipes.isNotEmpty) {
              await RecipeDetailDialog.show(context, recipes[index]);

              // Recargar datos al volver
              if (mounted) {
                await _cargarDatos();
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildCarouselTitle(String title, int count) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: _esMiPerfil
              ? const Color(0xFFEA7317).withOpacity(0.5)
              : Colors.blue.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
