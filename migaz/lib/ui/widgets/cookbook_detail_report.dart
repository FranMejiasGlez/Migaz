import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:migaz/core/utils/responsive_helper.dart';
import 'package:migaz/viewmodels/report_viewmodel.dart';
import 'package:provider/provider.dart';

class CookbookDetailReport extends StatefulWidget {
  final ResponsiveHelper responsive;
  
  const CookbookDetailReport({
    Key? key,
    required this.responsive,
  }) : super(key: key);

  @override
  State<CookbookDetailReport> createState() => _CookbookDetailReportState();
}

class _CookbookDetailReportState extends State<CookbookDetailReport> {
  final Map<String, bool> _expandedCategories = {};

  final Color _primaryColor = const Color(0xFFEA7317); // Orange for Cookbook
  final Color _cardColor = Colors.white;
  final Color _backgroundColor = const Color(0xFFF5F7FA);

  @override
  Widget build(BuildContext context) {
    final reportVM = context.watch<ReportViewModel>();
    final data = reportVM.cookbookReport;
    final r = widget.responsive;

    return Container(
      color: _backgroundColor,
      child: Column(
        children: [
          // Header
          _buildReportHeader(reportVM, r),
          
          SizedBox(height: 20 * r.scale),
          
          // Content
          if (data.isEmpty)
             _buildEmptyState(r)
          else
            ...data.map((catData) => _buildCategoryCard(catData, r)).toList(),
            
          SizedBox(height: 20 * r.scale),
          
          // Footer
          _buildSummaryFooter(reportVM, r),
          
          SizedBox(height: 32 * r.scale),
        ],
      ),
    );
  }

  Widget _buildReportHeader(ReportViewModel reportVM, ResponsiveHelper r) {
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
                    'LIBRO DE RECETAS',
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
              'Mis Recetas y Guardadas',
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

  Widget _buildCategoryCard(CookbookReportData catData, ResponsiveHelper r) {
    final isExpanded = _expandedCategories[catData.categoryName] ?? false;

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
          // Header
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(16),
              bottom: isExpanded ? Radius.zero : const Radius.circular(16),
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
                      child: Text(
                        catData.categoryName,
                        style: TextStyle(
                          fontSize: 16 * r.scale,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D3748),
                        ),
                      ),
                    ),
                    Text(
                      '${catData.totalRecipes} items',
                      style: TextStyle(
                        fontSize: 12 * r.scale,
                        color: const Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                
                // Column Headers
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20 * r.scale, vertical: 12 * r.scale),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: _headerText('RECETA', r)),
                      Expanded(child: Center(child: _headerText('DIF.', r))),
                      Expanded(flex: 2, child: Center(child: _headerText('VALORACIÓN', r))),
                      Expanded(child: Center(child: _headerText('GUARDADOS', r))), // Changed from LIKES
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.grey.withOpacity(0.1)),

                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: catData.recipes.length,
                  separatorBuilder: (c, i) => Divider(height: 1, indent: 20 * r.scale, endIndent: 20 * r.scale, color: Colors.grey.withOpacity(0.05)),
                  itemBuilder: (context, index) {
                    final recipe = catData.recipes[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20 * r.scale, vertical: 12 * r.scale),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  if (recipe.isMine)
                                    Padding(
                                      padding: EdgeInsets.only(right: 6 * r.scale),
                                      child: Icon(Icons.person, size: 14 * r.scale, color: _primaryColor),
                                    ),
                                  Expanded(
                                    child: Text(
                                      recipe.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13 * r.scale,
                                        color: const Color(0xFF2D3748),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ]),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: _difficultyBadge(recipe.difficulty, r),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.star_rounded, size: 16 * r.scale, color: const Color(0xFFFFC107)),
                                SizedBox(width: 4 * r.scale),
                                Text(
                                  recipe.rating.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13 * r.scale,
                                    color: const Color(0xFF4A5568),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.favorite_rounded, size: 14 * r.scale, color: const Color(0xFFE53E3E)),
                                SizedBox(width: 4 * r.scale),
                                Text(
                                  '${recipe.savedCount ?? 0}', // Using placeholder if null
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13 * r.scale,
                                    color: const Color(0xFF718096),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                // Footer Group
                Container(
                  padding: EdgeInsets.all(12 * r.scale),
                  color: Colors.grey.withOpacity(0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: ${catData.totalRecipes}',
                        style: TextStyle(fontSize: 12 * r.scale, fontWeight: FontWeight.bold, color: _primaryColor),
                      ),
                      Text(
                        'Promedio: ${catData.averageRating.toStringAsFixed(1)} ★', // Simple avg
                         style: TextStyle(fontSize: 12 * r.scale, color: Colors.grey[700]),
                      ),
                      Text(
                        'Recetas: ${catData.totalSaved}', // Changed from Guardados to Recetas
                         style: TextStyle(fontSize: 12 * r.scale, color: Colors.grey[700]),
                      ),
                    ],
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
  
  Widget _headerText(String text, ResponsiveHelper r) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10 * r.scale,
        fontWeight: FontWeight.bold,
        color: const Color(0xFFA0AEC0),
        letterSpacing: 1,
      ),
    );
  }

  Widget _difficultyBadge(int difficulty, ResponsiveHelper r) {
    Color color;
    String text;
    
    switch(difficulty) {
      case 1: color = Colors.green; text = 'Fácil'; break;
      case 2: color = Colors.orange; text = 'Media'; break;
      case 3: color = Colors.red; text = 'Difícil'; break;
      default: color = Colors.blue; text = 'N/A';
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * r.scale, vertical: 2 * r.scale),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10 * r.scale, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSummaryFooter(ReportViewModel vm, ResponsiveHelper r) {
    return Container(
      padding: EdgeInsets.all(20 * r.scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RESUMEN DE IMPACTO',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12 * r.scale,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12 * r.scale),
          Text(
            'Tus recetas (y las que guardas) conforman tu identidad culinaria.',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 14 * r.scale,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ResponsiveHelper r) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32 * r.scale),
        child: Column(
          children: [
            Icon(Icons.menu_book_rounded, size: 48 * r.scale, color: Colors.grey.shade300),
            SizedBox(height: 16 * r.scale),
            Text(
              'No hay recetas en tu libro aún',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
