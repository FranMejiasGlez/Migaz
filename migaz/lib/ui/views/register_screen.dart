// lib/ui/views/register_screen.dart
import 'package:flutter/material.dart';
import 'package:migaz/core/utils/resonsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:migaz/ui/widgets/auth/auth_logo.dart';
import 'package:migaz/ui/widgets/auth/auth_form_field.dart';
import 'package:migaz/core/theme/gradient_scaffold.dart';
import 'package:migaz/core/utils/responsive_helper.dart';
import 'package:migaz/core/config/routes.dart';
import 'package:migaz/ui/widgets/auth/user_credentials.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister(BuildContext context) async {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) {
      // Si el formulario no es válido, no seguimos
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Guardar credenciales en el Provider (ejemplo simple)
      final credentials = Provider.of<UserCredentials>(context, listen: false);
      credentials.setCredentials(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // Simular proceso de registro (puedes llamar a un ViewModel/repo real)
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      // Navegar al login reemplazando la ruta
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al registrar: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    // Estilo del botón principal del registro (ahora gris)
    final ButtonStyle registerButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.grey, // ← Cambiado a gris
      foregroundColor: Colors.black,
      padding: EdgeInsets.symmetric(vertical: 14 * responsive.scale),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    // Estilo del botón enlace (ir a login) en gris también
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
                        registerButtonStyle,
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
                        registerButtonStyle,
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
    ButtonStyle registerButtonStyle,
    ButtonStyle linkButtonStyle,
  ) {
    final logoMaxSize = (contentWidth * 0.22).clamp(56.0, 140.0);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AuthLogo(size: logoMaxSize * responsive.scale, isFlexible: true),
          SizedBox(height: 12 * responsive.scale),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.0),
            child: Text(
              "Regístrate en Migaz y empieza a cocinar. ¡Es rápido y fácil!",
              style: TextStyle(
                fontSize:
                    ResponsiveBreakpoints.getScaledFontSize(context, 15) *
                    responsive.scale,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              softWrap: true,
            ),
          ),
          SizedBox(height: 12 * responsive.scale),
          Text(
            "Regístrate",
            style: TextStyle(
              fontSize:
                  ResponsiveBreakpoints.getScaledFontSize(context, 20) *
                  responsive.scale,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16 * responsive.scale),

          // Campos
          AuthFormField(
            controller: _usernameController,
            labelText: 'Nombre de usuario',
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return 'Introduce un nombre de usuario';
              if (value.trim().length < 3) return 'Mínimo 3 caracteres';
              return null;
            },
          ),
          SizedBox(height: 12 * responsive.scale),
          AuthFormField(
            controller: _emailController,
            labelText: 'Correo electrónico',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return 'Introduce tu correo';
              final email = value.trim();
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(email)) return 'Correo inválido';
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
          SizedBox(height: 12 * responsive.scale),
          AuthFormField(
            controller: _confirmPasswordController,
            labelText: 'Confirmar contraseña',
            obscureText: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return 'Confirma tu contraseña';
              if (value.trim() != _passwordController.text.trim())
                return 'Las contraseñas no coinciden';
              return null;
            },
          ),
          SizedBox(height: 20 * responsive.scale),

          // Botón de registro (color gris)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : () => _handleRegister(context),
              style: registerButtonStyle,
              child: _isSubmitting
                  ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Crear cuenta',
                      style: TextStyle(
                        fontSize: 16 * responsive.scale,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 12 * responsive.scale),

          // Enlace al login (texto en gris)
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.login),
              style: linkButtonStyle,
              child: Text(
                '¿Ya tienes cuenta? Inicia sesión',
                style: TextStyle(fontSize: 14 * responsive.scale),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
