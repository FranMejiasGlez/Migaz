import 'package:flutter/material.dart';

class RecipeFilterDropdown extends StatelessWidget {
  final String value;
  final List<String> categories;
  final ValueChanged<String?> onChanged;

  const RecipeFilterDropdown({
    Key? key,
    required this.value,
    required this.categories,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150, // ✅ Aumentado de 110 a 150
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButton<String>(
          value: value,
          isExpanded: true, // ✅ Cambiado a true para que ocupe todo el ancho
          underline: const SizedBox(),
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            overflow: TextOverflow.ellipsis, // ✅ Añadido para truncar texto largo
          ),
          items: categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(
                category == 'Todos' ? 'Filtrar' : category,
                overflow: TextOverflow.ellipsis, // ✅ Truncar con puntos suspensivos
                maxLines: 1, // ✅ Una sola línea
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}