import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/api_config.dart';

class AuthService {
  static const String _kUserKey = 'auth_user';
  static const String _kUserIdKey = 'auth_user_id';
  static const String _kUserImageKey = 'auth_user_image';

  /// Iniciar sesión con email/usuario y contraseña
  Future<Map<String, dynamic>> login(
    String identificador,
    String password,
  ) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}');
      print('🔐 Intentando login en: $uri');

      final response = await http.post(
        uri,
        headers: ApiConfig.headers,
        body: jsonEncode({
          'identificador': identificador,
          'password': password,
        }),
      );

      print('📥 Respuesta login: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveSession(data);
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['msg'] ?? 'Error al iniciar sesión');
      }
    } catch (e) {
      print('❌ Error login: $e');
      rethrow;
    }
  }

  /// Registrar nuevo usuario
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.registroEndpoint}',
      );
      print('📝 Intentando registro en: $uri');

      final body = {'email': email, 'password': password, 'username': username};

      final response = await http.post(
        uri,
        headers: ApiConfig.headers,
        body: jsonEncode(body),
      );

      print('📥 Respuesta registro: ${response.statusCode}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // Opcional: Auto-login tras registro
        await _saveSession(data);
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['msg'] ?? 'Error al registrar usuario');
      }
    } catch (e) {
      print('❌ Error registro: $e');
      rethrow;
    }
  }

  /// Guardar sesión localmente
  Future<void> _saveSession(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    final username = userData['username'];
    final id = userData['_id'];
    final image = userData['profile_image'];

    if (username != null) {
      await prefs.setString(_kUserKey, username);
      ApiConfig.currentUser = username;
    }

    if (id != null) {
      await prefs.setString(_kUserIdKey, id);
    }

    if (image != null) {
      await prefs.setString(_kUserImageKey, image);
    }

    print('✅ Sesión guardada para: $username');
  }

  Future<void> updateImageSession(String imageUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserImageKey, imageUrl);
  }

  /// Cerrar sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserKey);
    await prefs.remove(_kUserIdKey);
    await prefs.remove(_kUserImageKey);
    ApiConfig.currentUser = '';
    print('👋 Sesión cerrada');
  }

  /// Recuperar usuario guardado al inicio
  Future<Map<String, String?>?> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_kUserKey);
    final id = prefs.getString(_kUserIdKey);
    final image = prefs.getString(_kUserImageKey);

    if (username != null && username.isNotEmpty) {
      ApiConfig.currentUser = username;
      print('🔄 Sesión recuperada para: $username ($id)');
      return {'username': username, 'id': id, 'image': image};
    }

    return null;
  }
}
