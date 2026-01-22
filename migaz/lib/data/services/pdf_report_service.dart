import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:migaz/viewmodels/report_viewmodel.dart';

class PdfReportService {
  final PdfColor baseOrange = PdfColor.fromInt(0xFFEA7317);
  final PdfColor statsBlue = PdfColor.fromInt(0xFF5B8DEE);
  final PdfColor lightGrey = PdfColor.fromInt(0xFFF7F9FB);
  final PdfColor darkGrey = PdfColor.fromInt(0xFF2D3748);

  final pw.TextStyle _baseStyle = pw.TextStyle(fontSize: 10, color: PdfColor.fromInt(0xFF2D3748));
  final pw.TextStyle _headerStyle = pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.white);
  final pw.TextStyle _titleStyle = pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFFEA7317));

  Future<void> generateAndDisplayReport(ReportViewModel vm, {bool isAdmin = false}) async {
    print('DEBUG: PdfReportService.generateAndDisplayReport started, isAdmin=$isAdmin');
    try {
      final pdf = pw.Document();

      if (isAdmin) {
        print('DEBUG: Building Admin specific pages');
        // Admin: Everything
        pdf.addPage(_buildPageGlobalAndActivity(vm));
        pdf.addPage(_buildPageCategories(vm, isAdmin: true));
        pdf.addPage(_buildPageCookbook(vm));
        pdf.addPage(_buildPageNetwork(vm));
      } else {
        print('DEBUG: Building User specific pages');
        // User: Popular Categories + Personal Data
        pdf.addPage(_buildPageCategories(vm, isAdmin: false));
        pdf.addPage(_buildPageCookbook(vm));
        pdf.addPage(_buildPageNetwork(vm));
      }

      print('DEBUG: PDF building finished, launching layout');
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Reporte_Migaz_${isAdmin ? "Admin" : vm.currentUserName}.pdf',
      );
      print('DEBUG: Printing.layoutPdf completed');
    } catch (e, stack) {
      print('DEBUG: ERROR generating PDF: $e');
      print('DEBUG: STACKTRACE: $stack');
    }
  }

  pw.Page _buildPageGlobalAndActivity(ReportViewModel vm) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          children: [
            _buildPremiumHeader('MIGAZ GLOBAL REPORT', 'EVOLUCIÓN DE LA APP'),
            pw.SizedBox(height: 30),
            _buildSectionTitle('BALANCE DEL SISTEMA:'),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                _buildScoreCircle(vm.recetasTotales.toString(), 'RECETAS'),
                pw.SizedBox(width: 40),
                _buildScoreCircle(vm.usuariosTotales.toString(), 'USUARIOS'),
              ],
            ),
            pw.SizedBox(height: 40),
            _buildActivityHistory(vm),
            pw.Spacer(),
            _buildPremiumSummary('ESTADO GLOBAL DEL SISTEMA', [
              'Tasa de crecimiento mensual: ${(vm.recetasTotales / 12).toStringAsFixed(1)} recetas/mes',
              'Usuarios activos registrados: ${vm.usuariosTotales}',
              'Categoría dominante: "${vm.bestRatedCategory}"',
            ], statsBlue),
          ],
        );
      },
    );
  }

  pw.Page _buildPageCategories(ReportViewModel vm, {required bool isAdmin}) {
    return pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return [
          _buildPremiumHeader('LOGO MIGAZ', isAdmin ? 'AUDITORÍA DE INVENTARIO' : 'CATEGORÍAS POPULARES'),
          pw.SizedBox(height: 20),
          ...vm.categoriesDetailedReport.take(isAdmin ? 100 : 5).map((cat) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildGroupHeader('CATEGORÍA: ${cat.categoryName.toUpperCase()}', statsBlue),
                pw.TableHelper.fromTextArray(
                  headers: ['ID', 'TÍTULO DE RECETA', 'FECHA ALTA', 'VALORACIÓN'],
                  data: cat.recipes.take(10).map((r) => [
                    '#${r.id.substring(r.id.length - 3)}',
                    r.title,
                    '${r.createdAt.day}/${r.createdAt.month}/${r.createdAt.year}',
                    '${r.rating.toStringAsFixed(1)} / 5',
                  ]).toList(),
                  border: null,
                  headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10),
                  cellStyle: const pw.TextStyle(fontSize: 9),
                  headerDecoration: pw.BoxDecoration(color: statsBlue),
                  rowDecoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5))),
                  cellAlignment: pw.Alignment.centerLeft,
                  oddRowDecoration: pw.BoxDecoration(color: lightGrey),
                ),
                _buildGroupFooter('RECETAS EN CAT: ${cat.totalRecipes}   |   VALORACIÓN MEDIA: ${cat.averageRating.toStringAsFixed(1)} / 5'),
                pw.SizedBox(height: 20),
              ],
            );
          }),
          _buildPremiumSummary('RESUMEN DE CATEGORÍAS', [
            'Total de recetas analizadas: ${vm.recetasTotales}',
            'Categoría con mejor desempeño: "${vm.bestRatedCategory}" (${vm.bestRatedCategoryScore.toStringAsFixed(1)} / 5)',
          ], statsBlue),
        ];
      },
    );
  }

  pw.Page _buildPageCookbook(ReportViewModel vm) {
    return pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return [
          _buildPremiumHeader('M I G A Z', 'LIBRO DE RECETAS: @${vm.currentUserName}'),
          pw.SizedBox(height: 20),
          ...vm.cookbookReport.map((cat) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildGroupHeader('CATEGORÍA: ${cat.categoryName.toUpperCase()}', baseOrange),
                pw.TableHelper.fromTextArray(
                  headers: ['RECETA', 'DIFICULTAD', 'VALORACIÓN', 'GUARDADOS'],
                  data: cat.recipes.map((r) => [
                    r.title,
                    _getDifficultyLabel(r.difficulty),
                    '${r.rating.toStringAsFixed(1)} / 5',
                    '${r.savedCount ?? 0}',
                  ]).toList(),
                  border: null,
                  headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10),
                  cellStyle: const pw.TextStyle(fontSize: 9),
                  headerDecoration: pw.BoxDecoration(color: baseOrange),
                  oddRowDecoration: pw.BoxDecoration(color: lightGrey),
                ),
                _buildGroupFooter('CONTENIDO: ${cat.totalRecipes} RECETAS   |   PROMEDIO: ${cat.averageRating.toStringAsFixed(1)} / 5'),
                pw.SizedBox(height: 20),
              ],
            );
          }),
          _buildPremiumSummary('RESUMEN DE IMPACTO', [
            'Impacto total en la comunidad: ${vm.totalImpact} guardados',
            'Recetas publicadas: ${vm.misRecetas}',
            'Recetas guardadas: ${vm.recetasGuardadas}',
          ], baseOrange),
        ];
      },
    );
  }

  pw.Page _buildPageNetwork(ReportViewModel vm) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildPremiumHeader('PERFIL: @${vm.currentUserName}', 'RED DE CONTACTOS'),
            pw.SizedBox(height: 30),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildGroupHeader('SEGUIDORES', statsBlue),
                      ...vm.listaSeguidores.take(20).map((u) => pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 2),
                        child: pw.Text('• ${u['username'] ?? 'Usuario'}', style: const pw.TextStyle(fontSize: 10)),
                      )),
                      if (vm.listaSeguidores.length > 20) pw.Text('...', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
                pw.SizedBox(width: 40),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildGroupHeader('SEGUIDOS', baseOrange),
                      ...vm.listaSeguidos.take(20).map((u) => pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 2),
                        child: pw.Text('• ${u['username'] ?? 'Usuario'}', style: const pw.TextStyle(fontSize: 10)),
                      )),
                      if (vm.listaSeguidos.length > 20) pw.Text('...', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
            pw.Spacer(),
            _buildPremiumFooterStats(vm),
            pw.SizedBox(height: 20),
            _buildPremiumSummary('ESTADÍSTICAS DE RED', [
              'Índice de Popularidad: ${vm.seguidos == 0 ? vm.seguidores : (vm.seguidores / vm.seguidos).toStringAsFixed(1)} seguidores/seguido',
              'Total Seguidores: ${vm.seguidores}',
              'Total Seguidos: ${vm.seguidos}',
            ], statsBlue),
          ],
        );
      },
    );
  }

  // --- COMPONENTES PREMIUM ---

  pw.Widget _buildPremiumHeader(String left, String right) {
    return pw.Container(
      height: 60,
      child: pw.Stack(
        children: [
          pw.Container(
            decoration: pw.BoxDecoration(
              color: statsBlue,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 20),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(left, style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 14)),
                pw.Text(right, style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 14)),
                pw.Text('${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year % 100}', style: pw.TextStyle(color: PdfColor(1, 1, 1, 0.8), fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildScoreCircle(String value, String label) {
    return pw.Column(
      children: [
        pw.Container(
          width: 80,
          height: 80,
          decoration: pw.BoxDecoration(
            borderRadius: pw.BorderRadius.circular(40),
            border: pw.Border.all(color: baseOrange, width: 4),
          ),
          alignment: pw.Alignment.center,
          child: pw.Text(value, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: baseOrange)),
        ),
        pw.SizedBox(height: 10),
        pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: darkGrey)),
      ],
    );
  }

  pw.Widget _buildActivityHistory(ReportViewModel vm) {
    final entries = vm.recetasPorMes.entries.toList();
    entries.sort((a, b) => a.key.compareTo(b.key));
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('ACTIVIDAD MENSUAL (RECETAS SUBIDAS)'),
        pw.SizedBox(height: 15),
        ...entries.map((e) {
          final monthNum = int.parse(e.key.split('-')[1]);
          final percentage = (e.value / (vm.recetasTotales > 0 ? vm.recetasTotales : 1));
          return pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            child: pw.Row(
              children: [
                pw.SizedBox(width: 80, child: pw.Text(_getMonthName(monthNum), style: const pw.TextStyle(fontSize: 9))),
                pw.Expanded(
                  child: pw.Stack(
                    alignment: pw.Alignment.centerLeft,
                    children: [
                      pw.Container(height: 12, decoration: pw.BoxDecoration(color: lightGrey, borderRadius: pw.BorderRadius.circular(6))),
                      pw.Container(
                        height: 12, 
                        width: percentage * 300, 
                        decoration: pw.BoxDecoration(color: statsBlue, borderRadius: pw.BorderRadius.circular(6))
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 40, child: pw.Text(' ${e.value}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  pw.Widget _buildGroupHeader(String title, PdfColor color) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 5),
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border(left: pw.BorderSide(color: color, width: 4)),
      ),
      child: pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: darkGrey)),
    );
  }

  pw.Widget _buildGroupFooter(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      alignment: pw.Alignment.centerRight,
      child: pw.Text(text, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: statsBlue)),
    );
  }

  pw.Widget _buildPremiumSummary(String title, List<String> lines, PdfColor color) {
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        color: lightGrey,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            height: 2,
            width: double.infinity,
            decoration: pw.BoxDecoration(
              color: color,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(8),
                topRight: pw.Radius.circular(8),
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(15),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: color, fontSize: 11)),
                pw.SizedBox(height: 8),
                ...lines.map((l) => pw.Bullet(text: l, style: const pw.TextStyle(fontSize: 9), bulletColor: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPremiumFooterStats(ReportViewModel vm) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
      children: [
        _buildMiniStat('SEGUIDORES', vm.seguidores.toString(), statsBlue),
        _buildMiniStat('SEGUIDOS', vm.seguidos.toString(), baseOrange),
      ],
    );
  }

  pw.Widget _buildMiniStat(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(value, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: color)),
        pw.Text(label, style: pw.TextStyle(fontSize: 8, color: darkGrey)),
      ],
    );
  }

  pw.Widget _buildSectionTitle(String title) {
    return pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: darkGrey));
  }

  String _getMonthName(int month) {
    const months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    return months[month - 1];
  }

  String _getDifficultyLabel(int d) {
    if (d <= 2) return 'Fácil';
    if (d <= 4) return 'Intermedio';
    return 'Experto';
  }
}
