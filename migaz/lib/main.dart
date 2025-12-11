import 'package:flutter/material.dart';
import 'package:migaz/core/config/routes.dart';
import 'package:provider/provider.dart';
import 'ui/widgets/auth/user_credentials.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/recipe_list_viewmodel.dart';
import 'viewmodels/comentario_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserCredentials()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => RecipeListViewModel()),
        ChangeNotifierProvider(create: (_) => ComentarioViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
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
      routes: AppRoutes.routes,
    );
  }
}
