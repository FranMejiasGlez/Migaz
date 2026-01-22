import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:migaz/core/utils/responsive_helper.dart';
import 'package:migaz/viewmodels/report_viewmodel.dart';
import 'package:provider/provider.dart';

/// Widget para mostrar categorías más populares (Admin)
class AdminCategoriesReport extends StatelessWidget {
  final ResponsiveHelper responsive;
  
  const AdminCategoriesReport({
    super.key,
    required this.responsive,
  });

  static const Color _primaryColor = Color(0xFF9F7AEA); // Purple for categories
  static const Color _backgroundColor = Color(0xFFF5F7FA);
  static const Color _cardColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    final reportVM = context.watch<ReportViewModel>();
    final r = responsive;

    return Container(
      color: _backgroundColor,
      child: Column(
        children: [
          _buildHeader(r),
          SizedBox(height: 20 * r.scale),
          _buildPopularCategoriesSection(reportVM, r),
          SizedBox(height: 32 * r.scale),
        ],
      ),
    );
  }

  Widget _buildHeader(ResponsiveHelper r) {
    final now = DateTime.now();
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
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * r.scale,
                  vertical: 6 * r.scale,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings, color: Colors.white, size: 18 * r.scale),
                    SizedBox(width: 6 * r.scale),
                    Text(
                      'ADMIN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12 * r.scale,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formattedDate,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16 * r.scale,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * r.scale),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Categorías Más Populares',
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

  Widget _buildPopularCategoriesSection(ReportViewModel vm, ResponsiveHelper r) {
    final categories = vm.categoriasPopulares.entries.toList();
    final maxCount = categories.isNotEmpty
        ? categories.map((e) => e.value).reduce((a, b) => a > b ? a : b)
        : 1;

    return Container(
      padding: EdgeInsets.all(20 * r.scale),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8 * r.scale),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.category_rounded, color: _primaryColor, size: 20 * r.scale),
              ),
              SizedBox(width: 12 * r.scale),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ranking de Categorías',
                    style: TextStyle(
                      fontSize: 16 * r.scale,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                  Text(
                    'Por número de recetas',
                    style: TextStyle(fontSize: 12 * r.scale, color: const Color(0xFF718096)),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20 * r.scale),
          if (categories.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20 * r.scale),
                child: Text(
                  'Sin datos de categorías',
                  style: TextStyle(color: Colors.grey, fontSize: 14 * r.scale),
                ),
              ),
            )
          else
            ...categories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              final percentage = (category.value / maxCount) * 100;
              
              return Padding(
                padding: EdgeInsets.only(bottom: 12 * r.scale),
                child: _buildCategoryBar(
                  r,
                  rank: index + 1,
                  name: category.key,
                  count: category.value,
                  percentage: percentage,
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildCategoryBar(
    ResponsiveHelper r, {
    required int rank,
    required String name,
    required int count,
    required double percentage,
  }) {
    final colors = [
      const Color(0xFFEA7317),
      const Color(0xFF5B8DEE),
      const Color(0xFF25CCAD),
      const Color(0xFF9F7AEA),
      const Color(0xFFED64A6),
      const Color(0xFFE53E3E),
      const Color(0xFF38B2AC),
      const Color(0xFFD69E2E),
    ];
    final color = colors[(rank - 1) % colors.length];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28 * r.scale,
              height: 28 * r.scale,
              decoration: BoxDecoration(
                color: rank <= 3 ? color : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: rank <= 3
                    ? Icon(Icons.emoji_events, color: Colors.white, size: 16 * r.scale)
                    : Text(
                        '$rank',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                          fontSize: 12 * r.scale,
                        ),
                      ),
              ),
            ),
            SizedBox(width: 12 * r.scale),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 14 * r.scale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4A5568),
                ),
              ),
            ),
            Text(
              '$count recetas',
              style: TextStyle(
                fontSize: 13 * r.scale,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 8 * r.scale),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6 * r.scale,
          ),
        ),
      ],
    );
  }
}
