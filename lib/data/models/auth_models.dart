class RegisterRequest {
  final String email;
  final String password;

  RegisterRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

class AuthResponse {
  final String token;
  final String? message;

  AuthResponse({required this.token, this.message});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(token: json['token'] ?? '', message: json['message']);
  }
}

class GrammarCheckRequest {
  final String text;

  GrammarCheckRequest({required this.text});

  Map<String, dynamic> toJson() {
    return {'text': text};
  }
}

class GrammarCheckResponse {
  final String corrected;
  final String? message;

  GrammarCheckResponse({required this.corrected, this.message});

  factory GrammarCheckResponse.fromJson(Map<String, dynamic> json) {
    return GrammarCheckResponse(
      corrected: json['corrected'] ?? '',
      message: json['message'],
    );
  }
}
