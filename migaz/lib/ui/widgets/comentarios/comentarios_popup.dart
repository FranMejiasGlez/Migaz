import 'package:flutter/material.dart';
import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/data/models/comentario.dart';

class comentariosPopup extends StatefulWidget {
  final Recipe recipe;
  final String currentUserName;
  final ValueChanged<Comentario>? onAddcomentario; // callback opcional

  const comentariosPopup({
    Key? key,
    required this.recipe,
    this.currentUserName = 'Usuario',
    this.onAddcomentario,
  }) : super(key: key);

  @override
  State<comentariosPopup> createState() => _comentariosPopupState();
}

class _comentariosPopupState extends State<comentariosPopup> {
  final TextEditingController _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addcomentario() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _sending = true);

    final comentario = Comentario(author: widget.currentUserName, text: text);

    // 1) Actualizamos localmente (lista mutable)
    setState(() {
      widget.recipe.comentarios.insert(0, comentario);
      _controller.clear();
    });

    // 2) Llamada opcional al callback (y/o al backend)
    try {
      widget.onAddcomentario?.call(comentario);
      // Aquí podrías enviar al backend (postcomentario) si lo implementas.
    } catch (_) {
      // manejo simple de errores (puedes mostrar Snackbar si quieres)
    } finally {
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Comentarios — ${widget.recipe.nombre}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: widget.recipe.comentarios.isEmpty
                  ? const Center(child: Text('Sé el primero en comentar'))
                  : ListView.separated(
                      reverse: false,
                      padding: const EdgeInsets.all(12),
                      itemCount: widget.recipe.comentarios.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final c = widget.recipe.comentarios[index];
                        return ListTile(
                          title: Text(c.author),
                          subtitle: Text(c.text),
                          trailing: Text(
                            _formatDate(c.createdAt),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Escribe un comentario...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _sending
                      ? const SizedBox(
                          width: 48,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : ElevatedButton(
                          onPressed: _addcomentario,
                          child: const Text('Enviar'),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    // simple formatting corto
    final d = dt;
    return '${d.day}/${d.month}/${d.year}';
  }
}
