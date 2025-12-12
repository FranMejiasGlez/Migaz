// lib/ui/widgets/recipe/recipe_grid_view.dart
import 'package:flutter/material.dart';
import 'package:migaz/core/constants/recipe_constants.dart';
import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/ui/widgets/recipe/recipe_card.dart';
import 'package:migaz/ui/widgets/recipe/recipe_detail_dialog.dart';

/// Widget unificado para mostrar recetas en grid
/// Uso: RecipeGridView(recipes: listaRecetas, onRefresh: metodoRefresh)
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
    // Mostrar widget vacío si no hay recetas
    if (recipes.isEmpty && emptyWidget != null) {
      return emptyWidget!;
    }

    Widget gridContent = LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final cardWidth = (screenWidth - 100) / 4;
        final cardHeight = cardWidth * 1.2;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: RecipeConstants.gridCrossAxisCount,
              crossAxisSpacing: RecipeConstants.gridCrossAxisSpacing,
              mainAxisSpacing: RecipeConstants.gridMainAxisSpacing,
              childAspectRatio: cardWidth / cardHeight,
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
        );
      },
    );

    // ✅ Envolver en RefreshIndicator si se proporciona onRefresh
    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: () async => onRefresh!(),
        child: gridContent,
      );
    }

    return gridContent;
  }
}