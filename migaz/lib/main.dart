import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/routes.dart';
import 'ui/widgets/auth/user_credentials.dart';
import 'viewmodels/auth_viewmodel.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserCredentials()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: const MyApp(),
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
      initialRoute: AppRoutes.login,
      // usa el mapa de rutas definido en config/routes.dart
      routes: AppRoutes.routes,
    );
  }
}
