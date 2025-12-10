import 'package:migaz/views/pantalla_biblioteca.dart';
import 'package:migaz/views/pantalla_guardados.dart';
import 'package:migaz/views/pantalla_misrecetas.dart';
import 'package:flutter/material.dart';
import '../views/login_screen.dart';
import '../views/register_screen.dart';
import '../views/pantalla_recetas.dart';
import '../views/pantalla_perfiluser.dart';

class AppRoutes {
  static const String login = '/';
  static const String register = '/register';
  static const String home = '/home';
  static const String biblioteca = '/biblioteca';
  static const String perfilUser = '/perfil';
  static const String guardados = '/biblioteca/guardados';
  static const String misrecetas = '/biblioteca/misrecetas';

  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      home: (context) => const PantallaRecetas(),
      biblioteca: (context) => const PantallaBiblioteca(),
      perfilUser: (context) => const PantallaPerfilUser(),
      guardados: (context) => const PantallaGuardados(),
      misrecetas: (context) => const PantallaMisRecetas(),
    };
  }
}
