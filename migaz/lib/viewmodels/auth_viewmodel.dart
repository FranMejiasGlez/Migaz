import 'package:migaz/viewmodels/base_viewmodel.dart';

/// ViewModel para autenticación (Login y Registro)
/// Maneja el estado y lógica de negocio relacionada con autenticación de usuarios
class AuthViewModel extends BaseViewModel {
  String _email = '';
  String _password = '';
  String _username = '';
  bool _isLoggedIn = false;

  // Getters
  String get email => _email;
  String get password => _password;
  String get username => _username;
  bool get isLoggedIn => _isLoggedIn;
  bool get hasCredentials => _email.isNotEmpty && _password.isNotEmpty;

  /// Actualiza el email
  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  /// Actualiza la contraseña
  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  /// Actualiza el nombre de usuario
  void setUsername(String username) {
    _username = username;
    notifyListeners();
  }

  /// Realiza el login
  Future<bool> login(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      setError('Por favor completa todos los campos');
      return false;
    }

    final result = await runAsync(() async {
      // Simular llamada a API
      await Future.delayed(const Duration(seconds: 1));
      
      // En producción, aquí se haría la llamada real al servicio de autenticación
      _email = email;
      _password = password;
      _isLoggedIn = true;
      
      return true;
    }, errorPrefix: 'Error al iniciar sesión');

    return result ?? false;
  }

  /// Realiza el registro
  Future<bool> register(String email, String password, String username) async {
    if (email.trim().isEmpty || password.trim().isEmpty || username.trim().isEmpty) {
      setError('Por favor completa todos los campos');
      return false;
    }

    final result = await runAsync(() async {
      // Simular llamada a API
      await Future.delayed(const Duration(seconds: 1));
      
      // En producción, aquí se haría la llamada real al servicio de registro
      _email = email;
      _password = password;
      _username = username;
      _isLoggedIn = true;
      
      return true;
    }, errorPrefix: 'Error al registrar usuario');

    return result ?? false;
  }

  /// Cierra sesión
  void logout() {
    _email = '';
    _password = '';
    _username = '';
    _isLoggedIn = false;
    clearError();
    notifyListeners();
  }
}
