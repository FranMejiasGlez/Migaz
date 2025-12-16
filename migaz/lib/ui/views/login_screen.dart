// lib/ui/views/login_screen.dart
import 'package:migaz/core/utils/responsive_breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:migaz/viewmodels/auth_viewmodel.dart';
import '../widgets/auth/auth_logo.dart';
import '../widgets/auth/auth_form_field.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/config/routes.dart';
import 'package:provider/provider.dart';
import '../../core/constants/recipe_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _identifierController;
  late TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _identifierController = TextEditingController();
    _passwordController = TextEditingController();

    // Verificar sesión al inicio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSession();
    });
  }

  Future<void> _checkSession() async {
    final authViewModel = context.read<AuthViewModel>();
    final hasSession = await authViewModel.checkSession();
    if (hasSession && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final authViewModel = context.read<AuthViewModel>();
      final success = await authViewModel.login(
        _identifierController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar sesión'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    // Botón principal: usar estilo de la app (fallback si no hay tema)
    final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.grey,
      foregroundColor: Colors.black,
      padding: EdgeInsets.symmetric(vertical: 14 * responsive.scale),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: RecipeConstants.buttonElevation,
      textStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16 * responsive.scale,
      ),
    );

    // Enlace / secundario (registrarse)
    final ButtonStyle linkButtonStyle = TextButton.styleFrom(
      foregroundColor: Colors.black,
      textStyle: TextStyle(fontSize: 14 * responsive.scale),
    );

    return Scaffold(
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = constraints.maxWidth > responsive.maxWidth
                ? responsive.maxWidth
                : constraints.maxWidth * 0.95;

            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth),
              child: responsive.needsScroll
                  ? SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.horizontalPadding,
                        vertical: 20,
                      ),
                      child: _buildContent(
                        context,
                        responsive,
                        contentWidth,
                        primaryButtonStyle,
                        linkButtonStyle,
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.horizontalPadding,
                        vertical: 20,
                      ),
                      child: _buildContent(
                        context,
                        responsive,
                        contentWidth,
                        primaryButtonStyle,
                        linkButtonStyle,
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ResponsiveHelper responsive,
    double contentWidth,
    ButtonStyle primaryButtonStyle,
    ButtonStyle linkButtonStyle,
  ) {
    final logoMaxSize = (contentWidth * 0.28).clamp(60.0, 160.0);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AuthLogo(size: logoMaxSize * responsive.scale, isFlexible: true),
          SizedBox(height: 16 * responsive.scale),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "Bienvenido a Migaz. ¿Preparado para cocinar?",
              style: TextStyle(
                fontSize:
                    ResponsiveBreakpoints.getScaledFontSize(context, 16) *
                    responsive.scale,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              softWrap: true,
            ),
          ),
          SizedBox(height: 12 * responsive.scale),
          Text(
            "Iniciar Sesión",
            style: TextStyle(
              fontSize:
                  ResponsiveBreakpoints.getScaledFontSize(context, 22) *
                  responsive.scale,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20 * responsive.scale),

          // Campos
          AuthFormField(
            controller: _identifierController,
            labelText: 'Correo electrónico o Usuario',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return 'Introduce tu correo o usuario';
              return null;
            },
          ),
          SizedBox(height: 12 * responsive.scale),
          AuthFormField(
            controller: _passwordController,
            labelText: 'Contraseña',
            obscureText: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return 'Introduce tu contraseña';
              return null;
            },
          ),
          SizedBox(height: 20 * responsive.scale),

          // BOTÓN INICIAR SESIÓN
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleLogin,
              style: primaryButtonStyle,
              child: _isSubmitting
                  ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Text('Entrar'),
            ),
          ),
          SizedBox(height: 12 * responsive.scale),

          // BOTÓN REGISTRARSE
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
              style: linkButtonStyle,
              child: const Text('Crear cuenta'),
            ),
          ),
        ],
      ),
    );
  }
}
