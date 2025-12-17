import 'package:migaz/data/services/auth_service.dart';
import 'package:migaz/viewmodels/base_viewmodel.dart';

/// ViewModel para autenticación (Login y Registro)
class AuthViewModel extends BaseViewModel {
  final AuthService _authService = AuthService();

  String _currentUser = '';
  String _currentUserId = '';
  String? _currentUserImage;
  bool _isLoggedIn = false;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String get currentUser => _currentUser;
  String get currentUserId => _currentUserId;
  String? get currentUserImage => _currentUserImage;

  /// Verifica si hay sesión al iniciar la app
  Future<bool> checkSession() async {
    final userData = await _authService.checkSession();
    if (userData != null) {
      _currentUser = userData['username'] ?? '';
      _currentUserId = userData['id'] ?? '';
      _currentUserImage = userData['image'];
      _isLoggedIn = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Realiza el login
  Future<bool> login(String identificador, String password) async {
    if (identificador.trim().isEmpty || password.trim().isEmpty) {
      setError('Por favor completa todos los campos');
      return false;
    }

    final result = await runAsync(() async {
      final data = await _authService.login(identificador, password);
      _currentUser = data['username'];
      _currentUserId = data['_id'];
      _currentUserImage = data['profile_image'];
      _isLoggedIn = true;
      return true;
    }, errorPrefix: 'Error al iniciar sesión');

    return result ?? false;
  }

  /// Realiza el registro
  Future<bool> register(String email, String password, String username) async {
    if (email.trim().isEmpty ||
        password.trim().isEmpty ||
        username.trim().isEmpty) {
      setError('Por favor completa todos los campos');
      return false;
    }

    final result = await runAsync(() async {
      final data = await _authService.register(
        email: email,
        password: password,
        username: username,
      );
      _currentUser = data['username'];
      _currentUserId = data['_id'];
      _currentUserImage = data['profile_image'];
      _isLoggedIn = true;
      return true;
    }, errorPrefix: 'Error al registrar usuario');

    return result ?? false;
  }

  /// Actualizar imagen de usuario en sesión (sin relogin)
  Future<void> updateUserImage(String imageUrl) async {
    _currentUserImage = imageUrl;
    await _authService.updateImageSession(imageUrl);
    notifyListeners();
  }

  /// Cierra sesión
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = '';
    _currentUserId = '';
    _currentUserImage = null;
    _isLoggedIn = false;
    clearError();
    notifyListeners();
  }
}
