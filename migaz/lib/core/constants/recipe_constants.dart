class RecipeConstants {
  // Categorías disponibles
  static const List<String> categories = [
    'Todos',
    'Española',
    'Italiana',
    'Japonesa',
    'Mexicana',
  ];

  // Dificultades
  static const List<Map<String, dynamic>> dificultades = [
    {'value': 1, 'label': 'Muy Fácil', 'emoji': '⭐'},
    {'value': 2, 'label': 'Fácil', 'emoji': '⭐⭐'},
    {'value': 3, 'label': 'Medio', 'emoji': '⭐⭐⭐'},
    {'value': 4, 'label': 'Difícil', 'emoji': '⭐⭐⭐⭐'},
    {'value': 5, 'label': 'Muy Difícil', 'emoji': '⭐⭐⭐⭐⭐'},
  ];

  // Obtener labels de dificultades
  static List<String> get dificultadLabels =>
      dificultades.map((d) => d['label'] as String).toList();

  // URL de avatar por defecto
  static const String defaultAvatarUrl =
      'https://raw.githubusercontent.com/FranMejiasGlez/TallerFlutter/main/sandbox_fran/imperativo/img/Logo. png';

  // Estilos de botones
  static const double buttonBorderRadius = 12.0;
  static const double buttonElevation = 5.0;

  // Configuración de grid
  static const int gridCrossAxisCount = 4;
  static const double gridCrossAxisSpacing = 12.0;
  static const double gridMainAxisSpacing = 12.0;
}
