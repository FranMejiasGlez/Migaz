import 'package:flutter/material.dart';
import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/ui/widgets/auth/user_credentials.dart';
import 'package:migaz/ui/widgets/comentarios/comentarios_popup.dart';
import 'package:migaz/ui/widgets/recipe/recipe_image_widget.dart';
import 'package:provider/provider.dart';

class RecipeDetailDialog extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailDialog({Key? key, required this.recipe}) : super(key: key);

  /// Método estático para mostrar el diálogo fácilmente
  static void show(BuildContext context, Recipe recipe) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return RecipeDetailDialog(recipe: recipe);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGEN DE LA RECETA
              RecipeImageWidget(
                recipe: recipe,
                width: 250,
                height: 200,
                borderRadius: 12,
              ),
              const SizedBox(height: 16),

              // NOMBRE
              Text(
                recipe.nombre,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // DESCRIPCIÓN
              if (recipe.descripcion.isNotEmpty)
                Text(
                  recipe.descripcion,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              const SizedBox(height: 16),

              // INFO CONTAINER
              _buildInfoContainer(),

              // INGREDIENTES
              if (recipe.ingredientes.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSectionTitle('Ingredientes'),
                const SizedBox(height: 8),
                _buildIngredientsList(),
              ],

              // PASOS
              if (recipe.pasos.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSectionTitle('Pasos'),
                const SizedBox(height: 8),
                _buildStepsList(),
              ],

              const SizedBox(height: 16),

              // BOTONES
              _buildCommentsButton(context),
              const SizedBox(height: 16),
              _buildCloseButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoContainer() {
    return Container(
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
              _buildInfoItem(
                icon: Icons.schedule,
                label: 'Tiempo',
                value: recipe.tiempo,
              ),
              _buildInfoItem(
                icon: Icons.star,
                label: 'Dificultad',
                value: recipe.dificultadTexto,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                icon: Icons.people,
                label: 'Comensales',
                value: '${recipe.comensales}',
              ),
              _buildInfoItem(
                icon: Icons.restaurant,
                label: 'Categoría',
                value: recipe.categoria,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
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
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildIngredientsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: recipe.ingredientes
          .map(
            (ingrediente) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 6, color: Colors.teal),
                  const SizedBox(width: 8),
                  Expanded(child: Text(ingrediente)),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildStepsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        recipe.pasos.length,
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
              Expanded(child: Text(recipe.pasos[index])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentsButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        final userCred = Provider.of<UserCredentials>(context, listen: false);

        String currentUserName = 'Usuario';
        if (userCred.email.isNotEmpty && userCred.email.contains('@')) {
          currentUserName = userCred.email.split('@')[0];
        }

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (ctx) => ComentariosPopup(
            recipe: recipe,
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
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text('Cerrar', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
