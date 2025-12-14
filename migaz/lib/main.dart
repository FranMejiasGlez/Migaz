import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:device_preview/device_preview.dart';
import 'package:migaz/core/config/routes.dart';
import 'package:provider/provider.dart';
import 'ui/widgets/auth/user_credentials.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/recipe_list_viewmodel.dart';
import 'viewmodels/comentario_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart';
import 'viewmodels/biblioteca_viewmodel.dart';

void main() {
  runApp(
    // 🎨 NUEVO: Envolver con DevicePreview
    DevicePreview(
      enabled: !kReleaseMode, // ✅ Solo en desarrollo, no en producción
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserCredentials()),
          ChangeNotifierProvider(create: (_) => AuthViewModel()),
          ChangeNotifierProvider(create: (_) => RecipeListViewModel()),
          ChangeNotifierProvider(create: (_) => ComentarioViewModel()),
          ChangeNotifierProvider(create: (_) => HomeViewModel()),
          ChangeNotifierProvider(create: (_) => BibliotecaViewModel()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Migaz - App de Recetas',
      debugShowCheckedModeBanner: false,

      // 🎨 NUEVO: Configuración para Device Preview
      useInheritedMediaQuery: true, // ✅ Necesario para Device Preview
      locale: DevicePreview.locale(context), // ✅ Soporte de idiomas
      builder: DevicePreview.appBuilder, // ✅ Wrapper de Device Preview

      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}
