import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';
import 'package:http_parser/http_parser.dart';

class UserService {
  /// Obtener perfil completo de un usuario por su ID
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/usuarios/$userId');
      final response = await http.get(uri, headers: ApiConfig.headers);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener perfil: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getUserProfile: $e');
      rethrow;
    }
  }

  /// Seguir o dejar de seguir a un usuario
  Future<Map<String, dynamic>> toggleFollow(String myUserId, String targetUserId) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/usuarios/$myUserId/seguir');
      
      final response = await http.post(
        uri, 
        headers: ApiConfig.headers,
        body: jsonEncode({'idDestino': targetUserId}),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al seguir usuario: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error toggleFollow: $e');
      rethrow;
    }
  }

  /// Obtener perfil público (ID, nombre, img) por username
  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/usuarios/buscar/$username');
      final response = await http.get(uri, headers: ApiConfig.headers);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('❌ Error getUserByUsername: $e');
      return null;
    }
  }

  /// Actualizar Perfil (Datos + Foto opcional)
  /// Soporta Web y Mobile usando XFile
  Future<Map<String, dynamic>> updateProfile(String userId, Map<String, String> data, dynamic imageFile) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/usuarios/$userId');
      final request = http.MultipartRequest('PUT', uri);
      
      // Headers (Quitamos Content-Type para que Multipart ponga el boundary correcto)
      final headers = Map<String, String>.from(ApiConfig.headers);
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      // Campos de texto
      request.fields.addAll(data);

      // Imagen
      if (imageFile != null) {
        if (imageFile is String) {
           // Si es path string (Mobile legacy)
           request.files.add(await http.MultipartFile.fromPath('imagen', imageFile));
        } else {

           // Si es XFile (Web/Mobile)
           // Asumimos que es XFile (cross_file)
           // Necesitamos leer bytes
           final bytes = await imageFile.readAsBytes();
           
           // Intentar deducir mime type por extensión
           final String ext = imageFile.name.split('.').last.toLowerCase();
           MediaType? mediaType;
           
           if (ext == 'png') {
             mediaType = MediaType('image', 'png');
           } else if (ext == 'jpg' || ext == 'jpeg') {
             mediaType = MediaType('image', 'jpeg');
           } else if (ext == 'webp') {
             mediaType = MediaType('image', 'webp');
           } else {
              // Default fallback
              mediaType = MediaType('image', 'jpeg'); 
           }

           request.files.add(
             http.MultipartFile.fromBytes(
               'imagen', 
               bytes, 
               filename: imageFile.name,
               contentType: mediaType,
             )
           );
      }
    }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al actualizar perfil: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error updateProfile: $e');
      rethrow;
    }
  }
}

