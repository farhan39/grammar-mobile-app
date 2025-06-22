import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grammar_checker/business_logic/cubit/auth/auth_state.dart';
import 'package:grammar_checker/data/repositories/repository.dart';

class AuthCubit extends Cubit<AuthState> {
  final Repository repository;

  AuthCubit({required this.repository}) : super(AuthInitial());

  // Initialize authentication - check if user is already logged in
  Future<void> initializeAuth() async {
    try {
      final isLoggedIn = await repository.isLoggedIn();
      if (isLoggedIn) {
        final userEmail = await repository.getCurrentUserEmail();
        emit(AuthLoggedIn(userEmail: userEmail ?? ''));
      } else {
        emit(AuthLoggedOut());
      }
    } catch (e) {
      emit(AuthError(message: 'Failed to initialize authentication: $e'));
    }
  }

  // Register new user
  Future<void> register(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      emit(const AuthError(message: 'Please fill in all fields'));
      return;
    }

    if (!_isValidEmail(email)) {
      emit(const AuthError(message: 'Please enter a valid email address'));
      return;
    }

    if (password.length < 6) {
      emit(const AuthError(message: 'Password must be at least 6 characters'));
      return;
    }

    emit(AuthLoading());

    try {
      await repository.register(email.trim(), password);
      emit(AuthLoggedIn(userEmail: email.trim()));
    } catch (e) {
      emit(AuthError(message: _parseErrorMessage(e.toString())));
    }
  }

  // Login existing user
  Future<void> login(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      emit(const AuthError(message: 'Please fill in all fields'));
      return;
    }

    if (!_isValidEmail(email)) {
      emit(const AuthError(message: 'Please enter a valid email address'));
      return;
    }

    emit(AuthLoading());

    try {
      await repository.login(email.trim(), password);
      emit(AuthLoggedIn(userEmail: email.trim()));
    } catch (e) {
      emit(AuthError(message: _parseErrorMessage(e.toString())));
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await repository.logout();
      emit(AuthLoggedOut());
    } catch (e) {
      emit(AuthError(message: 'Logout failed: $e'));
    }
  }

  // Clear error state
  void clearError() {
    if (state is AuthError) {
      emit(AuthLoggedOut());
    }
  }

  // Helper method to validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Helper method to parse and clean error messages
  String _parseErrorMessage(String error) {
    // Clean up common error patterns
    if (error.contains('Registration failed:')) {
      String cleanedError = error.replaceAll('Registration failed:', '').trim();
      if (cleanedError.contains('400')) {
        return 'Email already exists. Please try logging in instead.';
      }
      return cleanedError.isNotEmpty
          ? cleanedError
          : 'Registration failed. Please try again.';
    }

    if (error.contains('Login failed:')) {
      String cleanedError = error.replaceAll('Login failed:', '').trim();
      if (cleanedError.contains('401') || cleanedError.contains('400')) {
        return 'Invalid email or password. Please check your credentials.';
      }
      return cleanedError.isNotEmpty
          ? cleanedError
          : 'Login failed. Please try again.';
    }

    if (error.contains('No internet connection')) {
      return 'No internet connection. Please check your network.';
    }

    // Return a generic message for unknown errors
    return 'Something went wrong. Please try again.';
  }

  // Getters for easy state checking
  bool get isLoggedIn => state is AuthLoggedIn;
  bool get isLoading => state is AuthLoading;
  String? get currentUserEmail {
    final currentState = state;
    if (currentState is AuthLoggedIn) {
      return currentState.userEmail;
    }
    return null;
  }
}
