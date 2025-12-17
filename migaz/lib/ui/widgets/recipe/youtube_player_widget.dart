// lib/ui/widgets/recipe/youtube_player_widget.dart
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:url_launcher/url_launcher.dart';

class YoutubePlayerWidget extends StatefulWidget {
  final String youtubeUrl;

  const YoutubePlayerWidget({Key? key, required this.youtubeUrl})
    : super(key: key);

  @override
  State<YoutubePlayerWidget> createState() => _YoutubePlayerWidgetState();
}

class _YoutubePlayerWidgetState extends State<YoutubePlayerWidget> {
  YoutubePlayerController? _controller;
  bool _isPlayerReady = false;
  bool _hasError = false;
  String? _errorMessage;

  // 🎯 Detectar si es plataforma soportada para iframe player
  bool get _isIframePlatformSupported {
    // 🔧 FIX: Debido a problemas de WebView en Android (error 152-15 y crashes),
    // usamos fallback (abrir en app externa) para Android
    // El player embebido funciona bien en Web e iOS
    return kIsWeb || Platform.isIOS;
  }

  @override
  void initState() {
    super.initState();
    // Solo inicializar player en plataformas soportadas (Web, iOS)
    // Android usará fallback (abrir en app externa)
    if (_isIframePlatformSupported) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializePlayer();
      });
    } else {
      // Android y Desktop: mostrar fallback inmediatamente
      _isPlayerReady = true;
    }
  }

  void _initializePlayer() {
    try {
      final videoId = YoutubePlayerController.convertUrlToId(widget.youtubeUrl);

      print('🎬 URL recibida: ${widget.youtubeUrl}');
      print('🎬 Video ID extraído: $videoId');
      print('🎬 Es iOS: ${Platform.isIOS}');
      print('🎬 Es Web: $kIsWeb');

      if (videoId == null || videoId.isEmpty) {
        setState(() {
          _hasError = true;
          _errorMessage = 'No se pudo extraer el ID del video de la URL';
        });
        return;
      }

      _controller = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: false,
        params: const YoutubePlayerParams(
          showControls: true,
          mute: false,
          showFullscreenButton: true,
          loop: false,
          enableCaption: true,
          strictRelatedVideos: true,
          origin: 'https://www.youtube-nocookie.com',
        ),
      );

      setState(() {
        _isPlayerReady = true;
      });

      print('✅ YouTube Player inicializado correctamente');
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error al cargar el video: $e';
      });
      print('❌ Error al inicializar YouTube Player: $e');
    }
  }

  Future<void> _launchYoutubeUrl() async {
    try {
      final uri = Uri.parse(widget.youtubeUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('✅ Abriendo YouTube en app externa');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo abrir el video de YouTube'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error al abrir URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si hay error, mostrar mensaje
    if (_hasError) {
      return _buildErrorWidget();
    }

    // Si no está listo, mostrar loading
    if (!_isPlayerReady) {
      return _buildLoadingWidget();
    }

    // 🎯 Decidir qué mostrar según la plataforma
    if (_isIframePlatformSupported) {
      return _buildIframePlayer();
    } else {
      return _buildDesktopFallback();
    }
  }

  // 📱 Player embebido para Web/Mobile
  Widget _buildIframePlayer() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth > 800
            ? 800.0
            : constraints.maxWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Video Tutorial',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: YoutubePlayer(
                          controller: _controller!,
                          aspectRatio: 16 / 9,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildVideoInfo(),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 🖥️ Fallback para Desktop (Windows/macOS/Linux)
  Widget _buildDesktopFallback() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth > 800
            ? 800.0
            : constraints.maxWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Video Tutorial',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  children: [
                    // Thumbnail con botón de play
                    InkWell(
                      onTap: _launchYoutubeUrl,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.red.shade700, Colors.red.shade900],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  size: 64,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Ver en YouTube',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getPlatformIcon(),
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Abrir en ${_getPlatformName()}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildVideoInfo(),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 📋 Información del video (compartido)
  Widget _buildVideoInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.play_circle_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.youtubeUrl,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new, size: 20),
            onPressed: _launchYoutubeUrl,
            tooltip: 'Abrir en YouTube',
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Video Tutorial',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        'Cargando video de YouTube...',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Video Tutorial',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  const Text(
                    'Error al cargar video',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'URL de YouTube inválida',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
              Text(
                'URL: ${widget.youtubeUrl}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              const Text(
                'Formatos válidos: ',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '• https://www.youtube.com/watch?v=VIDEO_ID\n'
                '• https://youtu.be/VIDEO_ID\n'
                '• https://www.youtube.com/embed/VIDEO_ID',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 🎯 Helper:  Obtener icono según plataforma
  IconData _getPlatformIcon() {
    switch (Theme.of(context).platform) {
      case TargetPlatform.windows:
        return Icons.desktop_windows;
      case TargetPlatform.macOS:
        return Icons.laptop_mac;
      case TargetPlatform.linux:
        return Icons.computer;
      default:
        return Icons.open_in_new;
    }
  }

  // 🎯 Helper: Obtener nombre de plataforma
  String _getPlatformName() {
    switch (Theme.of(context).platform) {
      case TargetPlatform.windows:
        return 'Windows';
      case TargetPlatform.macOS:
        return 'macOS';
      case TargetPlatform.linux:
        return 'Linux';
      default:
        return 'navegador';
    }
  }
}
