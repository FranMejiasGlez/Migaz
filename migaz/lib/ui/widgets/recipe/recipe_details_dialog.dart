import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/ui/widgets/comentarios/comentarios_popup.dart';
import 'package:migaz/ui/widgets/auth/user_credentials.dart';

class RecipeDetailsDialog extends StatelessWidget {
  final Recipe recipe;
  final String? currentUserName;
  final void Function()? onClose;
  final void Function()? onOpenedComentarios;

  const RecipeDetailsDialog({
    Key? key,
    required this.recipe,
    this.currentUserName,
    this.onClose,
    this.onOpenedComentarios,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Si no se pasa username, intentar obtenerlo del provider UserCredentials
    final userCred = Provider.of<UserCredentials?>(context, listen: false);
    final userName =
        currentUserName ??
        (userCred != null && userCred.email.isNotEmpty
            ? userCred.email.split('@')[0]
            : '');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 250,
                      height: 200,
                      child: Image.network(recipe.imageUrl!, fit: BoxFit.cover),
                    ),
                  ),
                )
              else
                SizedBox(
                  width: 250,
                  height: 200,
                  child: Image.network(
                    "https://assets.tmecosys.com/image/upload/t_web_rdp_recipe_584x480_1_5x/img/recipe/ras/Assets/4ADF5D92-29D0-4EB7-8C8B-5C7DAA0DA74A/Derivates/E5E1004A-1FF0-448B-87AF-31393870B653.jpg",
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                recipe.nombre,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (recipe.descripcion.isNotEmpty)
                Text(
                  recipe.descripcion,
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
                          valor: recipe.tiempo,
                        ),
                        _infoItem(
                          icon: Icons.star,
                          label: 'Dificultad',
                          valor: recipe.dificultad,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _infoItem(
                          icon: Icons.people,
                          label: 'Servings',
                          valor: '${recipe.servings}',
                        ),
                        _infoItem(
                          icon: Icons.restaurant,
                          label: 'Categoría',
                          valor: recipe.categoria,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (recipe.ingredientes.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Ingredientes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: recipe.ingredientes
                      .map(
                        (i) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.circle,
                                size: 6,
                                color: Colors.teal,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(i)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              if (recipe.pasos.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Pasos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Column(
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
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Abrir comentarios como bottom sheet
                      onOpenedComentarios?.call();
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => ComentariosPopup(
                          recipe: recipe,
                          currentUserName: userName,
                          onAddComentario: (comentario) {
                            // Si quieres persistir al servidor, añade lógica aquí (o pasa callback desde afuera)
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.comment),
                    label: const Text('Comentarios'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onClose?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
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
}
