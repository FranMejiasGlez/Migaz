import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:migaz/core/utils/responsive_helper.dart';
import 'package:migaz/viewmodels/report_viewmodel.dart';
import 'package:provider/provider.dart';

/// Widget para mostrar estadísticas globales de usuarios y recetas (Admin)
class AdminTotalUsersReport extends StatelessWidget {
  final ResponsiveHelper responsive;
  
  const AdminTotalUsersReport({
    super.key,
    required this.responsive,
  });

  static const Color _primaryColor = Color(0xFFEA7317);
  static const Color _accentColor = Color(0xFF5B8DEE);
  static const Color _successColor = Color(0xFF25CCAD);
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
          _buildStatsGrid(reportVM, r),
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
              'Usuarios Totales',
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
            label: 'Usuarios Registrados',
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
}
