// lib/ui/widgets/recipe/recipe_search_section.dart
import 'package:flutter/material.dart';
import 'package:migaz/ui/widgets/recipe/recipe_filter_dropdown.dart';
import 'package:migaz/ui/widgets/recipe/recipe_search_bar.dart';
import 'package:migaz/data/services/categoria_service.dart';

class RecipeSearchSection extends StatefulWidget {
  final TextEditingController searchController;
  final String selectedFilter;
  final Function(String) onSearchChanged;
  final Function() onClearSearch;
  final Function(String?) onFilterChanged;
  final bool showClearButton;

  const RecipeSearchSection({
    Key? key,
    required this.searchController,
    required this.selectedFilter,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onFilterChanged,
    required this.showClearButton,
  }) : super(key: key);

  @override
  State<RecipeSearchSection> createState() => _RecipeSearchSectionState();
}

class _RecipeSearchSectionState extends State<RecipeSearchSection> {
  final CategoriaService _categoriaService = CategoriaService();
  List<String> _categories = ['Todos'];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    try {
      final categorias = await _categoriaService.obtenerCategorias();
      setState(() {
        _categories = categorias;
        _isLoadingCategories = false;
      });
    } catch (e) {
      print('❌ Error al cargar categorías: $e');
      setState(() {
        _categories = ['Todos']; // Fallback
        _isLoadingCategories = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Dropdown de categorías
          _isLoadingCategories
              ? const SizedBox(
                  height: 45,
                  child: Center(child: CircularProgressIndicator()),
                )
              : RecipeFilterDropdown(
                  value: widget.selectedFilter,
                  categories: _categories,
                  onChanged: widget.onFilterChanged,
                ),
          const SizedBox(height: 12),
          // Barra de búsqueda
          RecipeSearchBar(
            controller: widget.searchController,
            onChanged: widget.onSearchChanged,
            onClear: widget.onClearSearch,
            showClearButton: widget.showClearButton,
          ),
        ],
      ),
    );
  }
}