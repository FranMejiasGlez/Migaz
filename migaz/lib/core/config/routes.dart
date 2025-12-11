import 'package:migaz/ui/views/pantalla_biblioteca.dart';
import 'package:migaz/ui/views/pantalla_guardados.dart';
import 'package:migaz/ui/views/pantalla_misrecetas.dart';
import 'package:flutter/material.dart';
import '../../ui/views/login_screen.dart';
import '../../ui/views/register_screen.dart';
import '../../ui/views/pantalla_recetas.dart';
import '../../ui/views/pantalla_perfiluser.dart';
import '../../ui/views/pantalla_configuracion.dart';

class AppRoutes {
  static const String login = '/';
  static const String register = '/register';
  static const String home = '/home';
  static const String biblioteca = '/biblioteca';
  static const String perfilUser = '/perfil';
  static const String guardados = '/biblioteca/guardados';
  static const String misrecetas = '/biblioteca/misrecetas';
  static const String configuracion = '/perfil/configuracion';
  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      home: (context) => const PantallaRecetas(),
      biblioteca: (context) => const PantallaBiblioteca(),
      perfilUser: (context) => const PantallaPerfilUser(),
      guardados: (context) => const PantallaGuardados(),
      misrecetas: (context) => const PantallaMisRecetas(),
      configuracion: (context) => const PantallaConfiguracion(),
    };
  }
}
