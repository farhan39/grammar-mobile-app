import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService._privateConstructor();

  static final LocalStorageService _instance =
      LocalStorageService._privateConstructor();

  static LocalStorageService get instance => _instance;

  SharedPreferences? _prefs;

  // Storage keys
  static const String _firstRunKey = 'isFirstRun';
  static const String _jwtTokenKey = 'jwt_token';
  static const String _userEmailKey = 'user_email';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _setSafe(String key, String value) async {
    try {
      if (_prefs == null) {
        await init();
      }

      await _prefs!.setString(key, value);
    } catch (e, stackTrace) {
      _logError('Error setting $key', e, stackTrace: stackTrace);
      throw LocalStorageException('Error setting $key: $e', stackTrace);
    }
  }

  Future<String?> _getSafe(String key) async {
    if (key.isEmpty) {
      return null;
    }

    try {
      if (_prefs == null) {
        await init();
        if (_prefs == null) {
          throw LocalStorageException('Failed to initialize SharedPreferences');
        }
      }

      final result = _prefs!.getString(key);

      if (result == null || result.isEmpty) {
        return null;
      }

      if (result.isEmpty) {
        await _setSafe(key, '');
        return null;
      }

      return result.trim();
    } catch (e, stackTrace) {
      _logError('Error retrieving $key', e, stackTrace: stackTrace);
      throw LocalStorageException('Error retrieving $key: $e', stackTrace);
    }
  }

  Future<void> _removeSafe(String key) async {
    try {
      if (_prefs == null) {
        await init();
      }

      await _prefs!.remove(key);
    } catch (e, stackTrace) {
      _logError('Error removing $key', e, stackTrace: stackTrace);
      throw LocalStorageException('Error removing $key: $e', stackTrace);
    }
  }

  void _logError(String message, Object error, {StackTrace? stackTrace}) {
    if (kDebugMode) {
      if (stackTrace != null) {}
    }
  }

  // First run methods
  Future<bool> setFirstRun({required bool value}) async {
    try {
      await _setSafe(_firstRunKey, value.toString());
      return true;
    } catch (e, stackTrace) {
      _logError('Failed to set first run', e, stackTrace: stackTrace);
      throw LocalStorageException('Failed to set first run: $e', stackTrace);
    }
  }

  Future<bool> isFirstRun() async {
    try {
      final value = await _getSafe(_firstRunKey);
      return value == null ? true : value.toLowerCase() == 'true';
    } catch (e, stackTrace) {
      _logError('Failed to check if first run', e, stackTrace: stackTrace);
      throw LocalStorageException(
        'Failed to check if first run: $e',
        stackTrace,
      );
    }
  }

  // JWT Token methods
  Future<void> saveJwtToken(String token) async {
    try {
      await _setSafe(_jwtTokenKey, token);
    } catch (e, stackTrace) {
      _logError('Failed to save JWT token', e, stackTrace: stackTrace);
      throw LocalStorageException('Failed to save JWT token: $e', stackTrace);
    }
  }

  Future<String?> getJwtToken() async {
    try {
      return await _getSafe(_jwtTokenKey);
    } catch (e, stackTrace) {
      _logError('Failed to get JWT token', e, stackTrace: stackTrace);
      throw LocalStorageException('Failed to get JWT token: $e', stackTrace);
    }
  }

  Future<void> removeJwtToken() async {
    try {
      await _removeSafe(_jwtTokenKey);
    } catch (e, stackTrace) {
      _logError('Failed to remove JWT token', e, stackTrace: stackTrace);
      throw LocalStorageException('Failed to remove JWT token: $e', stackTrace);
    }
  }

  // User email methods
  Future<void> saveUserEmail(String email) async {
    try {
      await _setSafe(_userEmailKey, email);
    } catch (e, stackTrace) {
      _logError('Failed to save user email', e, stackTrace: stackTrace);
      throw LocalStorageException('Failed to save user email: $e', stackTrace);
    }
  }

  Future<String?> getUserEmail() async {
    try {
      return await _getSafe(_userEmailKey);
    } catch (e, stackTrace) {
      _logError('Failed to get user email', e, stackTrace: stackTrace);
      throw LocalStorageException('Failed to get user email: $e', stackTrace);
    }
  }

  Future<void> removeUserEmail() async {
    try {
      await _removeSafe(_userEmailKey);
    } catch (e, stackTrace) {
      _logError('Failed to remove user email', e, stackTrace: stackTrace);
      throw LocalStorageException(
        'Failed to remove user email: $e',
        stackTrace,
      );
    }
  }

  // Authentication check
  Future<bool> isLoggedIn() async {
    try {
      final token = await getJwtToken();
      return token != null && token.isNotEmpty;
    } catch (e, stackTrace) {
      _logError('Failed to check login status', e, stackTrace: stackTrace);
      return false;
    }
  }

  // Clear all user data (logout)
  Future<void> clearUserData() async {
    try {
      await removeJwtToken();
      await removeUserEmail();
    } catch (e, stackTrace) {
      _logError('Failed to clear user data', e, stackTrace: stackTrace);
      throw LocalStorageException('Failed to clear user data: $e', stackTrace);
    }
  }
}

class LocalStorageException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  LocalStorageException(this.message, [this.stackTrace]);

  @override
  String toString() => 'LocalStorageException: $message\n${stackTrace ?? ''}';
}
