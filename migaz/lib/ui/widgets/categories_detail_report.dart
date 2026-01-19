import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:migaz/core/utils/responsive_helper.dart';
import 'package:migaz/viewmodels/report_viewmodel.dart';
import 'package:provider/provider.dart';

class CategoriesDetailReport extends StatefulWidget {
  final ResponsiveHelper responsive;
  
  const CategoriesDetailReport({
    Key? key,
    required this.responsive,
  }) : super(key: key);

  @override
  State<CategoriesDetailReport> createState() => _CategoriesDetailReportState();
}

class _CategoriesDetailReportState extends State<CategoriesDetailReport> {
  final Map<String, bool> _expandedCategories = {};

  // Paleta de colores Premium
  final Color _primaryColor = const Color(0xFF5B8DEE);
  final Color _accentColor = const Color(0xFF25CCAD);
  final Color _warningColor = const Color(0xFFEA7317);
  final Color _cardColor = Colors.white;
  final Color _backgroundColor = const Color(0xFFF5F7FA);

  @override
  Widget build(BuildContext context) {
    final reportVM = context.watch<ReportViewModel>();
    final data = reportVM.categoriesDetailedReport;
    final r = widget.responsive;

    return Container(
      color: _backgroundColor,
      child: Column( // Changed to Column for intrinsic height
        children: [
          // --- MAIN HEADER CARD ---
          _buildReportHeader(r),
          
          SizedBox(height: 20 * r.scale),
          
          // --- CONTENT (Category Groups) ---
          if (data.isEmpty)
             _buildEmptyState(r)
          else
            ...data.map((catData) => _buildCategoryCard(catData, r)).toList(),
            
          SizedBox(height: 24 * r.scale),
          
          // --- SUMMARY FOOTER CARD ---
          _buildSummaryFooter(reportVM, r),
          
          SizedBox(height: 32 * r.scale), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildReportHeader(ResponsiveHelper r) {
    final now = DateTime.now();
    // Use the exact date of viewing
    final formattedDate = DateFormat('dd/MM/yyyy').format(now);

    return Container(
      padding: EdgeInsets.all(24 * r.scale),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, _primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // APP LOGO from Login Screen
              Container(
                width: 60 * r.scale, // Adjusted size
                height: 60 * r.scale,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white, // White background for the logo
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://raw.githubusercontent.com/FranMejiasGlez/TallerFlutter/main/sandbox_fran/imperativo/img/Logo.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'REPORTE DE INVENTARIO',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 10 * r.scale,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4 * r.scale),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16 * r.scale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Fecha de generación',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 10 * r.scale,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16 * r.scale),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Categorías Populares',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24 * r.scale,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(CategoryReportData catData, ResponsiveHelper r) {
    final isExpanded = _expandedCategories[catData.categoryName] ?? false; // Default collapsed for cleaner look

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 16 * r.scale),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // --- GROUP HEADER ---
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: isExpanded ? Radius.zero : const Radius.circular(16),
              bottomRight: isExpanded ? Radius.zero : const Radius.circular(16),
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  _expandedCategories[catData.categoryName] = !isExpanded;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: EdgeInsets.all(16 * r.scale),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10 * r.scale),
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        color: _primaryColor,
                        size: 20 * r.scale,
                      ),
                    ),
                    SizedBox(width: 16 * r.scale),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            catData.categoryName,
                            style: TextStyle(
                              fontSize: 16 * r.scale,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D3748),
                            ),
                          ),
                          Text(
                            '${catData.totalRecipes} Recetas',
                            style: TextStyle(
                              fontSize: 12 * r.scale,
                              color: const Color(0xFF718096),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Rating Badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12 * r.scale, vertical: 6 * r.scale),
                      decoration: BoxDecoration(
                        color: _getRatingColor(catData.averageRating).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _getRatingColor(catData.averageRating).withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star_rounded, size: 16 * r.scale, color: _getRatingColor(catData.averageRating)),
                          SizedBox(width: 4 * r.scale),
                          Text(
                            catData.averageRating.toStringAsFixed(1),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12 * r.scale,
                              color: _getRatingColor(catData.averageRating),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- CONTENT AREA ---
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                
                // --- RECIPE LIST ---
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: catData.recipes.length,
                  separatorBuilder: (c, i) => Divider(height: 1, indent: 20 * r.scale, endIndent: 20 * r.scale, color: Colors.grey.withOpacity(0.05)),
                  itemBuilder: (context, index) {
                    final recipe = catData.recipes[index];
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20 * r.scale, vertical: 4 * r.scale),
                      leading: Container(
                        width: 40 * r.scale,
                        height: 40 * r.scale,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            (index + 1).toString(),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.bold,
                              fontSize: 12 * r.scale
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        recipe.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14 * r.scale,
                          color: const Color(0xFF4A5568),
                        ),
                      ),
                      subtitle: Text(
                        'Alta: ${DateFormat('dd/MM/yyyy').format(recipe.createdAt)}',
                        style: TextStyle(
                          fontSize: 12 * r.scale,
                          color: const Color(0xFFA0AEC0),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rate_rounded, color: const Color(0xFFFFC107), size: 16 * r.scale),
                          SizedBox(width: 4 * r.scale),
                          Text(
                            recipe.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13 * r.scale,
                              color: const Color(0xFF4A5568),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                // --- FOOTER SUMMARY ---
                Padding(
                  padding: EdgeInsets.all(16 * r.scale),
                  child: Container(
                    padding: EdgeInsets.all(12 * r.scale),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Promedio Categoría',
                          style: TextStyle(
                            fontSize: 12 * r.scale,
                            fontWeight: FontWeight.w500,
                            color: _primaryColor,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              catData.averageRating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 16 * r.scale,
                                fontWeight: FontWeight.bold,
                                color: _primaryColor,
                              ),
                            ),
                            Icon(Icons.analytics_outlined, color: _primaryColor, size: 16 * r.scale),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryFooter(ReportViewModel vm, ResponsiveHelper r) {
    return Container(
      padding: EdgeInsets.all(20 * r.scale),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3748), // Dark sleek footer
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D3748).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RESUMEN GLOBAL',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12 * r.scale,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20 * r.scale),
          Row(
            children: [
              Expanded(
                child: _buildFooterStat(
                  r, 
                  'Total Recetas', 
                  '${vm.recetasTotales}', 
                  Icons.restaurant_menu_rounded,
                  Colors.white,
                ),
              ),
              Container(width: 1, height: 40 * r.scale, color: Colors.white.withOpacity(0.1)),
              Expanded(
                child: _buildFooterStat(
                  r, 
                  'Mejor Categoría', 
                  vm.bestRatedCategory.isEmpty ? '-' : vm.bestRatedCategory, 
                  Icons.emoji_events_rounded,
                  const Color(0xFFFFC107),
                  subValue: vm.bestRatedCategoryScore > 0 ? '★ ${vm.bestRatedCategoryScore.toStringAsFixed(1)}' : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterStat(
    ResponsiveHelper r, 
    String label, 
    String value, 
    IconData icon, 
    Color color,
    {String? subValue}
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24 * r.scale),
        SizedBox(height: 8 * r.scale),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18 * r.scale,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (subValue != null)
           Text(
            subValue,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 12 * r.scale,
              fontWeight: FontWeight.w500,
            ),
          )
        else
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 10 * r.scale,
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(ResponsiveHelper r) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.assignment_outlined, size: 48 * r.scale, color: Colors.grey.shade300),
          SizedBox(height: 16 * r.scale),
          Text(
            'No hay datos disponibles',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return const Color(0xFF38A169); // Green
    if (rating >= 4.0) return const Color(0xFF3182CE); // Blue
    if (rating >= 3.0) return const Color(0xFFDD6B20); // Orange
    return const Color(0xFFE53E3E); // Red
  }
}
