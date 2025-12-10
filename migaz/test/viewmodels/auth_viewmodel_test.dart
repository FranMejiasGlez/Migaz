import 'package:flutter_test/flutter_test.dart';
import 'package:migaz/viewmodels/auth_viewmodel.dart';

void main() {
  group('AuthViewModel Tests', () {
    late AuthViewModel viewModel;

    setUp(() {
      viewModel = AuthViewModel();
    });

    test('Initial state is correct', () {
      expect(viewModel.email, isEmpty);
      expect(viewModel.password, isEmpty);
      expect(viewModel.username, isEmpty);
      expect(viewModel.isLoggedIn, isFalse);
      expect(viewModel.hasCredentials, isFalse);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.hasError, isFalse);
    });

    test('setEmail updates email and notifies listeners', () {
      bool notified = false;
      viewModel.addListener(() => notified = true);

      viewModel.setEmail('test@example.com');

      expect(viewModel.email, equals('test@example.com'));
      expect(notified, isTrue);
    });

    test('setPassword updates password and notifies listeners', () {
      bool notified = false;
      viewModel.addListener(() => notified = true);

      viewModel.setPassword('password123');

      expect(viewModel.password, equals('password123'));
      expect(notified, isTrue);
    });

    test('setUsername updates username and notifies listeners', () {
      bool notified = false;
      viewModel.addListener(() => notified = true);

      viewModel.setUsername('testuser');

      expect(viewModel.username, equals('testuser'));
      expect(notified, isTrue);
    });

    test('hasCredentials returns true when email and password are set', () {
      viewModel.setEmail('test@example.com');
      viewModel.setPassword('password123');

      expect(viewModel.hasCredentials, isTrue);
    });

    test('hasCredentials returns false when email or password is empty', () {
      viewModel.setEmail('test@example.com');

      expect(viewModel.hasCredentials, isFalse);

      viewModel.setEmail('');
      viewModel.setPassword('password123');

      expect(viewModel.hasCredentials, isFalse);
    });

    test('login fails with empty credentials', () async {
      final result = await viewModel.login('', '');

      expect(result, isFalse);
      expect(viewModel.hasError, isTrue);
      expect(viewModel.errorMessage, contains('completa todos los campos'));
    });

    test('login succeeds with valid credentials', () async {
      final result = await viewModel.login('test@example.com', 'password123');

      expect(result, isTrue);
      expect(viewModel.isLoggedIn, isTrue);
      expect(viewModel.email, equals('test@example.com'));
      expect(viewModel.hasError, isFalse);
    });

    test('login sets loading state during execution', () async {
      bool wasLoading = false;
      viewModel.addListener(() {
        if (viewModel.isLoading) {
          wasLoading = true;
        }
      });

      await viewModel.login('test@example.com', 'password123');

      expect(wasLoading, isTrue);
      expect(viewModel.isLoading, isFalse);
    });

    test('register fails with empty credentials', () async {
      final result = await viewModel.register('', '', '');

      expect(result, isFalse);
      expect(viewModel.hasError, isTrue);
      expect(viewModel.errorMessage, contains('completa todos los campos'));
    });

    test('register succeeds with valid credentials', () async {
      final result = await viewModel.register(
        'test@example.com',
        'password123',
        'testuser',
      );

      expect(result, isTrue);
      expect(viewModel.isLoggedIn, isTrue);
      expect(viewModel.email, equals('test@example.com'));
      expect(viewModel.username, equals('testuser'));
      expect(viewModel.hasError, isFalse);
    });

    test('logout clears all user data and notifies listeners', () {
      // First login
      viewModel.setEmail('test@example.com');
      viewModel.setPassword('password123');
      viewModel.setUsername('testuser');

      bool notified = false;
      viewModel.addListener(() => notified = true);

      viewModel.logout();

      expect(viewModel.email, isEmpty);
      expect(viewModel.password, isEmpty);
      expect(viewModel.username, isEmpty);
      expect(viewModel.isLoggedIn, isFalse);
      expect(viewModel.hasError, isFalse);
      expect(notified, isTrue);
    });

    test('logout clears error state', () async {
      // Trigger an error
      await viewModel.login('', '');
      expect(viewModel.hasError, isTrue);

      viewModel.logout();

      expect(viewModel.hasError, isFalse);
      expect(viewModel.errorMessage, isNull);
    });
  });
}
