import 'package:grammar_checker/data/services/api_service.dart';
import 'package:grammar_checker/data/services/local_storage.dart';
import 'package:grammar_checker/data/models/auth_models.dart';
import 'package:grammar_checker/data/services/network_service.dart';

class Provider {
  final LocalStorageService localStorageService;
  final ApiService apiService;
  final NetworkService networkService;

  Provider({
    required this.localStorageService,
    required this.apiService,
    required this.networkService,
  });

  Future<bool> isOnline() async {
    bool isConnected = await networkService.isConnected();

    return isConnected;
  }

  Future<AuthResponse> register(String email, String password) async {
    final request = RegisterRequest(email: email, password: password);
    final response = await apiService.register(request);

    if (response.token.isNotEmpty) {
      await localStorageService.saveJwtToken(response.token);
      await localStorageService.saveUserEmail(email);
    }

    return response;
  }

  Future<AuthResponse> login(String email, String password) async {
    final request = LoginRequest(email: email, password: password);
    final response = await apiService.login(request);

    if (response.token.isNotEmpty) {
      await localStorageService.saveJwtToken(response.token);
      await localStorageService.saveUserEmail(email);
    }

    return response;
  }

  Future<void> logout() async {
    await localStorageService.clearUserData();
  }

  Future<bool> isLoggedIn() async {
    return await localStorageService.isLoggedIn();
  }

  Future<String?> getCurrentUserEmail() async {
    return await localStorageService.getUserEmail();
  }

  Future<String?> getJwtToken() async {
    return await localStorageService.getJwtToken();
  }

  Future<GrammarCheckResponse> checkGrammar(String text) async {
    final token = await localStorageService.getJwtToken();
    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found. Please login first.');
    }

    final request = GrammarCheckRequest(text: text);
    return await apiService.checkGrammar(request, token);
  }
}
