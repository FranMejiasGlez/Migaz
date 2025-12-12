// lib/core/utils/responsive_helper.dart
import 'package:flutter/material.dart';
import 'package:migaz/core/utils/resonsive_breakpoints.dart';

class ResponsiveHelper {
  final BuildContext context;

  ResponsiveHelper(this.context);

  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  // ✅ MEJORADO: Escala basada en breakpoints reales
  double get scale {
    if (screenWidth < 360) return 0.85; // Móviles muy pequeños
    if (screenWidth < ResponsiveBreakpoints.mobile) return 1.0; // Móvil normal
    if (screenWidth < ResponsiveBreakpoints.tablet)
      return 1.1; // Tablet pequeño
    if (screenWidth < ResponsiveBreakpoints.desktop)
      return 1.2; // Tablet grande
    return (screenWidth / 1200).clamp(1.0, 1.5); // Desktop
  }

  // ✅ MEJORADO:   Ancho máximo adaptativo
  double get maxWidth {
    if (screenWidth >= ResponsiveBreakpoints.desktop) return 800.0;
    if (screenWidth >= ResponsiveBreakpoints.tablet) return 600.0;
    if (screenWidth >= ResponsiveBreakpoints.mobile) return screenWidth * 0.9;
    return screenWidth * 0.95; // Móviles pequeños:  95% del ancho
  }

  bool get needsScroll => screenHeight <= 640;
  bool get isTablet => screenWidth >= ResponsiveBreakpoints.mobile;
  bool get isDesktop => screenWidth >= ResponsiveBreakpoints.desktop;
  bool get isMobile => screenWidth < ResponsiveBreakpoints.mobile;

  // ✅ NUEVO: Número de columnas para grids
  int get gridColumns => ResponsiveBreakpoints.getGridColumns(context);

  // ✅ NUEVO: Padding horizontal adaptativo
  double get horizontalPadding =>
      ResponsiveBreakpoints.getHorizontalPadding(context);
}
