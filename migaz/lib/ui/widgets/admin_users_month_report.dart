import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:migaz/core/utils/responsive_helper.dart';
import 'package:migaz/viewmodels/report_viewmodel.dart';
import 'package:provider/provider.dart';

/// Widget para mostrar usuarios nuevos por mes (Admin)
class AdminUsersPerMonthReport extends StatelessWidget {
  final ResponsiveHelper responsive;
  
  const AdminUsersPerMonthReport({
    super.key,
    required this.responsive,
  });

  static const Color _successColor = Color(0xFF25CCAD);
  static const Color _primaryColor = Color(0xFF25CCAD);
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
          _buildUsersPerMonthChart(reportVM, r),
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
              'Usuarios Nuevos por Mes',
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
                      'Crecimiento de la Comunidad',
                      style: TextStyle(
                        fontSize: 16 * r.scale,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    Text(
                      'Registros mensuales',
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
                                    style: TextStyle(fontSize: 10 * r.scale),
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
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: const Border(
                            bottom: BorderSide(color: Colors.grey),
                            left: BorderSide(color: Colors.grey),
                          ),
                        ),
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
}
