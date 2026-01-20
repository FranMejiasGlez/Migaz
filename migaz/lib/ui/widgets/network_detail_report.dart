import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:migaz/core/utils/responsive_helper.dart';
import 'package:migaz/viewmodels/report_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:migaz/core/config/api_config.dart';
import 'package:migaz/core/constants/recipe_constants.dart';

class NetworkDetailReport extends StatelessWidget {
  final ResponsiveHelper responsive;
  
  const NetworkDetailReport({
    Key? key,
    required this.responsive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reportVM = context.watch<ReportViewModel>();
    final r = responsive;
    
    // Datos
    final followers = reportVM.listaSeguidores;
    final following = reportVM.listaSeguidos;
    final followersCount = reportVM.seguidores;
    final followingCount = reportVM.seguidos;

    return Container(
      color: const Color(0xFFF5F7FA),
      child: Column(
        children: [
          // Header
          _buildReportHeader(reportVM, r),
          
          SizedBox(height: 20 * r.scale),
          
          // Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0 * r.scale),
            child: Column(
              children: [
                _buildNetworkTitle(r),
                SizedBox(height: 16 * r.scale),
                
                // Chart & Stats
                _buildChartSection(followersCount, followingCount, r),
                
                SizedBox(height: 24 * r.scale),
                
                // Lists Columns
                _buildListsSection(followers, following, r),
                
                SizedBox(height: 16 * r.scale),
              ],
            ),
          ),
          
          // Footer Summary
          _buildSummaryFooter(followersCount, followingCount, r),
          
          SizedBox(height: 32 * r.scale),
        ],
      ),
    );
  }

  Widget _buildReportHeader(ReportViewModel reportVM, ResponsiveHelper r) {
    final now = DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy').format(now);
    
    // Azul corporativo para Network
    final Color headerColor = const Color(0xFF2B6CB0); 

    return Container(
      padding: EdgeInsets.all(24 * r.scale),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [headerColor, headerColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: headerColor.withOpacity(0.3),
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
                width: 60 * r.scale,
                height: 60 * r.scale,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
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
                    'RED DE CONTACTOS',
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
                    'De: @${reportVM.currentUserName}',
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
              'Estado Actual',
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

  Widget _buildNetworkTitle(ResponsiveHelper r) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12 * r.scale, horizontal: 16 * r.scale),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
          top: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
        ),
      ),
      child: Text(
        'MI RED DE CONTACTOS (ESTADO ACTUAL)',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey[700],
          fontWeight: FontWeight.bold,
          fontSize: 14 * r.scale,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildChartSection(int followers, int following, ResponsiveHelper r) {
    final total = followers + following;
    if (total == 0) {
      return Center(child: Text("Sin actividad de red aún"));
    }
    
    return Container(
      height: 200 * r.scale, // Increased height for better visibility
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40 * r.scale,
                sections: [
                  PieChartSectionData(
                    color: Colors.blueAccent,
                    value: followers.toDouble(),
                    title: '${((followers/total)*100).toStringAsFixed(0)}%',
                    radius: 50 * r.scale,
                    titleStyle: TextStyle(fontSize: 12 * r.scale, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  PieChartSectionData(
                    color: Colors.orangeAccent,
                    value: following.toDouble(),
                    title: '${((following/total)*100).toStringAsFixed(0)}%',
                    radius: 50 * r.scale,
                     titleStyle: TextStyle(fontSize: 12 * r.scale, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          // Legend
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendItem(Colors.blueAccent, "Seguidores ($followers)", r),
              SizedBox(height: 8 * r.scale),
              _buildLegendItem(Colors.orangeAccent, "Seguidos ($following)", r),
            ],
          ),
          SizedBox(width: 32 * r.scale),
        ],
      ),
    );
  }
  
  Widget _buildLegendItem(Color color, String text, ResponsiveHelper r) {
    return Row(
      children: [
        Container(width: 12 * r.scale, height: 12 * r.scale, color: color),
        SizedBox(width: 8 * r.scale),
        Text(text, style: TextStyle(fontSize: 12 * r.scale, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildListsSection(List<dynamic> followers, List<dynamic> following, ResponsiveHelper r) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * r.scale),
      child:  IntrinsicHeight( // Ensures both columns stretch to same height
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _buildUserColumn("SEGUIDORES", "Te siguen a ti", followers, r, Colors.blueAccent)),
            Container(width: 1, color: Colors.grey.withOpacity(0.35)), // Vertical Divider
            Expanded(child: _buildUserColumn("SEGUIDOS", "Tú los sigues", following, r, Colors.orangeAccent)),
          ],
        ),
      ),
    );
  }

  Widget _buildUserColumn(String title, String subtitle, List<dynamic> users, ResponsiveHelper r, Color accentColor) {
    return Column(
      children: [
        // Column Header
        Container(
          margin: EdgeInsets.only(bottom: 16 * r.scale),
          padding: EdgeInsets.symmetric(vertical: 8 * r.scale, horizontal: 12 * r.scale),
          decoration: BoxDecoration(
             color: accentColor.withOpacity(0.05),
             borderRadius: BorderRadius.circular(8),
             border: Border.all(color: accentColor.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13 * r.scale, color: accentColor),
              ),
              SizedBox(height: 2 * r.scale),
              Text(
                subtitle,
                style: TextStyle(fontSize: 10 * r.scale, color: Colors.grey[600], fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        
        // List Content
        if (users.isEmpty)
           Padding(
             padding: EdgeInsets.all(16.0 * r.scale),
             child: Text("Sin registros aún", style: TextStyle(color: Colors.grey, fontSize: 12 * r.scale, fontStyle: FontStyle.italic)),
           )
        else
          ...users.asMap().entries.map((entry) {
            final user = entry.value;
            String name = 'Usuario';
            String? imageUrl;
            
            if (user is Map) {
              name = user['username'] ?? 'Sin nombre';
              imageUrl = user['profile_image'];
            }
            
            return Container(
              margin: EdgeInsets.only(bottom: 8 * r.scale, left: 4 * r.scale, right: 4 * r.scale),
              padding: EdgeInsets.all(8 * r.scale),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(color: Colors.grey.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32 * r.scale,
                    height: 32 * r.scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withOpacity(0.1),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        ApiConfig.getImageUrl(imageUrl ?? ApiConfig.defaultProfileImage),
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Image.network(
                          ApiConfig.defaultProfileImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12 * r.scale),
                  Expanded(
                    child: Text(
                      "@$name", 
                      style: TextStyle(
                        fontSize: 13 * r.scale, 
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D3748),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          
          const Spacer(), 
          
          Container(
            padding: EdgeInsets.symmetric(vertical: 12 * r.scale),
            width: double.infinity,
            child: Text(
              "TOTAL: ${users.length}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900, 
                fontSize: 12 * r.scale, 
                color: accentColor,
                letterSpacing: 1.2,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryFooter(int followers, int following, ResponsiveHelper r) {
    double ratio = following > 0 ? followers / following : followers.toDouble();
    String ratioText = "Tienes $followers seguidores por cada 1 seguido.";
    if (following > 0) {
      ratioText = "Tienes ${ratio.toStringAsFixed(1)} seguidores por cada 1 seguido.";
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16 * r.scale),
      padding: EdgeInsets.all(16 * r.scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3), style: BorderStyle.solid),
      ),
      child: Row(
        children: [
          Icon(Icons.insights, color: Colors.blueAccent, size: 24 * r.scale),
          SizedBox(width: 12 * r.scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ÍNDICE DE POPULARIDAD",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11 * r.scale,
                    color: Colors.grey[600],
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 4 * r.scale),
                Text(
                  ratioText,
                  style: TextStyle(
                    fontSize: 13 * r.scale,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
