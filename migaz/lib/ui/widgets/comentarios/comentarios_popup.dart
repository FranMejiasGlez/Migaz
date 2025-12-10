import 'package:flutter/material.dart';
import 'package:migaz/data/models/recipe.dart';
import 'package:migaz/data/models/comentario.dart';

typedef OnAddComentario = void Function(Comentario comentario);

class ComentariosPopup extends StatefulWidget {
  final Recipe recipe;
  final String currentUserName;
  final OnAddComentario? onAddComentario;

  const ComentariosPopup({
    Key? key,
    required this.recipe,
    required this.currentUserName,
    this.onAddComentario,
  }) : super(key: key);

  @override
  State<ComentariosPopup> createState() => _ComentariosPopupState();
}

class _ComentariosPopupState extends State<ComentariosPopup> {
  final TextEditingController _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _enviarComentario() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;

    setState(() => _sending = true);

    final nuevo = Comentario(autor: widget.currentUserName, texto: texto);

    // 1) actualizar localmente la receta (inserta al inicio)
    setState(() {
      widget.recipe.comentarios.insert(0, nuevo);
      _controller.clear();
    });

    // 2) callback opcional para persistencia
    try {
      widget.onAddComentario?.call(nuevo);
    } catch (_) {
      // Manejo simple: en producción muestra error/rollback si fuese necesario
    } finally {
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final comentarios = widget.recipe.comentarios;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(
                'Comentarios — ${widget.recipe.nombre}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              Expanded(
                child: comentarios.isEmpty
                    ? const Center(child: Text('Sé el primero en comentar'))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        itemCount: comentarios.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final c = comentarios[index];
                          return ListTile(
                            title: Text(
                              c.autor,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(c.texto),
                            trailing: Text(
                              '${c.creadoEn.day}/${c.creadoEn.month}/${c.creadoEn.year}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const Divider(),
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
                            onPressed: _enviarComentario,
                            child: const Text('Enviar'),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
