// lib/ui/views/login_screen.dart
import 'package:migaz/core/utils/responsive_breakpoints.dart';
import 'package:migaz/ui/widgets/auth/user_credentials.dart';
import 'package:flutter/material.dart';
import '../widgets/auth/auth_logo.dart';
import '../widgets/auth/auth_form_field.dart';
import '../../core/theme/gradient_scaffold.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/config/routes.dart';
import 'package:provider/provider.dart';
import '../../core/constants/recipe_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginPruebaState();
}

class _LoginPruebaState extends State<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final credentials = Provider.of<UserCredentials>(context);
    if (credentials.hasCredentials) {
      _emailController.text = credentials.email;
      _passwordController.text = credentials.password;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      // TODO: llamar al ViewModel / autenticación real
      await Future.delayed(const Duration(milliseconds: 350));

      if (!mounted) return;
      Navigator.pushNamed(context, AppRoutes.home);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al iniciar sesión: $e')));
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

    return GradientScaffold(
      child: Center(
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
            controller: _emailController,
            labelText: 'Correo electrónico',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return 'Introduce tu correo';
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
              if (value.trim().length < 4) return 'Mínimo 4 caracteres';
              return null;
            },
          ),
          SizedBox(height: 20 * responsive.scale),

          // BOTÓN INICIAR SESIÓN (mantener estilo)
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

          // BOTÓN REGISTRARSE (mantener estilo visual)
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
