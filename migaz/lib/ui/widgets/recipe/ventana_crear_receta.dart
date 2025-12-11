import 'package:flutter/material.dart';
import 'package:migaz/data/models/recipe.dart';

class DialogoCrearReceta extends StatefulWidget {
  final List<String> categorias;
  final List<String> dificultades; // ✅ Ahora solo labels

  const DialogoCrearReceta({
    Key? key,
    required this.categorias,
    required this.dificultades,
  }) : super(key: key);

  @override
  State<DialogoCrearReceta> createState() => _DialogoCrearRecetaState();
}

class _DialogoCrearRecetaState extends State<DialogoCrearReceta> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _tiempoController = TextEditingController();
  final TextEditingController _servingsController = TextEditingController();
  final TextEditingController _ingredienteInputController =
      TextEditingController();
  final TextEditingController _pasoInputController = TextEditingController();

  String _categoriaSeleccionada = '';
  int _dificultadSeleccionada =
      3; // ✅ CAMBIADO: String → int (por defecto:  Medio)

  final List<String> _ingredientes = [];
  final List<String> _pasos = [];

  @override
  void initState() {
    super.initState();
    _categoriaSeleccionada = widget.categorias.isNotEmpty
        ? widget.categorias[0]
        : 'Española';
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _tiempoController.dispose();
    _servingsController.dispose();
    _ingredienteInputController.dispose();
    _pasoInputController.dispose();
    super.dispose();
  }

  void _agregarIngrediente() {
    final text = _ingredienteInputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _ingredientes.add(text);
      _ingredienteInputController.clear();
    });
  }

  void _quitarIngrediente(int index) {
    setState(() => _ingredientes.removeAt(index));
  }

  void _agregarPaso() {
    final text = _pasoInputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _pasos.add(text);
      _pasoInputController.clear();
    });
  }

  void _quitarPaso(int index) {
    setState(() => _pasos.removeAt(index));
  }

  void _onGuardar() {
    final nombre = _nombreController.text.trim();

    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce un nombre para la receta')),
      );
      return;
    }

    final servings = int.tryParse(_servingsController.text.trim()) ?? 1;
    final tiempo = _tiempoController.text.trim();

    final nueva = Recipe(
      nombre: nombre,
      categoria: _categoriaSeleccionada,
      descripcion: _descripcionController.text.trim(),
      dificultad: _dificultadSeleccionada, // ✅ int
      comensales: servings,
      tiempo: tiempo,
      pasos: List<String>.from(_pasos),
      ingredientes: List<String>.from(_ingredientes),
      comentarios: [],
      valoracion: 0,
    );

    Navigator.of(context).pop(nueva);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crear nueva receta'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 8),

            // Categoría
            DropdownButtonFormField<String>(
              value: _categoriaSeleccionada,
              items: widget.categorias
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(
                () => _categoriaSeleccionada = v ?? _categoriaSeleccionada,
              ),
              decoration: const InputDecoration(labelText: 'Categoría'),
            ),
            const SizedBox(height: 8),

            // ✅ NUEVO: Dificultad con estrellas
            DropdownButtonFormField<int>(
              value: _dificultadSeleccionada,
              decoration: const InputDecoration(labelText: 'Dificultad'),
              items: [
                DropdownMenuItem(value: 1, child: Text('⭐ Muy Fácil')),
                DropdownMenuItem(value: 2, child: Text('⭐⭐ Fácil')),
                DropdownMenuItem(value: 3, child: Text('⭐⭐⭐ Medio')),
                DropdownMenuItem(value: 4, child: Text('⭐⭐⭐⭐ Difícil')),
                DropdownMenuItem(value: 5, child: Text('⭐⭐⭐⭐⭐ Muy Difícil')),
              ],
              onChanged: (v) => setState(
                () => _dificultadSeleccionada = v ?? _dificultadSeleccionada,
              ),
            ),

            TextField(
              controller: _tiempoController,
              decoration: const InputDecoration(labelText: 'Tiempo total'),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _servingsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Comensales'),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _descripcionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            const SizedBox(height: 16),

            // Ingredientes
            const Text(
              'Ingredientes',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ingredienteInputController,
                    decoration: const InputDecoration(
                      hintText: 'Añadir ingrediente',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _agregarIngrediente,
                ),
              ],
            ),
            ..._ingredientes.asMap().entries.map((entry) {
              return ListTile(
                title: Text(entry.value),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _quitarIngrediente(entry.key),
                ),
              );
            }).toList(),
            const SizedBox(height: 16),

            // Pasos
            const Text('Pasos', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pasoInputController,
                    decoration: const InputDecoration(hintText: 'Añadir paso'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _agregarPaso,
                ),
              ],
            ),
            ..._pasos.asMap().entries.map((entry) {
              return ListTile(
                leading: Text('${entry.key + 1}. '),
                title: Text(entry.value),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _quitarPaso(entry.key),
                ),
              );
            }).toList(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(onPressed: _onGuardar, child: const Text('Guardar')),
      ],
    );
  }
}
