import 'package:flutter/material.dart';
import 'package:migaz/ui/widgets/recipe/recipe_filter_dropdown.dart';
import 'package:migaz/ui/widgets/recipe/recipe_search_bar.dart';

class RecipeSearchSection extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedFilter;
  final List<String> categories;
  final Function(String) onSearchChanged;
  final Function() onClearSearch;
  final Function(String?) onFilterChanged;
  final bool showClearButton;

  const RecipeSearchSection({
    Key? key,
    required this.searchController,
    required this.selectedFilter,
    required this.categories,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onFilterChanged,
    required this.showClearButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          RecipeFilterDropdown(
            value: selectedFilter,
            categories: categories,
            onChanged: onFilterChanged,
          ),
          const SizedBox(height: 12),
          RecipeSearchBar(
            controller: searchController,
            onChanged: onSearchChanged,
            onClear: onClearSearch,
            showClearButton: showClearButton,
          ),
        ],
      ),
    );
  }
}
