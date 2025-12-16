import 'package:migaz/data/services/user_service.dart';
import 'package:migaz/viewmodels/base_viewmodel.dart';

class UserViewModel extends BaseViewModel {
  final UserService _userService = UserService();
  
  Map<String, dynamic>? _userProfile;
  List<dynamic> _followers = [];
  List<dynamic> _following = [];
  
  Map<String, dynamic>? get userProfile => _userProfile;
  List<dynamic> get followers => _followers;
  List<dynamic> get following => _following;

  Future<void> loadUserProfile(String userId) async {
    await runAsync(() async {
      final data = await _userService.getUserProfile(userId);
      _userProfile = data;
      _followers = data['seguidores'] ?? [];
      _following = data['siguiendo'] ?? [];
      return true;
    });
  }

  Future<Map<String, dynamic>?> getPublicProfileByUsername(String username) async {
    return await _userService.getUserByUsername(username);
  }

  // IdUsuarioOrigen = Yo. Target = A quien sigo/dejo de seguir.
  Future<bool> toggleFollow(String myUserId, String targetUserId) async {
    final success = await runAsync(() async {
      await _userService.toggleFollow(myUserId, targetUserId);
      // Recargamos el perfil para actualizar las listas completas con nombres e imágenes
      await loadUserProfile(myUserId);
      return true;
    });
    return success ?? false;
  }

  Future<Map<String, dynamic>?> updateProfile(String userId, Map<String, String> data, dynamic imageFile) async {
    return await runAsync(() async {
      final updatedUser = await _userService.updateProfile(userId, data, imageFile);
      
      // Si estamos visualizando este perfil, actualizamos los datos locales
      if (_userProfile != null && _userProfile!['_id'] == userId) {
        _userProfile = updatedUser;
        // Mantener listas si no vienen en la respuesta (el update a veces no devuelve populate)
        if (updatedUser['seguidores'] == null) updatedUser['seguidores'] = _followers;
        if (updatedUser['siguiendo'] == null) updatedUser['siguiendo'] = _following;
      }
      return updatedUser;
    });
  }
}
