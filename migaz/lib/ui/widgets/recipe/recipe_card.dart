import 'package:flutter/material.dart';
import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/ui/widgets/recipe/rating_display.dart';
import 'package:migaz/ui/widgets/recipe/recipe_image_widget.dart';
import 'package:migaz/ui/widgets/comentarios/comentarios_popup.dart';
import 'package:provider/provider.dart';
import 'package:migaz/ui/widgets/auth/user_credentials.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe; // ✅ Solo el objeto completo
  final VoidCallback? onTap; // ✅ Opcional

  const RecipeCard({Key? key, required this.recipe, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            // ✅ Imagen real de la receta
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: SizedBox(
                height: 250,
                width: double.infinity,
                child: RecipeImageWidget(
                  imageUrl: recipe.imagenes?.isNotEmpty == true
                      ? recipe.imagenes!.first
                      : null,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Contenido
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Título y categoría
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.nombre,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          recipe.categoria,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    // ✅ Rating y Comentarios
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Rating con estrellas
                        RatingDisplay(
                          rating: recipe.valoracion,
                          totalVotes: recipe.cantidadVotos,
                          size: 14,
                          showNumber: true,
                          showVotes: false,
                        ),

                        // ✅ Botón de comentarios
                        _buildCommentButton(context),
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

  // En recipe_card.dart, actualiza _buildCommentButton
  Widget _buildCommentButton(BuildContext context) {
    final comentariosCount = recipe.comentarios.length;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          print('👆 CLICK en comentarios de:  ${recipe.nombre}');
          _showComments(context);
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

  // ✅ Mostrar popup de comentarios
  void _showComments(BuildContext context) {
    final credentials = Provider.of<UserCredentials>(context, listen: false);
    final currentUser = credentials.email.isNotEmpty
        ? credentials.email
              .split('@')
              .first // Usar parte antes del @
        : 'usuario_demo';

    ComentariosPopup.show(
      context: context,
      recipe: recipe,
      currentUserName: currentUser,
    );
  }
}
