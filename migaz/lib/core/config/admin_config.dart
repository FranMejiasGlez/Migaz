/// Lista de usuarios administradores
/// Edita esta lista para agregar o quitar admins
class AdminConfig {
  static const List<String> adminUsernames = [
    'uhhflame',
    'rubix',
  ];

  /// Verifica si un username es administrador
  static bool isAdmin(String username) {
    return adminUsernames.contains(username.toLowerCase());
  }
}
