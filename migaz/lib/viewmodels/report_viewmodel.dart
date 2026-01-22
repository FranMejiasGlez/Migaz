// lib/viewmodels/report_viewmodel.dart
import 'package:migaz/data/services/report_service.dart';
import 'package:migaz/data/services/guardados_service.dart';
import 'package:migaz/data/services/pdf_report_service.dart';
import 'package:migaz/viewmodels/base_viewmodel.dart';

class ReportViewModel extends BaseViewModel {
  final ReportService _reportService = ReportService();
  final GuardadosService _guardadosService = GuardadosService();
  final PdfReportService _pdfService = PdfReportService();

  // Datos del usuario
  int _seguidores = 0;
  int _seguidos = 0;
  int _misRecetas = 0;
  int _recetasGuardadas = 0;
  String _currentUserName = '';

  // Datos de red (Listas completas)
  List<dynamic> _listaSeguidores = [];
  List<dynamic> _listaSeguidos = [];

  // Datos globales
  int _recetasTotales = 0;
  int _usuariosTotales = 0;
  Map<String, int> _recetasPorMes = {};
  Map<String, int> _usuariosPorMes = {};
  Map<String, int> _categoriasPopulares = {};
  
  // Detailed report data
  List<CategoryReportData> _categoriesDetailedReport = [];
  String _bestRatedCategory = '';
  double _bestRatedCategoryScore = 0.0;

  // Getters
  int get seguidores => _seguidores;
  int get seguidos => _seguidos;
  int get misRecetas => _misRecetas;
  int get recetasGuardadas => _recetasGuardadas;
  List<dynamic> get listaSeguidores => _listaSeguidores;
  List<dynamic> get listaSeguidos => _listaSeguidos;
  String get currentUserName => _currentUserName;
  int get recetasTotales => _recetasTotales;
  int get usuariosTotales => _usuariosTotales;
  Map<String, int> get recetasPorMes => _recetasPorMes;
  Map<String, int> get usuariosPorMes => _usuariosPorMes;
  Map<String, int> get categoriasPopulares => _categoriasPopulares;
  
  // New computed property for detailed report
  List<CategoryReportData> get categoriesDetailedReport => _categoriesDetailedReport;
  String get bestRatedCategory => _bestRatedCategory;
  double get bestRatedCategoryScore => _bestRatedCategoryScore;

  // Cookbook Data
  List<CookbookReportData> _cookbookReport = [];
  List<CookbookReportData> get cookbookReport => _cookbookReport;
  int _totalImpact = 0; // Total times my recipes were saved (placeholder)
  int get totalImpact => _totalImpact;

  /// Cargar todas las estadísticas del usuario
  Future<void> cargarEstadisticasUsuario(String userId, String username) async {
    _currentUserName = username;
    await runAsync(() async {
      // 1. Cargar perfil del usuario (seguidores/seguidos)
      final perfil = await _reportService.obtenerPerfilUsuario(userId);
      if (perfil != null) {
        _seguidores = (perfil['seguidores'] as List?)?.length ?? 0;
        _seguidos = (perfil['siguiendo'] as List?)?.length ?? 0;
        
        // Guardar listas completas
        _listaSeguidores = (perfil['seguidores'] as List?) ?? [];
        _listaSeguidos = (perfil['siguiendo'] as List?) ?? [];
      }

      // 2. Cargar todas las recetas para estadísticas
      final todasRecetas = await _reportService.obtenerTodasRecetas();
      _recetasTotales = todasRecetas.length;

      // 3. Filtrar mis recetas
      final misRecetasList = todasRecetas.where((r) {
        final user = r['user'];
        if (user is Map) {
          return user['_id'] == userId || user['username'] == username;
        }
        return user?.toString() == userId || user?.toString() == username;
      }).toList();
      _misRecetas = misRecetasList.length;

      // 4. Cargar recetas guardadas
      final guardadasIds = await _guardadosService.obtenerGuardadas(username);
      _recetasGuardadas = guardadasIds.length;

      // 5. Calcular recetas por mes
      _recetasPorMes = _reportService.calcularRecetasPorMes(todasRecetas);

      // 6. Calcular categorías populares
      _categoriasPopulares = _reportService.calcularCategoriasPopulares(todasRecetas);
      
      // 7. Calcular reporte detallado (Categorías Populares)
      _calcularReporteDetallado(todasRecetas);
      
      // 8. Calcular reporte Cookbook (Mis recetas + Guardadas)
      // Usamos el nuevo endpoint de estadísticas
      final estadisticasGuardados = await _reportService.obtenerEstadisticasGuardados();
      _calcularCookbookReport(todasRecetas, userId, username, guardadasIds, estadisticasGuardados);

      return true;
    });
  }

  /// Cargar estadísticas de admin (usuarios)
  Future<void> cargarEstadisticasAdmin() async {
    await runAsync(() async {
      // Cargar todos los usuarios
      final usuarios = await _reportService.obtenerTodosUsuarios();
      _usuariosTotales = usuarios.length;
      
      // Calcular usuarios por mes
      _usuariosPorMes = _reportService.calcularUsuariosPorMes(usuarios);

      return true;
    });
  }

  /// Cargar todo (usuario + admin)
  Future<void> cargarTodo(String userId, String username, {bool isAdmin = false}) async {
    await cargarEstadisticasUsuario(userId, username);
    if (isAdmin) {
      await cargarEstadisticasAdmin();
    }
  }

  /// Exportar las estadísticas actuales a PDF
  Future<void> exportToPdf({bool isAdmin = false}) async {
    print('DEBUG: ReportViewModel.exportToPdf called, isAdmin=$isAdmin');
    await runAsync(() async {
      await _pdfService.generateAndDisplayReport(this, isAdmin: isAdmin);
      return true;
    });
  }
  
  void _calcularReporteDetallado(List<dynamic> todasRecetas) {
    final Map<String, List<RecipeReportItem>> grouped = {};
    
    // Group recipes by category
    for (var receta in todasRecetas) {
      final categoria = receta['categoria']?.toString() ?? 'Sin categoría';
      final categoriaCapitalized = categoria.isNotEmpty 
          ? categoria[0].toUpperCase() + categoria.substring(1)
          : 'Sin categoría';
          
      if (!grouped.containsKey(categoriaCapitalized)) {
        grouped[categoriaCapitalized] = [];
      }
      
      // Parse data
      final createdAtStr = receta['createdAt'];
      final fecha = createdAtStr != null 
          ? DateTime.tryParse(createdAtStr.toString()) ?? DateTime.now()
          : DateTime.now();
          
      // Check for rating fields (flexible handling)
      double rating = 0.0;
      if (receta['promedio'] != null) {
        rating = double.tryParse(receta['promedio'].toString()) ?? 0.0;
      } else if (receta['rating'] != null) {
        rating = double.tryParse(receta['rating'].toString()) ?? 0.0;
      }

      // Check for difficulty
      int difficulty = 1;
      if (receta['dificultad'] != null) {
        difficulty = int.tryParse(receta['dificultad'].toString()) ?? 1;
      }

      grouped[categoriaCapitalized]!.add(
        RecipeReportItem(
          id: receta['_id']?.toString() ?? '',
          title: receta['nombre']?.toString() ?? 'Sin título',
          createdAt: fecha,
          rating: rating,
          difficulty: difficulty,
        )
      );
    }
    
    // Create report data objects
    final List<CategoryReportData> reportList = [];
    String bestCat = '';
    double bestScore = -1.0;
    
    grouped.forEach((category, recipes) {
      // Sort recipes by date descending (newest first)
      recipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // Calculate avg for category
      double totalRating = 0;
      for (var r in recipes) {
        totalRating += r.rating;
      }
      final avgRating = recipes.isNotEmpty ? totalRating / recipes.length : 0.0;
      
      if (avgRating > bestScore) {
        bestScore = avgRating;
        bestCat = category;
      }
      
      reportList.add(CategoryReportData(
        categoryName: category,
        recipes: recipes,
        totalRecipes: recipes.length,
        averageRating: avgRating,
      ));
    });
    
    // Sort categories by popularity (count) or rating? 
    // Wireframe implies "Categorías más populares", so sort by count desc
    reportList.sort((a, b) => b.totalRecipes.compareTo(a.totalRecipes));
    
    _categoriesDetailedReport = reportList;
    _bestRatedCategory = bestCat; 
    _bestRatedCategoryScore = bestScore;
  }

  void _calcularCookbookReport(
    List<dynamic> todasRecetas, 
    String userId, 
    String username,
    List<String> guardadasIds,
    Map<String, int> estadisticasGuardados,
  ) {
    final Map<String, List<RecipeReportItem>> grouped = {};
    
    // Filter recipes: EITHER created by me OR in my saved list
    final filteredRecetas = todasRecetas.where((r) {
      final rId = r['_id']?.toString() ?? '';
      
      // Check if created by me
      final user = r['user'];
      bool isMine = false;
      if (user is Map) {
        isMine = user['_id'] == userId || user['username'] == username;
      } else {
        isMine = user?.toString() == userId || user?.toString() == username;
      }
      
      // Check if saved
      final isSaved = guardadasIds.contains(rId);
      
      return isMine || isSaved;
    }).toList();

    for (var receta in filteredRecetas) {
      final rId = receta['_id']?.toString() ?? '';
      final categoria = receta['categoria']?.toString() ?? 'Sin categoría';
      final categoriaCapitalized = categoria.isNotEmpty 
          ? categoria[0].toUpperCase() + categoria.substring(1)
          : 'Sin categoría';
          
      if (!grouped.containsKey(categoriaCapitalized)) {
        grouped[categoriaCapitalized] = [];
      }
      
      final createdAtStr = receta['createdAt'];
      final fecha = createdAtStr != null 
          ? DateTime.tryParse(createdAtStr.toString()) ?? DateTime.now()
          : DateTime.now();
          
      double rating = 0.0;
      if (receta['promedio'] != null) {
        rating = double.tryParse(receta['promedio'].toString()) ?? 0.0;
      } else if (receta['rating'] != null) {
        rating = double.tryParse(receta['rating'].toString()) ?? 0.0;
      }

      int difficulty = 1;
      if (receta['dificultad'] != null) {
         difficulty = int.tryParse(receta['dificultad'].toString()) ?? 1;
      }
      
      // Calculate Saved Count
      // Use the map fetched from backend
      int savedCount = estadisticasGuardados[rId] ?? 0;
      
      // Determine if it is my recipe
      bool isMineRecipe = false;
      final user = receta['user'];
      if (user is Map) {
        isMineRecipe = user['_id'] == userId || user['username'] == username;
      } else {
        isMineRecipe = user?.toString() == userId || user?.toString() == username;
      }
      
      grouped[categoriaCapitalized]!.add(
        RecipeReportItem(
          id: rId,
          title: receta['nombre']?.toString() ?? 'Sin título',
          createdAt: fecha,
          rating: rating,
          difficulty: difficulty,
          savedCount: savedCount,
          isMine: isMineRecipe, // Populate new field
        )
      );
    }
    
    final List<CookbookReportData> reportList = [];
    int totalImpactSum = 0;
    
    grouped.forEach((category, recipes) {
      recipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      double totalRating = 0;
      for (var r in recipes) {
        totalRating += r.rating;
        // Only count impact for MY recipes if we wanted strictly "my impact"
        // But user asked for "number of times saved" in the report column for each recipe.
        // totalImpact usually implies effectiveness of my creations.
        if (r.savedCount != null) {
           totalImpactSum += r.savedCount!;
        }
      }
      final avgRating = recipes.isNotEmpty ? totalRating / recipes.length : 0.0;
      
      reportList.add(CookbookReportData(
        categoryName: category,
        recipes: recipes,
        totalRecipes: recipes.length,
        totalSaved: recipes.length, // Total recipes in this category
        averageRating: avgRating,
      ));
    });
    
    reportList.sort((a, b) => b.totalRecipes.compareTo(a.totalRecipes));
    _cookbookReport = reportList;
    _totalImpact = totalImpactSum; 
  }
}

class CategoryReportData {
  final String categoryName;
  final List<RecipeReportItem> recipes;
  final int totalRecipes;
  final double averageRating;
  
  CategoryReportData({
    required this.categoryName,
    required this.recipes,
    required this.totalRecipes,
    required this.averageRating,
  });
}

class RecipeReportItem {
  final String id;
  final String title;
  final DateTime createdAt;
  final double rating;
  final int difficulty; // Added
  final int? savedCount; // Added (placeholder for now)
  final bool isMine; // Added for UI differentiation
  
  RecipeReportItem({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.rating,
    this.difficulty = 1,
    this.savedCount,
    this.isMine = false,
  });
}

class CookbookReportData {
  final String categoryName;
  final List<RecipeReportItem> recipes;
  final int totalRecipes;
  final int totalSaved; // How many are saved recipes (not my own)
  final double averageRating;

  CookbookReportData({
    required this.categoryName,
    required this.recipes,
    required this.totalRecipes,
    required this.totalSaved,
    required this.averageRating,
  });
}
