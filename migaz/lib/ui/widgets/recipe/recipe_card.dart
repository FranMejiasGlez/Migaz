// lib/ui/widgets/recipe/recipe_card.dart
import 'package:flutter/material.dart';
import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/ui/widgets/recipe/rating_display.dart';
import 'package:migaz/ui/widgets/recipe/recipe_image_widget.dart';
import 'package:migaz/ui/widgets/comentarios/comentarios_popup.dart';
import 'package:provider/provider.dart';
import 'package:migaz/ui/widgets/auth/user_credentials.dart';

class RecipeCard extends StatelessWidget {
  final String nombre;
  final String categoria;
  final double valoracion;
  final int? cantidadVotos;
  final String? imageUrl;
  final int? cantidadComentarios; // ✅ NUEVO
  final Recipe recipe; // ✅ NUEVO:  Necesario para el popup
  final VoidCallback onTap;

  const RecipeCard({
    Key? key,
    required this.nombre,
    required this.categoria,
    required this.valoracion,
    this.cantidadVotos,
    this.imageUrl,
    this.cantidadComentarios, // ✅ NUEVO
    required this.recipe, // ✅ NUEVO
    required this.onTap,
  }) : super(key: key);

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
            // Imagen
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: SizedBox(
                height: 250,
                width: double.infinity,
                child: RecipeImageWidget(imageUrl: imageUrl, fit: BoxFit.cover),
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
                          nombre,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          categoria,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    // ✅ ACTUALIZADO: Rating y Comentarios
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Rating
                        RatingDisplay(
                          rating: valoracion,
                          totalVotes: cantidadVotos,
                          size: 14,
                          showNumber: true,
                          showVotes: false,
                        ),

                        // ✅ NUEVO: Botón de comentarios
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

  // ✅ NUEVO:  Botón de comentarios
  Widget _buildCommentButton(BuildContext context) {
    final comentariosCount = cantidadComentarios ?? recipe.comentarios.length;

    return InkWell(
      onTap: () => _showComments(context),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.comment_outlined, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              '$comentariosCount',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ NUEVO: Mostrar popup de comentarios
  void _showComments(BuildContext context) {
    final credentials = Provider.of<UserCredentials>(context, listen: false);
    final currentUser = credentials.email.isNotEmpty
        ? credentials.email
        : 'usuario_demo';

    ComentariosPopup.show(
      context: context,
      recipe: recipe,
      currentUserName: currentUser,
    );
  }
}
