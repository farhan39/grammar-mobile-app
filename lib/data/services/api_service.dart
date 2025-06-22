import 'dart:convert';
import 'package:grammar_checker/data/services/exceptions/api.dart';
import 'package:grammar_checker/data/models/auth_models.dart';
import 'package:grammar_checker/utility/constants/endpoints.dart';
import 'package:http/http.dart' as http;
import 'package:grammar_checker/data/services/network_service.dart';

class ApiService {
  ApiService._privateConstructor();

  static final ApiService _instance = ApiService._privateConstructor();

  static ApiService get instance => _instance;

  http.Client get _client => NetworkService.instance.client;

  static const defaultTimeout = Duration(seconds: 10);

  Future<bool> _checkConnection() async {
    if (!await NetworkService.instance.isConnected()) {
      throw ApiException('No internet connection');
    }
    return true;
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      await _checkConnection();

      final response = await _client
          .post(
            Uri.parse('${Endpoints.baseUrl}${Endpoints.register}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(defaultTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(jsonDecode(response.body));
      } else {
        throw ApiException(
          'Failed to register: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw ApiException('Error registering: $e');
    }
  }

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      await _checkConnection();

      final response = await _client
          .post(
            Uri.parse('${Endpoints.baseUrl}${Endpoints.login}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(defaultTimeout);

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(jsonDecode(response.body));
      } else {
        throw ApiException(
          'Failed to login: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw ApiException('Error logging in: $e');
    }
  }

  Future<GrammarCheckResponse> checkGrammar(
    GrammarCheckRequest request,
    String token,
  ) async {
    try {
      await _checkConnection();

      final response = await _client
          .post(
            Uri.parse('${Endpoints.baseUrl}${Endpoints.grammarCheck}'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(defaultTimeout);

      if (response.statusCode == 200) {
        return GrammarCheckResponse.fromJson(jsonDecode(response.body));
      } else {
        throw ApiException(
          'Failed to check grammar: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw ApiException('Error checking grammar: $e');
    }
  }

  // Legacy methods for backward compatibility
  Future<Map<String, dynamic>> fetchData(String endpoint) async {
    try {
      await _checkConnection();

      final response = await _client
          .get(Uri.parse('${Endpoints.baseUrl}/$endpoint'))
          .timeout(defaultTimeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ApiException('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Error fetching data: $e');
    }
  }

  Future<Map<String, dynamic>> postData(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      await _checkConnection();

      final response = await _client
          .post(
            Uri.parse('${Endpoints.baseUrl}/$endpoint'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(defaultTimeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ApiException('Failed to post data: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Error posting data: $e');
    }
  }
}
