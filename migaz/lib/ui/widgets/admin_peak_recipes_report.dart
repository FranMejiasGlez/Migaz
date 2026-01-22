import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:migaz/core/utils/responsive_helper.dart';
import 'package:migaz/viewmodels/report_viewmodel.dart';
import 'package:provider/provider.dart';

/// Widget para mostrar el mes con más recetas subidas (Admin)
class AdminPeakRecipesReport extends StatelessWidget {
  final ResponsiveHelper responsive;
  
  const AdminPeakRecipesReport({
    super.key,
    required this.responsive,
  });

  static const Color _accentColor = Color(0xFF5B8DEE);
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
          _buildPeakRecipeMonthCard(reportVM, r),
          SizedBox(height: 20 * r.scale),
          _buildRecipesPerMonthChart(reportVM, r),
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
          colors: [_accentColor, _accentColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _accentColor.withOpacity(0.3),
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
              'Recetas Subidas por Mes',
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

  Widget _buildPeakRecipeMonthCard(ReportViewModel vm, ResponsiveHelper r) {
    String peakMonth = '-';
    int peakCount = 0;
    
    vm.recetasPorMes.forEach((month, count) {
      if (count > peakCount) {
        peakCount = count;
        peakMonth = month;
      }
    });

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
          colors: [_accentColor.withOpacity(0.1), _accentColor.withOpacity(0.05)],
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
            child: Icon(Icons.emoji_events_rounded, color: _accentColor, size: 32 * r.scale),
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
            padding: EdgeInsets.symmetric(horizontal: 16 * r.scale, vertical: 8 * r.scale),
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

  Widget _buildRecipesPerMonthChart(ReportViewModel vm, ResponsiveHelper r) {
    final entries = vm.recetasPorMes.entries.toList();
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
                  color: _accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.trending_up_rounded, color: _accentColor, size: 20 * r.scale),
              ),
              SizedBox(width: 12 * r.scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Evolución de Recetas',
                      style: TextStyle(
                        fontSize: 16 * r.scale,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    Text(
                      'Recetas subidas por mes',
                      style: TextStyle(fontSize: 12 * r.scale, color: const Color(0xFF718096)),
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
                ? Center(child: Text('Sin datos', style: TextStyle(color: Colors.grey, fontSize: 14 * r.scale)))
                : Padding(
                    padding: EdgeInsets.only(top: 10 * r.scale, right: 10 * r.scale),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: maxY + 2,
                        barGroups: entries.asMap().entries.map((entry) {
                          return BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value.value.toDouble(),
                                color: _accentColor,
                                width: 16 * r.scale,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx >= entries.length || idx < 0) return const SizedBox();
                                final month = entries[idx].key.split('-').last;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(_getMonthName(int.parse(month)), style: TextStyle(fontSize: 10 * r.scale)),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30 * r.scale)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: true, drawVerticalLine: false),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return months[(month - 1) % 12];
  }

  String _getFullMonthName(int month) {
    const months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    return months[(month - 1) % 12];
  }
}
