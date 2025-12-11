// lib/ui/widgets/recipe/recipe_detail_dialog.dart
import 'package:flutter/material.dart';
import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/ui/widgets/recipe/rating_stars.dart';
import 'package:migaz/ui/widgets/recipe/rating_display.dart';
import 'package:migaz/ui/widgets/recipe/recipe_image_widget.dart';
import 'package:migaz/ui/widgets/comentarios/comentarios_popup.dart';
import 'package:migaz/viewmodels/home_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:migaz/ui/widgets/auth/user_credentials.dart';

class RecipeDetailDialog {
  static void show(BuildContext context, Recipe recipe) {
    showDialog(
      context: context,
      builder: (context) => _RecipeDetailDialogContent(recipe: recipe),
    );
  }
}

class _RecipeDetailDialogContent extends StatefulWidget {
  final Recipe recipe;

  const _RecipeDetailDialogContent({required this.recipe});

  @override
  State<_RecipeDetailDialogContent> createState() =>
      _RecipeDetailDialogContentState();
}

class _RecipeDetailDialogContentState
    extends State<_RecipeDetailDialogContent> {
  late Recipe _recipe;
  double _myRating = 0;
  bool _isRating = false;
  bool _showIngredients = false; // ✅ NUEVO: Controlar panel lateral
  String _currentUser = 'usuario_demo'; //!!

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
    // ✅ NUEVO: Cargar usuario actual
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final credentials = Provider.of<UserCredentials>(context, listen: false);
      setState(() {
        _currentUser = credentials.email.isNotEmpty
            ? credentials.email.split('@').first
            : 'usuario_demo';
      });
    });
  }

  // ✅ NUEVO: Botón de guardar (añadir después de _buildCommentsButton)
  Widget _buildSaveButton() {
    // No mostrar si es mi propia receta
    if (_recipe.esMia(_currentUser)) {
      return const SizedBox.shrink();
    }

    return Consumer<HomeViewModel>(
      builder: (context, homeViewModel, child) {
        final isGuardada = _recipe.isGuardada;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isGuardada
                ? Colors.amber.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isGuardada
                  ? Colors.amber.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.3),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _handleSaveRecipe(homeViewModel),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isGuardada ? Colors.amber : Colors.grey[400],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isGuardada ? Icons.bookmark : Icons.bookmark_border,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isGuardada
                                ? 'Guardada en favoritos'
                                : 'Guardar receta',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isGuardada
                                ? 'Toca para quitar de favoritos'
                                : 'Guarda esta receta para verla después',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isGuardada
                          ? Icons.check_circle
                          : Icons.add_circle_outline,
                      color: isGuardada ? Colors.amber : Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ✅ NUEVO: Manejar guardar/quitar
  Future<void> _handleSaveRecipe(HomeViewModel homeViewModel) async {
    if (_recipe.id == null) return;

    final wasGuardada = _recipe.isGuardada;

    final exito = await homeViewModel.toggleGuardarReceta(
      _recipe.id!,
      _currentUser,
    );

    if (mounted && exito) {
      setState(() {
        _recipe.isGuardada = !wasGuardada;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _recipe.isGuardada
                ? '✅ Receta guardada en favoritos'
                : '✅ Receta eliminada de favoritos',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleRating(double rating) async {
    if (_isRating) return;

    setState(() {
      _isRating = true;
      _myRating = rating;
    });

    final homeViewModel = context.read<HomeViewModel>();

    final success = await homeViewModel.valorarReceta(
      _recipe.id!,
      rating,
      'usuario_demo',
    );

    if (success) {
      final updatedRecipes = homeViewModel.todasLasRecetas
          .where((r) => r.id == _recipe.id)
          .toList();

      if (updatedRecipes.isNotEmpty) {
        setState(() {
          _recipe = updatedRecipes.first;
          _isRating = false;
        });
      } else {
        setState(() {
          _isRating = false;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Valoración guardada:  ${rating.toInt()} estrellas',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      setState(() {
        _isRating = false;
        _myRating = 0;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al guardar valoración'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 600),
        child: Stack(
          children: [
            // ✅ Contenido principal
            Row(
              children: [
                // Contenido principal
                Expanded(
                  child: Column(
                    children: [
                      _buildHeader(),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildBasicInfo(),
                              const SizedBox(height: 24),
                              _buildRatingSection(),
                              const SizedBox(height: 16),
                              _buildCommentsButton(),
                              const SizedBox(height: 24),
                              _buildSaveButton(),
                              _buildDescription(),
                              const SizedBox(height: 24),

                              // ✅ NUEVO:  Botón para mostrar/ocultar ingredientes
                              _buildIngredientsToggleButton(),
                              const SizedBox(height: 24),

                              _buildInstructions(),
                              if (_recipe.youtube != null &&
                                  _recipe.youtube!.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                _buildYoutubeLink(),
                              ],
                            ],
                          ),
                        ),
                      ),
                      _buildFooter(),
                    ],
                  ),
                ),

                // ✅ NUEVO: Panel lateral de ingredientes
                if (_showIngredients) _buildIngredientsSidePanel(),
              ],
            ),

            // ✅ NUEVO:  Botón flotante para abrir/cerrar
            Positioned(
              right: _showIngredients ? 310 : 16,
              top: 220,
              child: _buildFloatingIngredientsButton(),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ NUEVO:  Botón flotante para toggle
  Widget _buildFloatingIngredientsButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        setState(() {
          _showIngredients = !_showIngredients;
        });
      },
      backgroundColor: Colors.green,
      icon: Icon(
        _showIngredients ? Icons.close : Icons.restaurant_menu,
        color: Colors.white,
      ),
      label: Text(
        _showIngredients ? 'Ocultar' : 'Ingredientes',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ✅ NUEVO: Panel lateral desplegable
  Widget _buildIngredientsSidePanel() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 300,
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border(
          left: BorderSide(color: Colors.green.shade300, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(-5, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del panel
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.restaurant_menu, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Ingredientes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${_recipe.ingredientes.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Lista de ingredientes
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _recipe.ingredientes.length,
              itemBuilder: (context, index) {
                final ingrediente = _recipe.ingredientes[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          ingrediente,
                          style: const TextStyle(fontSize: 14, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ✅ NUEVO:  Botón en el contenido para mostrar ingredientes
  Widget _buildIngredientsToggleButton() {
    return InkWell(
      onTap: () {
        setState(() {
          _showIngredients = !_showIngredients;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_menu,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ver ingredientes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${_recipe.ingredientes.length} ingredientes necesarios',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(
              _showIngredients ? Icons.visibility_off : Icons.visibility,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: RecipeImageWidget(
            imageUrl: _recipe.imagenes?.isNotEmpty == true
                ? _recipe.imagenes!.first
                : null,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),

        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
            ),
          ),
        ),

        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Text(
            _recipe.nombre,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black, blurRadius: 8)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ NUEVO:  Mostrar fecha de creación
        if (_recipe.createdAt != null) _buildCreatedAtBanner(),

        const SizedBox(height: 12),

        // Chips existentes
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildInfoChip(Icons.category, _recipe.categoria, Colors.blue),
            _buildInfoChip(
              Icons.people,
              '${_recipe.comensales} personas',
              Colors.green,
            ),
            _buildInfoChip(Icons.timer, _recipe.tiempo, Colors.orange),
            _buildInfoChip(
              Icons.signal_cellular_alt,
              _getDifficultyLabel(_recipe.dificultad),
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  // ✅ NUEVO: Banner con fecha completa y tiempo relativo
  Widget _buildCreatedAtBanner() {
    if (_recipe.createdAt == null) return const SizedBox.shrink();

    final fechaCompleta = _formatearFechaCompleta(_recipe.createdAt!);
    final fechaRelativa = _formatearFechaRelativa(_recipe.createdAt!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade400, Colors.teal.shade600],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today, size: 18, color: Colors.white),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fecha completa
              Text(
                fechaCompleta,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              // Tiempo relativo
              Text(
                fechaRelativa,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ NUEVO: Formatear fecha completa (15 de diciembre de 2025)
  String _formatearFechaCompleta(String fechaString) {
    try {
      final fecha = DateTime.parse(fechaString);

      final meses = [
        '',
        'enero',
        'febrero',
        'marzo',
        'abril',
        'mayo',
        'junio',
        'julio',
        'agosto',
        'septiembre',
        'octubre',
        'noviembre',
        'diciembre',
      ];

      final dia = fecha.day;
      final mes = meses[fecha.month];
      final anios = fecha.year;
      final hora = fecha.hour.toString().padLeft(2, '0');
      final minuto = fecha.minute.toString().padLeft(2, '0');

      return '$dia de $mes de $anios a las $hora:$minuto';
    } catch (e) {
      print('❌ Error al formatear fecha completa: $e');
      return 'Fecha desconocida';
    }
  }

  // ✅ NUEVO:  Formatear fecha relativa (hace 2 días)
  String _formatearFechaRelativa(String fechaString) {
    try {
      final fecha = DateTime.parse(fechaString);
      final ahora = DateTime.now();
      final diferencia = ahora.difference(fecha);

      // Hace menos de 1 minuto
      if (diferencia.inSeconds < 60) {
        return 'Publicada hace unos segundos';
      }

      // Hace menos de 1 hora
      if (diferencia.inMinutes < 60) {
        final minutos = diferencia.inMinutes;
        return 'Publicada hace $minutos ${minutos == 1 ? "minuto" : "minutos"}';
      }

      // Hace menos de 1 día
      if (diferencia.inHours < 24) {
        final horas = diferencia.inHours;
        return 'Publicada hace $horas ${horas == 1 ? "hora" : "horas"}';
      }

      // Hace menos de 1 semana
      if (diferencia.inDays < 7) {
        final dias = diferencia.inDays;
        return 'Publicada hace $dias ${dias == 1 ? "día" : "días"}';
      }

      // Hace menos de 1 mes
      if (diferencia.inDays < 30) {
        final semanas = (diferencia.inDays / 7).floor();
        return 'Publicada hace $semanas ${semanas == 1 ? "semana" : "semanas"}';
      }

      // Hace menos de 1 anios
      if (diferencia.inDays < 365) {
        final meses = (diferencia.inDays / 30).floor();
        return 'Publicada hace $meses ${meses == 1 ? "mes" : "meses"}';
      }

      // Hace más de 1 anios
      final anios = (diferencia.inDays / 365).floor();
      return 'Publicada hace $anios ${anios == 1 ? "anios" : "anios"}';
    } catch (e) {
      print('❌ Error al formatear fecha relativa:  $e');
      return 'Publicada recientemente';
    }
  }

  // ✅ NUEVO: Método para formatear la fecha
  String _formatearFecha(String fechaString) {
    try {
      final fecha = DateTime.parse(fechaString);
      final ahora = DateTime.now();
      final diferencia = ahora.difference(fecha);

      // Hace menos de 1 minuto
      if (diferencia.inSeconds < 60) {
        return 'hace unos segundos';
      }

      // Hace menos de 1 hora
      if (diferencia.inMinutes < 60) {
        final minutos = diferencia.inMinutes;
        return 'hace $minutos ${minutos == 1 ? "minuto" : "minutos"}';
      }

      // Hace menos de 1 día
      if (diferencia.inHours < 24) {
        final horas = diferencia.inHours;
        return 'hace $horas ${horas == 1 ? "hora" : "horas"}';
      }

      // Hace menos de 1 semana
      if (diferencia.inDays < 7) {
        final dias = diferencia.inDays;
        return 'hace $dias ${dias == 1 ? "día" : "días"}';
      }

      // Hace menos de 1 mes
      if (diferencia.inDays < 30) {
        final semanas = (diferencia.inDays / 7).floor();
        return 'hace $semanas ${semanas == 1 ? "semana" : "semanas"}';
      }

      // Hace menos de 1 anios
      if (diferencia.inDays < 365) {
        final meses = (diferencia.inDays / 30).floor();
        return 'hace $meses ${meses == 1 ? "mes" : "meses"}';
      }

      // Hace más de 1 anios
      final anios = (diferencia.inDays / 365).floor();
      return 'hace $anios ${anios == 1 ? "anios" : "anios"}';
    } catch (e) {
      print('❌ Error al formatear fecha:  $e');
      return 'Fecha desconocida';
    }
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Chip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
    );
  }

  String _getDifficultyLabel(int dificultad) {
    switch (dificultad) {
      case 1:
        return 'Muy Fácil';
      case 2:
        return 'Fácil';
      case 3:
        return 'Medio';
      case 4:
        return 'Difícil';
      case 5:
        return 'Muy Difícil';
      default:
        return 'Medio';
    }
  }

  Widget _buildRatingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Valoración',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              const Text(
                'Promedio:  ',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 12),
              RatingDisplay(
                rating: _recipe.valoracion,
                totalVotes: _recipe.cantidadVotos,
                size: 24,
                showNumber: true,
                showVotes: true,
              ),
            ],
          ),

          const Divider(height: 24),

          const Text(
            '¿Qué te ha parecido?',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              RatingStars(
                initialRating: _myRating,
                onRatingChanged: _handleRating,
                size: 36,
                enabled: !_isRating,
              ),
              if (_isRating) ...[
                const SizedBox(width: 16),
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsButton() {
    final comentariosCount = _recipe.comentarios.length;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _showComments,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.comment,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Comentarios',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        comentariosCount == 0
                            ? 'Sé el primero en comentar'
                            : '$comentariosCount ${comentariosCount == 1 ? "comentario" : "comentarios"}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComments() {
    final credentials = Provider.of<UserCredentials>(context, listen: false);
    final currentUser = credentials.email.isNotEmpty
        ? credentials.email.split('@').first
        : 'usuario_demo';

    ComentariosPopup.show(
      context: context,
      recipe: _recipe,
      currentUserName: currentUser,
    );
  }

  Widget _buildDescription() {
    if (_recipe.descripcion.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          _recipe.descripcion,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Instrucciones',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._recipe.pasos.asMap().entries.map((entry) {
          final index = entry.key;
          final paso = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    paso,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildYoutubeLink() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Video Tutorial',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            print('Abrir YouTube:  ${_recipe.youtube}');
          },
          child: Row(
            children: [
              const Icon(Icons.play_circle_outline, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _recipe.youtube!,
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
