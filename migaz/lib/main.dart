import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:device_preview/device_preview.dart';
import 'package:migaz/core/config/api_config.dart';
import 'package:migaz/core/config/routes.dart';
import 'package:provider/provider.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/recipe_list_viewmodel.dart';
import 'viewmodels/comentario_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart';
import 'viewmodels/biblioteca_viewmodel.dart';
import 'viewmodels/user_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';

void main() {
  // ✅ Configura la URL pública de DevTunnel
  // IMPORTANTE: Actualiza esta URL cada vez que reinicies el túnel
  // ⚠️ NO incluir barra diagonal final
  ApiConfig.publicServerUrl = 'https://g107vtml-3000.uks1.devtunnels.ms';

  // ✅ Solo un runApp()
  runApp(
    // 🎨 DevicePreview solo en modo desarrollo
    DevicePreview(
      enabled: !kReleaseMode, // ✅ Solo en desarrollo, no en producción
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => RecipeListViewModel()),
        ChangeNotifierProvider(create: (_) => ComentarioViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => BibliotecaViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeViewModel, _) {
          return MaterialApp(
            title: 'Migaz - App de Recetas',
            debugShowCheckedModeBanner: false,
            theme: themeViewModel.currentTheme, // ✅ Tema dinámico
            // 🎨 Configuración para Device Preview (solo afecta en desarrollo)
            locale: DevicePreview.locale(context),
            builder: DevicePreview.appBuilder,

            initialRoute: AppRoutes.login,
            routes: AppRoutes.routes,
          );
        },
      ),
    );
  }
}
