import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:migaz/core/utils/responsive_helper.dart';
import 'package:migaz/viewmodels/report_viewmodel.dart';
import 'package:provider/provider.dart';

class AdminDetailReport extends StatelessWidget {
  final ResponsiveHelper responsive;
  
  const AdminDetailReport({
    Key? key,
    required this.responsive,
  }) : super(key: key);

  // Premium color palette
  static const Color _primaryColor = Color(0xFFEA7317); // Orange for admin
  static const Color _accentColor = Color(0xFF5B8DEE);
  static const Color _successColor = Color(0xFF25CCAD);
  static const Color _cardColor = Colors.white;
  static const Color _backgroundColor = Color(0xFFF5F7FA);

  @override
  Widget build(BuildContext context) {
    final reportVM = context.watch<ReportViewModel>();
    final r = responsive;

    return Container(
      color: _backgroundColor,
      child: Column(
        children: [
          // Header
          _buildReportHeader(r),
          
          SizedBox(height: 20 * r.scale),
          
          // Stats Grid
          _buildStatsGrid(reportVM, r),
          
          SizedBox(height: 20 * r.scale),
          
          // New Users Per Month Chart
          _buildUsersPerMonthChart(reportVM, r),
          
          SizedBox(height: 20 * r.scale),
          
          // Peak Recipe Month Card
          _buildPeakRecipeMonthCard(reportVM, r),
          
          SizedBox(height: 20 * r.scale),
          
          // Popular Categories
          _buildPopularCategoriesSection(reportVM, r),
          
          SizedBox(height: 32 * r.scale),
        ],
      ),
    );
  }

  Widget _buildReportHeader(ResponsiveHelper r) {
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
              // Admin Badge
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
                    Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 18 * r.scale,
                    ),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'PANEL DE ADMINISTRACIÓN',
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
                ],
              ),
            ],
          ),
          SizedBox(height: 16 * r.scale),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Estadísticas Globales',
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

  Widget _buildStatsGrid(ReportViewModel vm, ResponsiveHelper r) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            r,
            icon: Icons.people_alt_rounded,
            value: '${vm.usuariosTotales}',
            label: 'Usuarios Totales',
            color: _accentColor,
          ),
        ),
        SizedBox(width: 12 * r.scale),
        Expanded(
          child: _buildStatCard(
            r,
            icon: Icons.restaurant_menu_rounded,
            value: '${vm.recetasTotales}',
            label: 'Recetas Totales',
            color: _successColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ResponsiveHelper r, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
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
        children: [
          Container(
            padding: EdgeInsets.all(12 * r.scale),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28 * r.scale),
          ),
          SizedBox(height: 12 * r.scale),
          Text(
            value,
            style: TextStyle(
              fontSize: 32 * r.scale,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
          SizedBox(height: 4 * r.scale),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12 * r.scale,
              color: const Color(0xFF718096),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersPerMonthChart(ReportViewModel vm, ResponsiveHelper r) {
    final entries = vm.usuariosPorMes.entries.toList();
    final maxY = entries.isNotEmpty
        ? entries.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble()
        : 1.0;

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
                  color: _successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person_add_alt_1_rounded,
                  color: _successColor,
                  size: 20 * r.scale,
                ),
              ),
              SizedBox(width: 12 * r.scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Usuarios Nuevos por Mes',
                      style: TextStyle(
                        fontSize: 16 * r.scale,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    Text(
                      'Crecimiento de la comunidad',
                      style: TextStyle(
                        fontSize: 12 * r.scale,
                        color: const Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20 * r.scale),
          SizedBox(
            height: 200 * r.scale,
            child: entries.isEmpty
                ? Center(
                    child: Text(
                      'Sin datos de usuarios por mes',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14 * r.scale,
                      ),
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.only(
                      top: 10 * r.scale,
                      right: 10 * r.scale,
                    ),
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: maxY + 2,
                        lineBarsData: [
                          LineChartBarData(
                            spots: entries.asMap().entries.map((entry) {
                              return FlSpot(
                                entry.key.toDouble(),
                                entry.value.value.toDouble(),
                              );
                            }).toList(),
                            isCurved: true,
                            color: _successColor,
                            barWidth: 3,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4 * r.scale,
                                  color: _successColor,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: _successColor.withOpacity(0.2),
                            ),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx >= entries.length || idx < 0) {
                                  return const SizedBox();
                                }
                                final month = entries[idx].key.split('-').last;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _getMonthName(int.parse(month)),
                                    style: TextStyle(
                                      fontSize: 10 * r.scale,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30 * r.scale,
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: const Border(
                            bottom: BorderSide(color: Colors.grey),
                            left: BorderSide(color: Colors.grey),
                          ),
                        ),
                        gridData: const FlGridData(
                          show: true,
                          drawVerticalLine: false,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeakRecipeMonthCard(ReportViewModel vm, ResponsiveHelper r) {
    // Find peak month
    String peakMonth = '-';
    int peakCount = 0;
    
    vm.recetasPorMes.forEach((month, count) {
      if (count > peakCount) {
        peakCount = count;
        peakMonth = month;
      }
    });

    // Format peak month
    String formattedPeakMonth = '-';
    if (peakMonth != '-' && peakMonth.contains('-')) {
      final parts = peakMonth.split('-');
      if (parts.length == 2) {
        final year = parts[0];
        final month = int.tryParse(parts[1]) ?? 1;
        formattedPeakMonth = '${_getFullMonthName(month)} $year';
      }
    }

    return Container(
      padding: EdgeInsets.all(20 * r.scale),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _accentColor.withOpacity(0.1),
            _accentColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accentColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16 * r.scale),
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.trending_up_rounded,
              color: _accentColor,
              size: 32 * r.scale,
            ),
          ),
          SizedBox(width: 16 * r.scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mes con Más Recetas',
                  style: TextStyle(
                    fontSize: 14 * r.scale,
                    color: const Color(0xFF718096),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4 * r.scale),
                Text(
                  formattedPeakMonth,
                  style: TextStyle(
                    fontSize: 20 * r.scale,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16 * r.scale,
              vertical: 8 * r.scale,
            ),
            decoration: BoxDecoration(
              color: _accentColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$peakCount recetas',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14 * r.scale,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularCategoriesSection(ReportViewModel vm, ResponsiveHelper r) {
    final categories = vm.categoriasPopulares.entries.take(5).toList();
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
                child: Icon(
                  Icons.category_rounded,
                  color: _primaryColor,
                  size: 20 * r.scale,
                ),
              ),
              SizedBox(width: 12 * r.scale),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categorías Más Populares',
                    style: TextStyle(
                      fontSize: 16 * r.scale,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                  Text(
                    'Top 5 por número de recetas',
                    style: TextStyle(
                      fontSize: 12 * r.scale,
                      color: const Color(0xFF718096),
                    ),
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
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14 * r.scale,
                  ),
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
            }).toList(),
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
    ];
    final color = colors[(rank - 1) % colors.length];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24 * r.scale,
              height: 24 * r.scale,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    color: color,
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

  String _getMonthName(int month) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return months[(month - 1) % 12];
  }

  String _getFullMonthName(int month) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    return months[(month - 1) % 12];
  }
}
