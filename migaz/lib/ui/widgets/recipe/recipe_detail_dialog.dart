// lib/ui/widgets/recipe/recipe_detail_dialog. dart
import 'package:flutter/material.dart';
import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/ui/widgets/recipe/rating_stars.dart';
import 'package:migaz/ui/widgets/recipe/rating_display.dart';
import 'package:migaz/viewmodels/home_viewmodel.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
  }

  Future<void> _handleRating(double rating) async {
    if (_isRating) return;

    setState(() {
      _isRating = true;
      _myRating = rating;
    });

    final homeViewModel = context.read<HomeViewModel>();

    // Llamar al backend para valorar
    final success = await homeViewModel.valorarReceta(
      _recipe.id!,
      rating,
      'usuario_demo', // ✅ Usuario temporal
    );

    if (success) {
      // Actualizar la receta localmente
      setState(() {
        // Buscar la receta actualizada en el ViewModel
        final updatedRecipes = homeViewModel.todasLasRecetas
            .where((r) => r.id == _recipe.id)
            .toList();

        if (updatedRecipes.isNotEmpty) {
          _recipe = updatedRecipes.first;
        }

        _isRating = false;
      });

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
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
        child: Column(
          children: [
            // Header con imagen y título
            _buildHeader(),

            // Contenido scrolleable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfo(),
                    const SizedBox(height: 24),
                    _buildRatingSection(), // ✅ NUEVO
                    const SizedBox(height: 24),
                    _buildDescription(),
                    const SizedBox(height: 24),
                    _buildIngredients(),
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

            // Footer con botón cerrar
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        // Imagen de fondo
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: Image.network(
            _recipe.imagenes?.isNotEmpty == true
                ? 'http://localhost:3000/${_recipe.imagenes!.first}'
                : 'https://via.placeholder.com/800x300? text=Sin+imagen',
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[300],
                child: const Icon(Icons.restaurant, size: 64),
              );
            },
          ),
        ),

        // Degradado oscuro
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

        // Título sobre la imagen
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
    return Wrap(
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
    );
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

  // ✅ NUEVO: Sección de valoraciones
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

          // Valoración promedio
          Row(
            children: [
              const Text(
                'Promedio: ',
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

          // Valorar
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

  Widget _buildIngredients() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ingredientes',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._recipe.ingredientes.map((ingrediente) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.fiber_manual_record, size: 8),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    ingrediente,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
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
            // Aquí puedes abrir el enlace en un navegador
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
