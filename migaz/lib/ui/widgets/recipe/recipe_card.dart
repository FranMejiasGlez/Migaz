// lib/ui/widgets/recipe/recipe_card.dart
import 'package:flutter/material.dart';
import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/ui/widgets/recipe/rating_display.dart';
import 'package:migaz/ui/widgets/recipe/recipe_image_widget.dart';
import 'package:migaz/ui/widgets/comentarios/comentarios_popup.dart';
import 'package:provider/provider.dart';
import 'package:migaz/ui/widgets/auth/user_credentials.dart';
import 'package:migaz/viewmodels/home_viewmodel.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;

  const RecipeCard({Key? key, required this.recipe, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ NUEVO: Buscar la receta actualizada en el HomeViewModel
    return Consumer<HomeViewModel>(
      builder: (context, homeViewModel, child) {
        // Intentar encontrar la versión actualizada de la receta
        final recetaActualizada = homeViewModel.todasLasRecetas.firstWhere(
          (r) => r.id == recipe.id,
          orElse: () => recipe, // Si no se encuentra, usar la original
        );

        return _buildCard(context, recetaActualizada);
      },
    );
  }

  Widget _buildCard(BuildContext context, Recipe recetaActual) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 2),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: SizedBox(
                height: 250,
                width: double.infinity,
                child: RecipeImageWidget(
                  imageUrl: recetaActual.imagenes?.isNotEmpty == true
                      ? recetaActual.imagenes!.first
                      : null,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recetaActual.nombre,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          recetaActual.categoria,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ✅ ACTUALIZADO: Usa valoración actualizada
                        RatingDisplay(
                          rating: recetaActual.valoracion,
                          totalVotes: recetaActual.cantidadVotos,
                          size: 14,
                          showNumber: true,
                          showVotes: false,
                        ),

                        // ✅ ACTUALIZADO: Usa comentarios actualizados
                        _buildCommentButton(context, recetaActual),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentButton(BuildContext context, Recipe recetaActual) {
    final comentariosCount = recetaActual.comentarios.length;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          print('👆 CLICK en comentarios de:  ${recetaActual.nombre}');
          _showComments(context, recetaActual);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: comentariosCount > 0
                ? Colors.blue.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: comentariosCount > 0 ? Colors.blue : Colors.grey[400]!,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.comment,
                size: 18,
                color: comentariosCount > 0
                    ? Colors.blue[700]
                    : Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                '$comentariosCount',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: comentariosCount > 0
                      ? Colors.blue[700]
                      : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComments(BuildContext context, Recipe recetaActual) {
    final credentials = Provider.of<UserCredentials>(context, listen: false);
    final currentUser = credentials.email.isNotEmpty
        ? credentials.email.split('@').first
        : 'usuario_demo';

    ComentariosPopup.show(
      context: context,
      recipe: recetaActual,
      currentUserName: currentUser,
    );
  }
}
