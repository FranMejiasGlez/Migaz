import 'package:flutter/material.dart';

/// Campo de formulario reutilizable para autenticación.
/// - Soporta TextFormField (validator) y TextField (onChanged) según uso.
/// - Acepta parámetros compatibles con el uso en `login_screen.dart`:
///   controller, labelText, keyboardType, obscureText, validator, onChanged, scale.
class AuthFormField extends StatelessWidget {
  final String? labelText;
  final bool obscureText;
  final double? scale;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final String? initialValue;
  final bool autovalidate;

  const AuthFormField({
    Key? key,
    this.labelText,
    this.obscureText = false,
    this.scale,
    this.controller,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.initialValue,
    this.autovalidate = false,
  }) : super(key: key);

  double _effectiveScale(BuildContext context) {
    if (scale != null) return scale!;
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 0.9;
    if (width < 600) return 1.0;
    return 1.05;
  }

  @override
  Widget build(BuildContext context) {
    final s = _effectiveScale(context);

    // Label arriba + caja de estilo consistente
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if ((labelText ?? '').isNotEmpty) ...[
          Text(
            labelText!,
            style: TextStyle(fontSize: 14 * s, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4 * s),
        ],
        // Fondo coloreado y TextFormField integrado para validación
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF4F5D75),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8 * s),
            child: TextFormField(
              controller: controller,
              initialValue: controller == null ? initialValue : null,
              obscureText: obscureText,
              keyboardType: keyboardType,
              validator: validator,
              autovalidateMode: autovalidate
                  ? AutovalidateMode.always
                  : AutovalidateMode.disabled,
              onChanged: onChanged,
              style: TextStyle(fontSize: 14 * s, color: Colors.white),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8 * s,
                  vertical: 12 * s,
                ),
                isDense: true,
                // Mantener hintText opcionalmente si se desea
              ),
            ),
          ),
        ),
      ],
    );
  }
}
