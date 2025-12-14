import 'package:flutter/material.dart';
import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/ui/widgets/recipe/recipe_card.dart';
import 'package:migaz/ui/widgets/recipe/recipe_detail_dialog.dart';
// Asegúrate de importar tus utilidades responsive
import 'package:migaz/core/utils/responsive_breakpoints.dart';

class RecipeGridView extends StatelessWidget {
  final List<Recipe> recipes;
  final VoidCallback? onRefresh;
  final Widget? emptyWidget;

  const RecipeGridView({
    Key? key,
    required this.recipes,
    this.onRefresh,
    this.emptyWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Manejo de estado vacío
    if (recipes.isEmpty && emptyWidget != null) {
      return emptyWidget!;
    }

    // 2. Obtenemos las columnas y padding basados en tus Breakpoints
    final int crossAxisCount = ResponsiveBreakpoints.getGridColumns(context);
    final double horizontalPadding = ResponsiveBreakpoints.getHorizontalPadding(
      context,
    );

    // Contenido del Grid
    Widget gridContent = Center(
      child: ConstrainedBox(
        // 3. Limitamos el ancho máximo a 1200px (desktop) para que quede centrado
        // y no se estire excesivamente en monitores ultrawide.
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 16,
          ),
          child: GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            // Agregamos padding inferior para que el último elemento no quede pegado al borde/FAB
            padding: const EdgeInsets.only(bottom: 80),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  crossAxisCount, // Columnas dinámicas (1, 2, 3 o 4)
              crossAxisSpacing: 16, // Espaciado horizontal entre tarjetas
              mainAxisSpacing: 16, // Espaciado vertical entre tarjetas
              // 4. Relación de aspecto: 0.8 significa que el alto es un poco mayor que el ancho.
              // Ajusta este valor si tus tarjetas se ven muy cortadas o muy largas.
              // 0.75 = más alta | 0.85 = más cuadrada
              childAspectRatio: 0.8,
            ),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final receta = recipes[index];
              return RecipeCard(
                recipe: receta,
                onTap: () => RecipeDetailDialog.show(context, receta),
              );
            },
          ),
        ),
      ),
    );

    // 5. Envolver en RefreshIndicator si es necesario
    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: () async => onRefresh!(),
        child: gridContent,
      );
    }

    return gridContent;
  }
}
