import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/data/services/categoria_service.dart';

class DialogoCrearReceta extends StatefulWidget {
  final List<String> dificultades;

  const DialogoCrearReceta({
    Key? key,
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
  final TextEditingController _ingredienteInputController = TextEditingController();
  final TextEditingController _pasoInputController = TextEditingController();
  final TextEditingController _youtubeController = TextEditingController();
  
  final CategoriaService _categoriaService = CategoriaService();
  List<String> _categorias = [];
  bool _isLoadingCategorias = true;

  String _categoriaSeleccionada = '';
  int _dificultadSeleccionada = 3;

  final List<String> _ingredientes = [];
  final List<String> _pasos = [];
  final List<XFile> _imagenesSeleccionadas = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  // ✅ NUEVO: Cargar categorías desde la BD
  Future<void> _cargarCategorias() async {
    try {
      final categorias = await _categoriaService.obtenerCategorias();
      setState(() {
        // Filtrar "Todos" ya que no es una categoría válida para crear
        _categorias = categorias.where((c) => c != 'Todos').toList();
        _categoriaSeleccionada = _categorias.isNotEmpty ? _categorias[0] : '';
        _isLoadingCategorias = false;
      });
    } catch (e) {
      print('❌ Error al cargar categorías: $e');
      setState(() {
        // Fallback a categorías por defecto
        _categorias = ['Española', 'Italiana', 'Mexicana', 'Asiática', 'Postre'];
        _categoriaSeleccionada = _categorias[0];
        _isLoadingCategorias = false;
      });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _tiempoController.dispose();
    _servingsController.dispose();
    _ingredienteInputController.dispose();
    _pasoInputController.dispose();
    _youtubeController.dispose();
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

  Future<void> _seleccionarImagenGaleria() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imagenesSeleccionadas.add(image);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  Future<void> _tomarFoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imagenesSeleccionadas.add(image);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al tomar foto: $e')),
        );
      }
    }
  }

  Future<void> _seleccionarMultiplesImagenes() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        setState(() {
          _imagenesSeleccionadas.addAll(images);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imágenes: $e')),
        );
      }
    }
  }

  void _eliminarImagen(int index) {
    setState(() {
      _imagenesSeleccionadas.removeAt(index);
    });
  }

  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Galería'),
                onTap: () {
                  Navigator.pop(context);
                  _seleccionarImagenGaleria();
                },
              ),
              if (!kIsWeb)
                ListTile(
                  leading: const Icon(Icons.photo_camera, color: Colors.green),
                  title: const Text('Cámara'),
                  onTap: () {
                    Navigator.pop(context);
                    _tomarFoto();
                  },
                ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: Colors.orange),
                title: const Text('Múltiples imágenes'),
                onTap: () {
                  Navigator.pop(context);
                  _seleccionarMultiplesImagenes();
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('Cancelar'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onGuardar() {
    final nombre = _nombreController.text.trim();

    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce un nombre para la receta')),
      );
      return;
    }

    if (_categoriaSeleccionada.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una categoría')),
      );
      return;
    }

    final servings = int.tryParse(_servingsController.text.trim()) ?? 1;
    final tiempo = _tiempoController.text.trim();

    final nueva = Recipe(
      nombre: nombre,
      categoria: _categoriaSeleccionada,
      descripcion: _descripcionController.text.trim(),
      dificultad: _dificultadSeleccionada,
      comensales: servings,
      tiempo: tiempo,
      pasos: List<String>.from(_pasos),
      ingredientes: List<String>.from(_ingredientes),
      comentarios: [],
      valoracion: 0,
    );

    Navigator.of(context).pop({
      'receta': nueva,
      'youtube': _youtubeController.text.trim(),
      'imagenes': _imagenesSeleccionadas,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crear nueva receta'),
      content: SizedBox(
        width: double.maxFinite,
        child: _isLoadingCategorias
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nombreController,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                    ),
                    const SizedBox(height: 8),

                    // ✅ Categoría con datos dinámicos
                    DropdownButtonFormField<String>(
                      value: _categoriaSeleccionada.isNotEmpty ? _categoriaSeleccionada : null,
                      items: _categorias
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(
                        () => _categoriaSeleccionada = v ?? _categoriaSeleccionada,
                      ),
                      decoration: const InputDecoration(labelText: 'Categoría'),
                    ),
                    const SizedBox(height: 8),

                    // Dificultad
                    DropdownButtonFormField<int>(
                      value: _dificultadSeleccionada,
                      decoration: const InputDecoration(labelText: 'Dificultad'),
                      items: const [
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
                    const SizedBox(height: 8),

                    TextField(
                      controller: _youtubeController,
                      decoration: const InputDecoration(
                        labelText: 'Video YouTube (opcional)',
                        hintText: 'https://youtube.com/...',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sección de imágenes
                    _buildImagenesSection(),
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
                    const Text(
                      'Pasos',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _pasoInputController,
                            decoration: const InputDecoration(
                              hintText: 'Añadir paso',
                            ),
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoadingCategorias ? null : _onGuardar,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  Widget _buildImagenesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Imágenes',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: _mostrarOpcionesImagen,
              icon: const Icon(Icons.add_photo_alternate, size: 20),
              label: const Text('Añadir'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_imagenesSeleccionadas.isEmpty)
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined, size: 40, color: Colors.grey[600]),
                  const SizedBox(height: 8),
                  Text(
                    'No hay imágenes',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _imagenesSeleccionadas.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildImagePreview(_imagenesSeleccionadas[index]),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _eliminarImagen(index),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildImagePreview(XFile image) {
    if (kIsWeb) {
      return FutureBuilder<Uint8List>(
        future: image.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            );
          }
          return Container(
            width: 120,
            height: 120,
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      );
    } else {
      return Image.file(
        File(image.path),
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    }
  }
}