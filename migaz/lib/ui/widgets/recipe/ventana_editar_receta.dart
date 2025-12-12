import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:migaz/data/models/recipe.dart';

class DialogoEditarReceta extends StatefulWidget {
  final Recipe recetaOriginal;
  final List<String> categorias;
  final List<String> dificultades;

  const DialogoEditarReceta({
    Key? key,
    required this.recetaOriginal,
    required this.categorias,
    required this.dificultades,
  }) : super(key: key);

  @override
  State<DialogoEditarReceta> createState() => _DialogoEditarRecetaState();
}

class _DialogoEditarRecetaState extends State<DialogoEditarReceta> {
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _tiempoController;
  late TextEditingController _servingsController;
  late TextEditingController _ingredienteInputController;
  late TextEditingController _pasoInputController;
  late TextEditingController _youtubeController;

  late String _categoriaSeleccionada;
  late int _dificultadSeleccionada;

  late List<String> _ingredientes;
  late List<String> _pasos;
  late List<XFile> _imagenesEditadas; // Editadas solo durante edición
  late List<String> _imagenesPreviasUrls; // Imágenes originales si las hay
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Inicializar controllers con valores actuales
    _nombreController = TextEditingController(
      text: widget.recetaOriginal.nombre,
    );
    _descripcionController = TextEditingController(
      text: widget.recetaOriginal.descripcion,
    );
    _tiempoController = TextEditingController(
      text: widget.recetaOriginal.tiempo,
    );
    _servingsController = TextEditingController(
      text: widget.recetaOriginal.comensales.toString(),
    );
    _ingredienteInputController = TextEditingController();
    _pasoInputController = TextEditingController();
    _youtubeController = TextEditingController(
      text: widget.recetaOriginal.youtube ?? '',
    );

    _categoriaSeleccionada = widget.categorias.firstWhere(
      (c) => c.toLowerCase() == widget.recetaOriginal.categoria.toLowerCase(),
      orElse: () => widget.categorias[0],
    );
    _dificultadSeleccionada = widget.recetaOriginal.dificultad;
    _ingredientes = List<String>.from(widget.recetaOriginal.ingredientes);
    _pasos = List<String>.from(widget.recetaOriginal.pasos);

    // Convertir URLs originales en lista, si las usas. Aquí ignoramos su edición.
    _imagenesPreviasUrls = widget.recetaOriginal.imagenes ?? [];
    _imagenesEditadas = [];
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
          _imagenesEditadas.add(image);
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
          _imagenesEditadas.add(image);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al tomar foto: $e')));
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
          _imagenesEditadas.addAll(images);
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

  void _eliminarImagenEditada(int index) {
    setState(() {
      _imagenesEditadas.removeAt(index);
    });
  }

  void _eliminarImagenPrevia(int index) {
    setState(() {
      _imagenesPreviasUrls.removeAt(index);
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
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: Colors.orange,
                ),
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

    final servings = int.tryParse(_servingsController.text.trim()) ?? 1;
    final tiempo = _tiempoController.text.trim();

    final recetaEditada = widget.recetaOriginal.copyWith(
      nombre: nombre,
      categoria: _categoriaSeleccionada,
      descripcion: _descripcionController.text.trim(),
      dificultad: _dificultadSeleccionada,
      comensales: servings,
      tiempo: tiempo,
      pasos: List<String>.from(_pasos),
      ingredientes: List<String>.from(_ingredientes),
      youtube: _youtubeController.text.trim(),
      // Comentarios y valoración se mantienen
    );

    Navigator.of(context).pop({
      'receta': recetaEditada,
      'imagenesNuevas': _imagenesEditadas,
      'imagenesPrevias': _imagenesPreviasUrls,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar receta'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
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
                  hintText: 'https://youtube.com/.. .',
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
                  leading: Text('${entry.key + 1}.  '),
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
        ElevatedButton(onPressed: _onGuardar, child: const Text('Guardar')),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_imagenesPreviasUrls.isEmpty && _imagenesEditadas.isEmpty)
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
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ..._imagenesPreviasUrls.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final url = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            url,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _eliminarImagenPrevia(idx),
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
                }),
                ..._imagenesEditadas.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final image = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildImagePreview(image),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _eliminarImagenEditada(idx),
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
                }),
              ],
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
