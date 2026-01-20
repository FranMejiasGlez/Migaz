import 'package:migaz/core/config/routes.dart';
import 'package:flutter/material.dart';
import 'package:migaz/ui/widgets/recipe/user_avatar.dart';
import 'package:migaz/core/utils/responsive_helper.dart';
import 'package:migaz/core/utils/responsive_breakpoints.dart';
import 'package:migaz/core/config/api_config.dart';
import 'package:provider/provider.dart';
import 'package:migaz/viewmodels/user_viewmodel.dart';
import 'package:migaz/viewmodels/auth_viewmodel.dart';

class PantallaPerfilUser extends StatefulWidget {
  const PantallaPerfilUser({super.key});

  @override
  State<PantallaPerfilUser> createState() => _PantallaPerfilUserState();
}

class _PantallaPerfilUserState extends State<PantallaPerfilUser> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatos();
    });
  }

  void _cargarDatos() {
    final authViewModel = context.read<AuthViewModel>();
    final userId = authViewModel.currentUserId;
    if (userId.isNotEmpty) {
      context.read<UserViewModel>().loadUserProfile(userId);
    }
  }

  // --- ACCIONES ---

  // Seguir de vuelta a alguien que me sigue (lista izquierda)
  Future<void> _seguirUsuario(String targetUserId, String targetName) async {
    final authVM = context.read<AuthViewModel>();
    final userVM = context.read<UserViewModel>();

    final exito = await userVM.toggleFollow(authVM.currentUserId, targetUserId);
    if (exito && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("¡Ahora sigues a $targetName!"),
          backgroundColor: Colors.green,
          duration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  // Dejar de seguir (lista derecha)
  Future<void> _dejarDeSeguir(String targetUserId, String targetName) async {
    final authVM = context.read<AuthViewModel>();
    final userVM = context.read<UserViewModel>();

    final exito = await userVM.toggleFollow(authVM.currentUserId, targetUserId);
    if (exito && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Dejaste de seguir a $targetName"),
          backgroundColor: Colors.redAccent,
          duration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final isMobile = responsive.isMobile;

    return Scaffold(
      // backgroundColor: Colors.white, // Eliminado para usar el tema
      body: Consumer2<UserViewModel, AuthViewModel>(
        builder: (context, userVM, authVM, child) {
          if (userVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final seguidores = userVM.followers; // List<dynamic> (Map)
          final siguiendo = userVM.following; // List<dynamic> (Map)

          return SafeArea(
            child: Column(
              children: [
                SizedBox(height: 10 * responsive.scale),
                // HEADER RESPONSIVO
                _buildHeader(
                  context,
                  responsive,
                  authVM.currentUser,
                  userVM.userProfile?['profile_image'],
                ),

                SizedBox(height: 30 * responsive.scale),

                // ZONA DE LISTAS
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 10 : 20,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. COLUMNA IZQUIERDA: SEGUIDORES
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                "${seguidores.length} Seguidores",
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveBreakpoints.getScaledFontSize(
                                        context,
                                        18,
                                      ) *
                                      responsive.scale,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 20 * responsive.scale),
                              Expanded(
                                child: seguidores.isEmpty
                                    ? Center(
                                        child: Text(
                                          "Aún no tienes seguidores",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12 * responsive.scale,
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        itemCount: seguidores.length,
                                        itemBuilder: (context, index) {
                                          final user = seguidores[index];
                                          final userId = user['_id'];
                                          // Verifico si yo ya lo sigo
                                          final loSigo = siguiendo.any(
                                            (u) => u['_id'] == userId,
                                          );

                                          return UserCardIzquierdaStyle(
                                            name: user["username"] ?? 'Usuario',
                                            imageUrl:
                                                user["profile_image"], // Puede ser null
                                            isFollowing: loSigo,
                                            modoDerecha: false,
                                            responsive: responsive,
                                            onPressed: () => _seguirUsuario(
                                              userId,
                                              user["username"] ?? 'Usuario',
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),

                        // Separador
                        Container(
                          width: 1,
                          color: Colors.black12,
                          margin: EdgeInsets.symmetric(
                            horizontal: 8 * responsive.scale,
                          ),
                        ),

                        // 2. COLUMNA DERECHA: SEGUIDOS
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                "${siguiendo.length} Seguidos",
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveBreakpoints.getScaledFontSize(
                                        context,
                                        18,
                                      ) *
                                      responsive.scale,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 20 * responsive.scale),
                              Expanded(
                                child: siguiendo.isEmpty
                                    ? Center(
                                        child: Text(
                                          "No sigues a nadie aún",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12 * responsive.scale,
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        itemCount: siguiendo.length,
                                        itemBuilder: (context, index) {
                                          final user = siguiendo[index];
                                          final userId = user['_id'];

                                          return UserCardIzquierdaStyle(
                                            name: user["username"] ?? 'Usuario',
                                            imageUrl: user["profile_image"],
                                            isFollowing: true,
                                            modoDerecha: true,
                                            responsive: responsive,
                                            onPressed: () => _dejarDeSeguir(
                                              userId,
                                              user["username"] ?? 'Usuario',
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ResponsiveHelper responsive,
    String currentUserName,
    String? userImage,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0 * responsive.scale, vertical: 8.0),
      child: Column(
        children: [
          // Fila superior: Atrás y Ajustes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, size: 28 * responsive.scale),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.home),
                tooltip: 'Volver',
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.configuracion),
                  child: Icon(
                    Icons.settings_outlined,
                    size: 32 * responsive.scale,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          
          // Centro: Avatar, Nombre y Acciones (Adaptable y Perfectamente centrado)
          Builder(
            builder: (context) {
              final isWide = !responsive.isMobile;
              
              Widget avatarBlock = Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  UserAvatar(
                    imageUrl: userImage,
                    onTap: () {},
                    size: 70 * responsive.scale,
                  ),
                  SizedBox(height: 8 * responsive.scale),
                  Text(
                    currentUserName.isNotEmpty ? currentUserName : "Usuario",
                    style: TextStyle(
                      fontSize: 16 * responsive.scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              );

              Widget titleBlock = Container(
                constraints: BoxConstraints(minWidth: 150 * responsive.scale),
                decoration: BoxDecoration(
                  color: const Color(0xFFEA7317).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 24 * responsive.scale,
                  vertical: 12 * responsive.scale,
                ),
                child: Text(
                  'Mi Perfil',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20 * responsive.scale,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );

              Widget buttonsBlock = Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeaderButton(
                    context: context,
                    label: 'Biblioteca',
                    color: const Color(0xFF25CCAD),
                    icon: Icons.auto_stories,
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.biblioteca),
                    responsive: responsive,
                  ),
                  SizedBox(height: 12 * responsive.scale),
                  _buildHeaderButton(
                    context: context,
                    label: 'Reportes',
                    color: const Color(0xFF5B8DEE),
                    icon: Icons.bar_chart,
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.reporte),
                    responsive: responsive,
                    isPrimary: true,
                  ),
                ],
              );

              if (isWide) {
                // Modo Escritorio/Tablet: Simetría para centrado perfecto
                return Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: avatarBlock,
                      ),
                    ),
                    SizedBox(width: 48 * responsive.scale),
                    titleBlock,
                    SizedBox(width: 48 * responsive.scale),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: buttonsBlock,
                      ),
                    ),
                  ],
                );
              } else {
                // Modo Móvil: Stacking vertical
                return Column(
                  children: [
                    avatarBlock,
                    SizedBox(height: 24 * responsive.scale),
                    titleBlock,
                    SizedBox(height: 24 * responsive.scale),
                    buttonsBlock,
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required BuildContext context,
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
    required ResponsiveHelper responsive,
    bool isPrimary = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: isPrimary ? Colors.white : Colors.black,
        padding: EdgeInsets.symmetric(
          horizontal: 20 * responsive.scale,
          vertical: 10 * responsive.scale,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 3,
        minimumSize: Size(140 * responsive.scale, 40 * responsive.scale),
      ),
      icon: Icon(icon, size: 18 * responsive.scale),
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13 * responsive.scale,
        ),
      ),
    );
  }
}

class UserCardIzquierdaStyle extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final bool isFollowing;
  final bool modoDerecha;
  final VoidCallback onPressed;
  final ResponsiveHelper responsive;

  const UserCardIzquierdaStyle({
    super.key,
    required this.name,
    this.imageUrl,
    required this.isFollowing,
    required this.modoDerecha,
    required this.onPressed,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    String textoBoton = "";
    Color colorFondo = Colors.grey[200]!;
    Color colorTexto = Colors.black;
    IconData icono = Icons.add;
    VoidCallback? accionBoton = onPressed;

    if (modoDerecha) {
      textoBoton = "Dejar de seguir";
      colorFondo = const Color(0xFFFF6B6B);
      colorTexto = Colors.white;
      icono = Icons.remove;
    } else {
      if (isFollowing) {
        textoBoton = "Siguiendo";
        colorFondo = const Color(0xFF1CC4A8).withOpacity(0.2);
        colorTexto = const Color(0xFF0E6B5C);
        icono = Icons.check;
        accionBoton = null;
      } else {
        textoBoton = "Seguir";
        colorFondo = Colors.grey[200]!;
        colorTexto = Colors.black;
        icono = Icons.add;
      }
    }

    return Card(
      color: Colors.white.withOpacity(0.8),
      margin: EdgeInsets.only(bottom: 10 * responsive.scale),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 8 * responsive.scale,
          vertical: 8 * responsive.scale,
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18 * responsive.scale,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: NetworkImage(
                    ApiConfig.getImageUrl(imageUrl ?? ApiConfig.defaultProfileImage),
                  ),
                ),
                SizedBox(width: 8 * responsive.scale),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize:
                          ResponsiveBreakpoints.getScaledFontSize(context, 13) *
                          responsive.scale,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8 * responsive.scale),
            SizedBox(
              width: double.infinity,
              height: 32 * responsive.scale,
              child: ElevatedButton(
                onPressed: accionBoton,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorFondo,
                  disabledBackgroundColor: colorFondo,
                  disabledForegroundColor: colorTexto,
                  foregroundColor: colorTexto,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(
                    horizontal: 8 * responsive.scale,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icono, size: 14 * responsive.scale),
                    SizedBox(width: 4 * responsive.scale),
                    Flexible(
                      child: Text(
                        textoBoton,
                        style: TextStyle(
                          fontSize:
                              ResponsiveBreakpoints.getScaledFontSize(
                                context,
                                11,
                              ) *
                              responsive.scale,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
