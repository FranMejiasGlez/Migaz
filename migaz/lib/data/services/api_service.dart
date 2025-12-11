import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
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
    List<File>? files,
  ) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', url);

      // Añadir headers
      request.headers.addAll(ApiConfig.multipartHeaders);

      // Añadir campos de texto
      request.fields.addAll(fields);

      // Añadir archivos si existen
      if (files != null && files.isNotEmpty) {
        for (var file in files) {
          final stream = http.ByteStream(file.openRead());
          final length = await file.length();
          final multipartFile = http.MultipartFile(
            'imagenes', // nombre del campo en tu API
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
      return Exception('Error inesperado: $error');
    }
  }

  void dispose() {
    _client.close();
  }
}
