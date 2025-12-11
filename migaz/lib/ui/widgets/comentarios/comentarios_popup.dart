import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/viewmodels/comentario_viewmodel.dart';

class ComentariosPopup extends StatefulWidget {
  final Recipe recipe;
  final String currentUserName;

  const ComentariosPopup({
    Key? key,
    required this.recipe,
    required this.currentUserName,
  }) : super(key: key);

  @override
  State<ComentariosPopup> createState() => _ComentariosPopupState();

  static void show({
    required BuildContext context,
    required Recipe recipe,
    required String currentUserName,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ChangeNotifierProvider(
          create: (_) => ComentarioViewModel(),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: ComentariosPopup(
              recipe: recipe,
              currentUserName: currentUserName,
            ),
          ),
        );
      },
    );
  }
}

class _ComentariosPopupState extends State<ComentariosPopup> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Cargar comentarios al abrir el popup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.recipe.id != null) {
        context.read<ComentarioViewModel>().cargarComentarios(
          widget.recipe.id!,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _enviarComentario() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El comentario no puede estar vacío')),
      );
      return;
    }

    if (widget.recipe.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se puede comentar en esta receta'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final viewModel = context.read<ComentarioViewModel>();

    final exito = await viewModel.crearComentario(
      recetaId: widget.recipe.id!,
      texto: texto,
      usuario: widget.currentUserName,
    );

    if (mounted) {
      if (exito) {
        _controller.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Comentario enviado'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              viewModel.errorMessage ?? 'Error al enviar comentario',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _eliminarComentario(String comentarioId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar comentario'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este comentario?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      final viewModel = context.read<ComentarioViewModel>();
      final exito = await viewModel.eliminarComentario(comentarioId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              exito ? '✅ Comentario eliminado' : 'Error al eliminar comentario',
            ),
            backgroundColor: exito ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ComentarioViewModel>(
      builder: (context, viewModel, child) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(
                children: [
                  // Header
                  _buildHeader(),
                  const Divider(),

                  // Lista de comentarios
                  Expanded(child: _buildComentariosList(viewModel)),

                  // Input para nuevo comentario
                  const Divider(),
                  _buildInputSection(viewModel),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Comentarios',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.recipe.nombre,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Cerrar',
          ),
        ],
      ),
    );
  }

  Widget _buildComentariosList(ComentarioViewModel viewModel) {
    // Mostrar loading
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Mostrar error
    if (viewModel.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                viewModel.errorMessage ?? 'Error al cargar comentarios',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  if (widget.recipe.id != null) {
                    viewModel.cargarComentarios(widget.recipe.id!);
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    // Lista vacía
    if (viewModel.comentarios.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.comment_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Sé el primero en comentar',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Lista de comentarios
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: viewModel.comentarios.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final comentario = viewModel.comentarios[index];
        final esMio = comentario.usuario == widget.currentUserName;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: esMio ? Colors.blue : Colors.grey,
            child: Text(
              comentario.usuario.isNotEmpty
                  ? comentario.usuario[0].toUpperCase()
                  : '?',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  comentario.usuario,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (esMio)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'eliminar',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Eliminar'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'eliminar' && comentario.id != null) {
                      _eliminarComentario(comentario.id!);
                    }
                  },
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(comentario.texto),
              const SizedBox(height: 8),
              Text(
                _formatearFecha(comentario.fecha),
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputSection(ComentarioViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Escribe un comentario...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          viewModel.isLoading
              ? const SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : Material(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap: _enviarComentario,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) {
      return 'Fecha desconocida';
    }

    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inDays > 365) {
      return '${(diferencia.inDays / 365).floor()} año${diferencia.inDays > 730 ? 's' : ''}';
    } else if (diferencia.inDays > 30) {
      return '${(diferencia.inDays / 30).floor()} mes${diferencia.inDays > 60 ? 'es' : ''}';
    } else if (diferencia.inDays > 0) {
      return '${diferencia.inDays} día${diferencia.inDays > 1 ? 's' : ''}';
    } else if (diferencia.inHours > 0) {
      return '${diferencia.inHours} hora${diferencia.inHours > 1 ? 's' : ''}';
    } else if (diferencia.inMinutes > 0) {
      return '${diferencia.inMinutes} min';
    } else {
      return 'Ahora';
    }
  }
}
