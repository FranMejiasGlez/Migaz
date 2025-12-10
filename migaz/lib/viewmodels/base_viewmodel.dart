import 'package:flutter/foundation.dart';

/// Base ViewModel que proporciona funcionalidad común para todos los ViewModels
/// Maneja estados de carga y errores de manera centralizada
abstract class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// Establece el estado de carga
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Establece un mensaje de error
  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Limpia el error actual
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Ejecuta una operación asíncrona con manejo automático de loading y errores
  Future<T?> runAsync<T>(Future<T> Function() operation, {String? errorPrefix}) async {
    try {
      setLoading(true);
      clearError();
      final result = await operation();
      setLoading(false);
      return result;
    } catch (e) {
      setLoading(false);
      final errorMsg = errorPrefix != null ? '$errorPrefix: $e' : e.toString();
      setError(errorMsg);
      return null;
    }
  }
}
