import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/data/services/categoria_service.dart';
import 'package:migaz/core/utils/responsive_helper.dart';
import 'package:migaz/core/config/api_config.dart';

class DialogoEditarReceta extends StatefulWidget {
  final Recipe recetaOriginal;
  final List<String> dificultades;

  const DialogoEditarReceta({
    Key? key,
    required this.recetaOriginal,
    required this.dificultades,
  }) : super(key: key);

  @override
  State<DialogoEditarReceta> createState() => _DialogoEditarRecetaState();
}

class _DialogoEditarRecetaState extends State<DialogoEditarReceta> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _tiempoController;
  late TextEditingController _servingsController;
  late TextEditingController _ingredienteInputController;
  late TextEditingController _pasoInputController;
  late TextEditingController _youtubeController;

  final CategoriaService _categoriaService = CategoriaService();
  List<String> _categorias = [];
  bool _isLoadingCategorias = true;

  late String _categoriaSeleccionada;
  late int _dificultadSeleccionada;

  late List<String> _ingredientes;
  late List<String> _pasos;
  late List<XFile> _imagenesEditadas;
  late List<String> _imagenesPreviasUrls;
  final ImagePicker _picker = ImagePicker();

  String? _errorIngredientes;
  String? _errorPasos;

  @override
  void initState() {
    super.initState();
    _inicializarControllers();
    _cargarCategorias();
  }

  void _inicializarControllers() {
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

    _categoriaSeleccionada = widget.recetaOriginal.categoria;
    _dificultadSeleccionada = widget.recetaOriginal.dificultad;
    _ingredientes = List<String>.from(widget.recetaOriginal.ingredientes);
    _pasos = List<String>.from(widget.recetaOriginal.pasos);

    // ✅ CAMBIO 1: Crear una copia nueva de la lista para romper la referencia
    _imagenesPreviasUrls = List<String>.from(
      widget.recetaOriginal.imagenes ?? [],
    );

    _imagenesEditadas = [];
  }

  Future<void> _cargarCategorias() async {
    try {
      final categorias = await _categoriaService.obtenerCategorias();
      setState(() {
        _categorias = categorias.where((c) => c != 'Todos').toList();

        if (!_categorias.contains(_categoriaSeleccionada) &&
            _categorias.isNotEmpty) {
          _categoriaSeleccionada = _categorias[0];
        }

        _isLoadingCategorias = false;
      });
    } catch (e) {
      //print('❌ Error al cargar categorías: $e');
      setState(() {
        _categorias = [
          'española',
          'italiana',
          'mexicana',
          'japonesa',
          'china',
          'vegetariana',
        ];
        if (!_categorias.contains(_categoriaSeleccionada)) {
          _categoriaSeleccionada = _categorias[0];
        }
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
      _errorIngredientes = null;
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
      _errorPasos = null;
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
    setState(() {
      _errorIngredientes = null;
      _errorPasos = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_ingredientes.isEmpty) {
      setState(() {
        _errorIngredientes = 'Añade al menos un ingrediente';
      });
      return;
    }

    if (_pasos.isEmpty) {
      setState(() {
        _errorPasos = 'Añade al menos un paso';
      });
      return;
    }

    final servings = int.tryParse(_servingsController.text.trim()) ?? 1;
    final tiempo = _tiempoController.text.trim();

    final recetaEditada = widget.recetaOriginal.copyWith(
      nombre: _nombreController.text.trim(),
      categoria: _categoriaSeleccionada,
      descripcion: _descripcionController.text.trim(),
      dificultad: _dificultadSeleccionada,
      comensales: servings,
      tiempo: tiempo,
      pasos: List<String>.from(_pasos),
      ingredientes: List<String>.from(_ingredientes),
      youtube: _youtubeController.text.trim(),

      // ✅ CAMBIO 2: Asignar la lista de imágenes modificada al objeto
      imagenes: List<String>.from(_imagenesPreviasUrls),
    );

    Navigator.of(context).pop({
      'receta': recetaEditada,
      'imagenesNuevas': _imagenesEditadas,
      'imagenesPrevias': _imagenesPreviasUrls,
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    return AlertDialog(
      title: const Text('Editar receta'),
      content: SizedBox(
        width: responsive.isDesktop
            ? responsive.screenWidth * 0.4
            : responsive.isTablet
            ? responsive.screenWidth * 0.6
            : responsive.screenWidth * 0.9,
        height: responsive.isDesktop
            ? responsive.screenHeight * 0.6
            : responsive.isTablet
            ? responsive.screenHeight * 0.7
            : responsive.screenHeight * 0.8,
        child: _isLoadingCategorias
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre *',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El nombre es obligatorio';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      DropdownButtonFormField<String>(
                        value: _categoriaSeleccionada,
                        items: _categorias
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                        onChanged: (v) => setState(
                          () => _categoriaSeleccionada =
                              v ?? _categoriaSeleccionada,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Categoría *',
                        ),
                      ),
                      const SizedBox(height: 8),

                      DropdownButtonFormField<int>(
                        value: _dificultadSeleccionada,
                        decoration: const InputDecoration(
                          labelText: 'Dificultad',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 1,
                            child: Text('⭐ Muy Fácil'),
                          ),
                          DropdownMenuItem(value: 2, child: Text('⭐⭐ Fácil')),
                          DropdownMenuItem(value: 3, child: Text('⭐⭐⭐ Medio')),
                          DropdownMenuItem(
                            value: 4,
                            child: Text('⭐⭐⭐⭐ Difícil'),
                          ),
                          DropdownMenuItem(
                            value: 5,
                            child: Text('⭐⭐⭐⭐⭐ Muy Difícil'),
                          ),
                        ],
                        onChanged: (v) => setState(
                          () => _dificultadSeleccionada =
                              v ?? _dificultadSeleccionada,
                        ),
                      ),

                      TextFormField(
                        controller: _tiempoController,
                        decoration: const InputDecoration(
                          labelText: 'Tiempo total *',
                          hintText: 'Ej: 30 min',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El tiempo es obligatorio';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _servingsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Comensales *',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Los comensales son obligatorios';
                          }
                          final num = int.tryParse(value.trim());
                          if (num == null || num <= 0) {
                            return 'Debe ser un número mayor a 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _descripcionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                        ),
                      ),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _youtubeController,
                        decoration: const InputDecoration(
                          labelText: 'Video YouTube (opcional)',
                          hintText: 'https://youtube.com/...',
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildImagenesSection(),
                      const SizedBox(height: 16),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Ingredientes *',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${_ingredientes.length})',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          if (_errorIngredientes != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                _errorIngredientes!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _ingredienteInputController,
                              decoration: const InputDecoration(
                                hintText: 'Añadir ingrediente',
                              ),
                              onSubmitted: (_) => _agregarIngrediente(),
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

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Pasos *',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${_pasos.length})',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          if (_errorPasos != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                _errorPasos!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _pasoInputController,
                              decoration: const InputDecoration(
                                hintText: 'Añadir paso',
                              ),
                              onSubmitted: (_) => _agregarPaso(),
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

  // ✅ CAMBIO 3: Método reconstruido con validación de URL y manejo de errores
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
                  final rawUrl = entry.value;

                  // ✅ SOLUCIÓN: Usamos el método centralizado.
                  // Esto funcionará en Web (localhost) y Android (10.0.2.2) automáticamente.
                  final fullUrl = ApiConfig.getImageUrl(rawUrl);

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            fullUrl,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            // Agregamos manejo de errores visual para depurar
                            errorBuilder: (context, error, stackTrace) {
                              // print('Error cargando: $fullUrl'); // Descomenta para ver la URL exacta en consola
                              return Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey[300],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                                    Text(
                                      'Error',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        // ... (resto del código del botón de borrar igual que antes) ...
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
