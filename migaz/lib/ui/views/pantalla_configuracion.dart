import 'package:flutter/material.dart';

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
  bool _modoOscuro = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Config usuario [S]'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // --- HEADER CON NOMBRE Y AVATAR ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nombre Usuario',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF25CCAD),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- TOGGLE MODO CLARO/OSCURO ---
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF25CCAD),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Modo claro',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Switch(
                      value: _modoOscuro,
                      onChanged: (value) {
                        setState(() {
                          _modoOscuro = value;
                        });
                      },
                      activeColor: const Color(0xFFFFC107),
                      inactiveThumbColor: Colors.grey,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- SECCIÓN EDITAR PERFIL ---
              _buildExpandableSection(
                title: 'Editar perfil',
                items: ['Cambiar Foto', 'Cambiar Correo', 'Cambiar Contraseña'],
                backgroundColor: const Color(0xFFD4C5F9),
              ),
              const SizedBox(height: 24),

              // --- SECCIÓN CONTACTANOS ---
              _buildExpandableSection(
                title: 'Contactanos',
                items: [
                  'Email: adjaki@falfasd@gmail.com',
                  'Github: https://github.com/adjaki/falfasd/PROYECTO_APP_RECETAS',
                ],
                backgroundColor: const Color(0xFFFFD9B3),
              ),
              const SizedBox(height: 32),

              // --- BOTÓN CERRAR SESIÓN ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A4A5C),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required List<String> items,
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          trailing: const Icon(Icons.expand_more),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(item),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
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
            onPressed: () {
              Navigator.pop(context);
              // Aquí iría la lógica para cerrar sesión
              //print('Sesión cerrada');
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
