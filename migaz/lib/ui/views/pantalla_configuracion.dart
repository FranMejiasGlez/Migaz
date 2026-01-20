import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../core/config/routes.dart';
import '../../core/config/api_config.dart';
import '../../core/utils/responsive_helper.dart';

class PantallaConfiguracion extends StatelessWidget {
  const PantallaConfiguracion({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _PantallaConfiguracionView();
  }
}

class _PantallaConfiguracionView extends StatefulWidget {
  const _PantallaConfiguracionView({Key? key}) : super(key: key);

  @override
  State<_PantallaConfiguracionView> createState() =>
      _PantallaConfiguracionViewState();
}

class _PantallaConfiguracionViewState
    extends State<_PantallaConfiguracionView> {
  // bool _modoOscuro = false; // Eliminado por ThemeViewModel
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // Cargar perfil completo si no está cargado (para tener la URL de la foto)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = context.read<AuthViewModel>();
      if (authVM.currentUserId.isNotEmpty) {
        context.read<UserViewModel>().loadUserProfile(authVM.currentUserId);
      }
    });
  }

  Future<void> _seleccionarFoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
      _actualizarFotoPerfil();
    }
  }

  Future<void> _actualizarFotoPerfil() async {
    if (_imageFile == null) return;

    setState(() => _isUploading = true);

    // 1. Validar extensión localmente antes de enviar
    final String extension = _imageFile!.name.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Formato no soportado. Usa JPG, PNG o WEBP.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      setState(() => _isUploading = false);
      return;
    }

    try {
      final authVM = context.read<AuthViewModel>();
      final userVM = context.read<UserViewModel>();

      // Enviamos solo la foto (mapa vacío para datos)
      final nuevoPerfil = await userVM.updateProfile(
        authVM.currentUserId,
        {},
        _imageFile,
      );

      if (nuevoPerfil != null) {
        // ÉXITO
        if (nuevoPerfil['profile_image'] != null) {
          await authVM.updateUserImage(nuevoPerfil['profile_image']);
        }
        await userVM.loadUserProfile(authVM.currentUserId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto de perfil actualizada'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // ERROR (devuelto como null por BaseViewModel)
        if (mounted) {
          String mensajeError =
              userVM.errorMessage ?? 'Error al subir la imagen';

          // Intentar hacer el mensaje más amigable
          if (mensajeError.contains('400') ||
              mensajeError.contains('415') ||
              mensajeError.toLowerCase().contains('format')) {
            mensajeError = 'Formato de imagen no válido. Prueba con JPG o PNG.';
          } else if (mensajeError.contains('413')) {
            mensajeError = 'La imagen es demasiado grande.';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(mensajeError), backgroundColor: Colors.red),
          );
        }
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
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuracion'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: responsive.maxWidth),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.horizontalPadding,
                vertical: 12.0, // Reducido para que empiece más arriba
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- HEADER CON NOMBRE Y AVATAR EN LA ESQUINA SUPERIOR DERECHA ---
                  Consumer2<AuthViewModel, UserViewModel>(
                    builder: (context, authVM, userVM, _) {
                      String? currentImageUrl = userVM.userProfile?['profile_image'];
    
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // AVATAR CLICKABLE
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: _seleccionarFoto,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 80 * responsive.scale,
                                        height: 80 * responsive.scale,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF25CCAD),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                          boxShadow: [
                                            BoxShadow(blurRadius: 5, color: Colors.black26),
                                          ],
                                          image: DecorationImage(
                                            image: _imageFile != null
                                                ? (kIsWeb
                                                    ? NetworkImage(_imageFile!.path)
                                                    : FileImage(File(_imageFile!.path)) as ImageProvider)
                                                : NetworkImage(
                                                    ApiConfig.getImageUrl(currentImageUrl ?? ""),
                                                  ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      if (_isUploading)
                                        CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2 * responsive.scale,
                                        ),
        
                                      if (!_isUploading)
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.camera_alt,
                                              size: 14 * responsive.scale,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 8 * responsive.scale),
                              Text(
                                authVM.currentUser.isNotEmpty ? authVM.currentUser : 'Usuario',
                                style: TextStyle(
                                  fontSize: 14 * responsive.scale,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
    
                  // --- TOGGLE MODO OSCURO ---
                  Consumer<ThemeViewModel>(
                    builder: (context, themeVM, _) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF25CCAD),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              themeVM.isDarkMode ? 'Modo Oscuro' : 'Modo Claro',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Switch(
                              value: themeVM.isDarkMode,
                              onChanged: (value) => themeVM.toggleTheme(value),
                              activeColor: const Color(0xFFFFC107),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
    
                  // --- SECCIÓN EDITAR PERFIL ---
                  _buildExpandableSection(
                    title: 'Editar perfil',
                    children: [
                      ListTile(
                        leading: const Icon(Icons.photo_camera),
                        title: const Text('Cambiar Foto de Perfil'),
                        onTap: _seleccionarFoto,
                      ),
                      const ListTile(
                        leading: Icon(Icons.email),
                        title: Text('Cambiar Correo (Próximamente)'),
                      ),
                      const ListTile(
                        leading: Icon(Icons.lock),
                        title: Text('Cambiar Contraseña (Próximamente)'),
                      ),
                    ],
                    backgroundColor: const Color(0xFFD4C5F9),
                  ),
                  const SizedBox(height: 24),
    
                  // --- SECCIÓN CONTACTANOS ---
                  _buildExpandableSection(
                    title: 'Contactanos',
                    children: [
                      const ListTile(
                        leading: Icon(Icons.email),
                        title: Text('fran.mejias.glez98@gmail.com'),
                      ),
                      const ListTile(
                        leading: Icon(Icons.code),
                        title: Text('Github Project'),
                        subtitle: Text('https://github.com/franmejiasglez/Migaz'),
                      ),
                    ],
                    backgroundColor: const Color(0xFFFFD9B3),
                  ),
                  const SizedBox(height: 32),
    
                  // --- BOTÓN CERRAR SESIÓN ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showLogoutDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3A4A5C),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Cerrar Sesión',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required List<Widget> children, // Cambiado de List<String> a List<Widget>
    required Color backgroundColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          trailing: const Icon(Icons.expand_more, color: Colors.black),
          children: children,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // Cerrar sesión
              await context.read<AuthViewModel>().logout();

              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
