import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:migaz/viewmodels/report_viewmodel.dart';
import 'package:migaz/viewmodels/auth_viewmodel.dart';
import 'package:migaz/core/config/routes.dart';
import 'package:migaz/core/utils/responsive_helper.dart';
import 'package:migaz/core/utils/responsive_breakpoints.dart';

class PantallaReporte extends StatefulWidget {
  const PantallaReporte({super.key});

  @override
  State<PantallaReporte> createState() => _PantallaReporteState();
}

class _PantallaReporteState extends State<PantallaReporte> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatos();
    });
  }

  void _cargarDatos() {
    final authVM = context.read<AuthViewModel>();
    final reportVM = context.read<ReportViewModel>();

    if (authVM.currentUserId.isNotEmpty) {
      // Detectar si es admin (hardcoded "uhhFlame")
      final isAdmin = authVM.currentUser.toLowerCase() == 'uhhflame';

      reportVM.cargarTodo(
        authVM.currentUserId,
        authVM.currentUser,
        isAdmin: isAdmin,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    return Scaffold(
      body: Consumer2<ReportViewModel, AuthViewModel>(
        builder: (context, reportVM, authVM, child) {
          if (reportVM.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando estadísticas...'),
                ],
              ),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(context, responsive),

                // Charts content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16 * responsive.scale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // LOGIC:
                        // Admin: New Users, Total Users, Recipes/Month, Categories, Global Recipes
                        // Normal: Recipes/Month, Followers, Global Recipes, Categories
                        if (authVM.currentUser.toLowerCase() == 'uhhflame') ...[
                          // ADMIN VIEW
                          // 1. Usuarios Totales + Usuarios Nuevos (Agrupado)
                          _buildAdminHeader(responsive),
                          SizedBox(height: 20 * responsive.scale),

                          _buildResponsiveRow(responsive, [
                            _buildTotalUsersCard(reportVM, responsive),
                            _buildUsersPerMonthChart(reportVM, responsive),
                          ]),
                          SizedBox(height: 20 * responsive.scale),

                          // 2. Global Recipes + Categories
                          _buildResponsiveRow(responsive, [
                            _buildTotalRecipesCard(
                              reportVM,
                              responsive,
                            ), // Recetas globales
                            _buildCategoriesChart(
                              reportVM,
                              responsive,
                            ), // Categorias
                          ]),
                          SizedBox(height: 20 * responsive.scale),

                          // 3. Cookbook (Added per request)
                          _buildCookbookChart(reportVM, responsive),
                          SizedBox(height: 20 * responsive.scale),

                          // 4. Recipes per Month
                          _buildRecipesPerMonthChart(reportVM, responsive),
                        ] else ...[
                          // NORMAL VIEW
                          // 1. Followers + Global Recipes
                          _buildResponsiveRow(responsive, [
                            _buildFollowersChart(reportVM, responsive),
                            _buildTotalRecipesCard(reportVM, responsive),
                          ]),
                          SizedBox(height: 20 * responsive.scale),

                          // 2. Cookbook (Added per request)
                          _buildCookbookChart(reportVM, responsive),
                          SizedBox(height: 20 * responsive.scale),

                          // 3. Categories
                          _buildCategoriesChart(reportVM, responsive),
                          SizedBox(height: 20 * responsive.scale),

                          // 4. Recipes per Month
                          _buildRecipesPerMonthChart(reportVM, responsive),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ResponsiveHelper responsive) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.0 * responsive.scale,
        vertical: 10 * responsive.scale,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, size: 24 * responsive.scale),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.perfilUser),
          ),
          Expanded(
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 24 * responsive.scale,
                  vertical: 8 * responsive.scale,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B8DEE).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Reporte de Estadísticas',
                  style: TextStyle(
                    fontSize:
                        ResponsiveBreakpoints.getScaledFontSize(context, 20) *
                        responsive.scale,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 48 * responsive.scale), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildResponsiveRow(
    ResponsiveHelper responsive,
    List<Widget> children,
  ) {
    if (responsive.isMobile) {
      return Column(
        children: children
            .map(
              (c) => Padding(
                padding: EdgeInsets.only(bottom: 16 * responsive.scale),
                child: c,
              ),
            )
            .toList(),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
          .map(
            (c) => Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8 * responsive.scale),
                child: c,
              ),
            ),
          )
          .toList(),
    );
  }

  // ==================== CHART WIDGETS ====================

  Widget _buildFollowersChart(ReportViewModel vm, ResponsiveHelper responsive) {
    final total = vm.seguidores + vm.seguidos;

    return _buildChartCard(
      title: 'Seguidores vs Seguidos',
      icon: Icons.people,
      responsive: responsive,
      child: SizedBox(
        height: 200 * responsive.scale,
        child: total == 0
            ? Center(
                child: Text(
                  'Sin datos de seguidores',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14 * responsive.scale,
                  ),
                ),
              )
            : Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: vm.seguidores.toDouble(),
                            title: '${vm.seguidores}',
                            color: const Color(0xFF25CCAD),
                            radius: 60 * responsive.scale,
                            titleStyle: TextStyle(
                              fontSize: 14 * responsive.scale,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: vm.seguidos.toDouble(),
                            title: '${vm.seguidos}',
                            color: const Color(0xFF5B8DEE),
                            radius: 60 * responsive.scale,
                            titleStyle: TextStyle(
                              fontSize: 14 * responsive.scale,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                        sectionsSpace: 2,
                        centerSpaceRadius: 30 * responsive.scale,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegendItem(
                          'Seguidores',
                          const Color(0xFF25CCAD),
                          responsive,
                        ),
                        SizedBox(height: 8 * responsive.scale),
                        _buildLegendItem(
                          'Seguidos',
                          const Color(0xFF5B8DEE),
                          responsive,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTotalRecipesCard(
    ReportViewModel vm,
    ResponsiveHelper responsive,
  ) {
    return _buildChartCard(
      title: 'Recetas Globales',
      icon: Icons.restaurant_menu,
      responsive: responsive,
      child: SizedBox(
        height: 200 * responsive.scale,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${vm.recetasTotales}',
                style: TextStyle(
                  fontSize: 64 * responsive.scale,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFEA7317),
                ),
              ),
              Text(
                'recetas en total',
                style: TextStyle(
                  fontSize: 16 * responsive.scale,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCookbookChart(ReportViewModel vm, ResponsiveHelper responsive) {
    final maxY =
        (vm.misRecetas > vm.recetasGuardadas
                ? vm.misRecetas
                : vm.recetasGuardadas)
            .toDouble();

    return _buildChartCard(
      title: 'Mi Libro de Cocina',
      icon: Icons.menu_book,
      responsive: responsive,
      child: SizedBox(
        height: 200 * responsive.scale,
        child: (vm.misRecetas + vm.recetasGuardadas) == 0
            ? Center(
                child: Text(
                  'Sin recetas propias ni guardadas',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14 * responsive.scale,
                  ),
                ),
              )
            : Padding(
                padding: EdgeInsets.only(
                  top: 20 * responsive.scale,
                  right: 20 * responsive.scale,
                ),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY + 2,
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(
                            toY: vm.misRecetas.toDouble(),
                            color: const Color(0xFF25CCAD),
                            width: 40 * responsive.scale,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY: vm.recetasGuardadas.toDouble(),
                            color: const Color(0xFFEA7317),
                            width: 40 * responsive.scale,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ],
                      ),
                    ],
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final titles = ['Mis Recetas', 'Guardadas'];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                titles[value.toInt()],
                                style: TextStyle(
                                  fontSize: 12 * responsive.scale,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30 * responsive.scale,
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(
                      show: true,
                      drawVerticalLine: false,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildCategoriesChart(
    ReportViewModel vm,
    ResponsiveHelper responsive,
  ) {
    final top5 = vm.categoriasPopulares.entries.take(5).toList();
    final maxValue = top5.isNotEmpty ? top5.first.value.toDouble() : 1.0;

    return _buildChartCard(
      title: 'Categorías Más Populares',
      icon: Icons.category,
      responsive: responsive,
      child: SizedBox(
        height: 220 * responsive.scale,
        child: top5.isEmpty
            ? Center(
                child: Text(
                  'Sin datos de categorías',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14 * responsive.scale,
                  ),
                ),
              )
            : Padding(
                padding: EdgeInsets.only(
                  top: 16 * responsive.scale,
                  right: 16 * responsive.scale,
                  left: 8 * responsive.scale,
                ),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxValue + 2,
                    barGroups: top5.asMap().entries.map((entry) {
                      final colors = [
                        const Color(0xFF25CCAD),
                        const Color(0xFF5B8DEE),
                        const Color(0xFFEA7317),
                        const Color(0xFFFF6B6B),
                        const Color(0xFF9B59B6),
                      ];
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.value.toDouble(),
                            color: colors[entry.key % colors.length],
                            width: 24 * responsive.scale,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      );
                    }).toList(),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= top5.length)
                              return const SizedBox();
                            final name = top5[value.toInt()].key;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                name.length > 8
                                    ? '${name.substring(0, 8)}...'
                                    : name,
                                style: TextStyle(
                                  fontSize: 10 * responsive.scale,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30 * responsive.scale,
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(
                      show: true,
                      drawVerticalLine: false,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildRecipesPerMonthChart(
    ReportViewModel vm,
    ResponsiveHelper responsive,
  ) {
    final entries = vm.recetasPorMes.entries.toList();
    final maxY = entries.isNotEmpty
        ? entries.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble()
        : 1.0;

    return _buildChartCard(
      title: 'Recetas Subidas por Mes',
      icon: Icons.trending_up,
      responsive: responsive,
      child: SizedBox(
        height: 220 * responsive.scale,
        child: entries.isEmpty
            ? Center(
                child: Text(
                  'Sin datos de recetas por mes',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14 * responsive.scale,
                  ),
                ),
              )
            : Padding(
                padding: EdgeInsets.only(
                  top: 20 * responsive.scale,
                  right: 20 * responsive.scale,
                  bottom: 10 * responsive.scale,
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
                        color: const Color(0xFF5B8DEE),
                        barWidth: 3,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4 * responsive.scale,
                              color: const Color(0xFF5B8DEE),
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: const Color(0xFF5B8DEE).withOpacity(0.2),
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
                            if (idx >= entries.length || idx < 0)
                              return const SizedBox();
                            final month = entries[idx].key.split('-').last;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _getMonthName(int.parse(month)),
                                style: TextStyle(
                                  fontSize: 10 * responsive.scale,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30 * responsive.scale,
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
    );
  }

  // ==================== HELPERS ====================

  Widget _buildChartCard({
    required String title,
    required IconData icon,
    required ResponsiveHelper responsive,
    required Widget child,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16 * responsive.scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF5B8DEE),
                  size: 24 * responsive.scale,
                ),
                SizedBox(width: 8 * responsive.scale),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18 * responsive.scale,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16 * responsive.scale),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(
    String label,
    Color color,
    ResponsiveHelper responsive,
  ) {
    return Row(
      children: [
        Container(
          width: 16 * responsive.scale,
          height: 16 * responsive.scale,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 8 * responsive.scale),
        Text(label, style: TextStyle(fontSize: 12 * responsive.scale)),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return months[(month - 1) % 12];
  }

  // ==================== ADMIN WIDGETS ====================

  Widget _buildAdminHeader(ResponsiveHelper responsive) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16 * responsive.scale,
        vertical: 12 * responsive.scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEA7317).withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFEA7317).withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.admin_panel_settings,
            color: const Color(0xFFEA7317),
            size: 28 * responsive.scale,
          ),
          SizedBox(width: 12 * responsive.scale),
          Text(
            'Estadísticas de Administrador',
            style: TextStyle(
              fontSize: 18 * responsive.scale,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFEA7317),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalUsersCard(ReportViewModel vm, ResponsiveHelper responsive) {
    return _buildChartCard(
      title: 'Usuarios Totales',
      icon: Icons.people_alt,
      responsive: responsive,
      child: SizedBox(
        height: 200 * responsive.scale,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people,
                size: 80 * responsive.scale,
                color: const Color(0xFF5B8DEE).withOpacity(0.3),
              ),
              SizedBox(height: 16 * responsive.scale),
              Text(
                '${vm.usuariosTotales}',
                style: TextStyle(
                  fontSize: 48 * responsive.scale,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5B8DEE),
                ),
              ),
              Text(
                'usuarios registrados',
                style: TextStyle(
                  fontSize: 14 * responsive.scale,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsersPerMonthChart(
    ReportViewModel vm,
    ResponsiveHelper responsive,
  ) {
    final entries = vm.usuariosPorMes.entries.toList();
    final maxY = entries.isNotEmpty
        ? entries.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble()
        : 1.0;

    return _buildChartCard(
      title: 'Usuarios Nuevos por Mes',
      icon: Icons.trending_up,
      responsive: responsive,
      child: SizedBox(
        height: 200 * responsive.scale,
        child: entries.isEmpty
            ? Center(
                child: Text(
                  'Sin datos de usuarios por mes',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14 * responsive.scale,
                  ),
                ),
              )
            : Padding(
                padding: EdgeInsets.only(
                  top: 20 * responsive.scale,
                  right: 20 * responsive.scale,
                  bottom: 10 * responsive.scale,
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
                        color: const Color(0xFF25CCAD),
                        barWidth: 3,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4 * responsive.scale,
                              color: const Color(0xFF25CCAD),
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: const Color(0xFF25CCAD).withOpacity(0.2),
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
                            if (idx >= entries.length || idx < 0)
                              return const SizedBox();
                            final month = entries[idx].key.split('-').last;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _getMonthName(int.parse(month)),
                                style: TextStyle(
                                  fontSize: 10 * responsive.scale,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30 * responsive.scale,
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
    );
  }
}
