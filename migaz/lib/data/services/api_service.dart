import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:migaz/core/config/api_config.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// GET request
  Future<dynamic> get(String endpoint) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final response = await _client.get(url, headers: ApiConfig.headers);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request (JSON)
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final response = await _client.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final response = await _client.put(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<dynamic> delete(String endpoint) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final response = await _client.delete(url, headers: ApiConfig.headers);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST Multipart (para archivos/imágenes)
  Future<dynamic> postMultipart(
    String endpoint,
    Map<String, String> fields,
    dynamic files,
  ) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', url);

      request.headers.addAll(ApiConfig.multipartHeaders);
      request.fields.addAll(fields);

      if (files != null && files is List && files.isNotEmpty) {
        if (files.first is File) {
          // Móvil/Desktop:  List<File>
          for (var file in files) {
            final stream = http.ByteStream(file.openRead());
            final length = await file.length();
            final multipartFile = http.MultipartFile(
              'imagenes',
              stream,
              length,
              filename: file.path.split('/').last,
            );
            request.files.add(multipartFile);
          }
        } else if (files.first is XFile) {
          // Web: List<XFile>
          for (var xfile in files) {
            final bytes = await xfile.readAsBytes();
            final multipartFile = http.MultipartFile.fromBytes(
              'imagenes',
              bytes,
              filename: xfile.name,
            );
            request.files.add(multipartFile);
          }
        }
      }

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// ✅ ACTUALIZADO: POST Multipart con JSON + Archivos
  Future<dynamic> postMultipartWithJson(
    String endpoint,
    Map<String, dynamic> jsonData,
    dynamic files,
  ) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', url);

      // ✅ Añadir headers
      final headers = Map<String, String>.from(ApiConfig.multipartHeaders);
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      // ✅ Añadir campos
      jsonData.forEach((key, value) {
        if (value is List) {
          for (int i = 0; i < value.length; i++) {
            request.fields['$key[$i]'] = value[i].toString();
          }
        } else {
          request.fields[key] = value.toString();
        }
      });

      print('📤 DEBUG - Fields enviados: ');
      request.fields.forEach((key, value) {
        print('  $key: $value');
      });

      // ✅ Añadir archivos CON contentType explícito
      if (files != null && files is List && files.isNotEmpty) {
        if (files.first is File) {
          // Móvil/Desktop:  List<File>
          for (var file in files) {
            final stream = http.ByteStream(file.openRead());
            final length = await file.length();

            // ✅ Determinar el tipo MIME según la extensión
            final extension = file.path.split('.').last.toLowerCase();
            String contentType = 'image/jpeg'; // Por defecto

            if (extension == 'png') {
              contentType = 'image/png';
            } else if (extension == 'jpg' || extension == 'jpeg') {
              contentType = 'image/jpeg';
            } else if (extension == 'webp') {
              contentType = 'image/webp';
            }

            final multipartFile = http.MultipartFile(
              'imagenes',
              stream,
              length,
              filename: file.path.split('/').last,
              contentType: http.MediaType.parse(contentType), // ✅ AÑADIDO
            );
            request.files.add(multipartFile);
            print(
              '📎 DEBUG - Archivo añadido: ${file.path.split('/').last} (${contentType})',
            );
          }
        } else if (files.first is XFile) {
          // Web: List<XFile>
          for (var xfile in files) {
            final bytes = await xfile.readAsBytes();

            // ✅ Determinar el tipo MIME
            String contentType = xfile.mimeType ?? 'image/jpeg';

            // Si no tiene mimeType, determinarlo por extensión
            if (contentType.isEmpty ||
                contentType == 'application/octet-stream') {
              final extension = xfile.name.split('.').last.toLowerCase();
              if (extension == 'png') {
                contentType = 'image/png';
              } else if (extension == 'jpg' || extension == 'jpeg') {
                contentType = 'image/jpeg';
              } else if (extension == 'webp') {
                contentType = 'image/webp';
              } else {
                contentType = 'image/jpeg'; // Por defecto
              }
            }

            final multipartFile = http.MultipartFile.fromBytes(
              'imagenes',
              bytes,
              filename: xfile.name,
              contentType: http.MediaType.parse(contentType), // ✅ AÑADIDO
            );
            request.files.add(multipartFile);
            print('📎 DEBUG - Archivo añadido: ${xfile.name} (${contentType})');
          }
        }
      }

      print('📤 DEBUG - Total archivos:  ${request.files.length}');

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 DEBUG - Status: ${response.statusCode}');
      print('📥 DEBUG - Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ DEBUG - Error: $e');
      throw _handleError(e);
    }
  }

  /// PUT Multipart
  Future<dynamic> putMultipart(
    String endpoint,
    Map<String, String> fields,
    List<File>? files,
  ) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final request = http.MultipartRequest('PUT', url);

      request.headers.addAll(ApiConfig.multipartHeaders);
      request.fields.addAll(fields);

      if (files != null && files.isNotEmpty) {
        for (var file in files) {
          final stream = http.ByteStream(file.openRead());
          final length = await file.length();
          final multipartFile = http.MultipartFile(
            'imagenes',
            stream,
            length,
            filename: file.path.split('/').last,
          );
          request.files.add(multipartFile);
        }
      }

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Maneja la respuesta HTTP
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      throw HttpException('Error ${response.statusCode}: ${response.body}');
    }
  }

  /// Maneja errores
  Exception _handleError(dynamic error) {
    if (error is SocketException) {
      return Exception('No hay conexión a internet');
    } else if (error is HttpException) {
      return Exception(error.message);
    } else if (error is FormatException) {
      return Exception('Error al procesar la respuesta del servidor');
    } else {
      return Exception('Error inesperado:  $error');
    }
  }

  void dispose() {
    _client.close();
  }
}
