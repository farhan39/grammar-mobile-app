import 'package:grammar_checker/data/providers/provider.dart';
import 'package:grammar_checker/data/models/auth_models.dart';

class Repository {
  final Provider provider;

  Repository({required this.provider});

  // Network connectivity
  Future<bool> isOnline() async {
    bool onlineStatus = await provider.isOnline();
    return onlineStatus;
  }

  // Authentication methods
  Future<AuthResponse> register(String email, String password) async {
    try {
      return await provider.register(email, password);
    } catch (e) {
      throw RepositoryException('Registration failed: $e');
    }
  }

  Future<AuthResponse> login(String email, String password) async {
    try {
      return await provider.login(email, password);
    } catch (e) {
      throw RepositoryException('Login failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      await provider.logout();
    } catch (e) {
      throw RepositoryException('Logout failed: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      return await provider.isLoggedIn();
    } catch (e) {
      throw RepositoryException('Failed to check login status: $e');
    }
  }

  Future<String?> getCurrentUserEmail() async {
    try {
      return await provider.getCurrentUserEmail();
    } catch (e) {
      throw RepositoryException('Failed to get current user email: $e');
    }
  }

  // Grammar checking
  Future<GrammarCheckResponse> checkGrammar(String text) async {
    try {
      if (text.trim().isEmpty) {
        throw RepositoryException('Text cannot be empty');
      }
      return await provider.checkGrammar(text);
    } catch (e) {
      throw RepositoryException('Grammar check failed: $e');
    }
  }
}

class RepositoryException implements Exception {
  final String message;
  const RepositoryException(this.message);

  @override
  String toString() => message;
}
