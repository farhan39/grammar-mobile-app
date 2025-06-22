import 'package:flutter/material.dart';
import 'package:grammar_checker/presentation/screens/auth/login_screen.dart';
import 'package:grammar_checker/presentation/screens/auth/signup_screen.dart';
import 'package:grammar_checker/presentation/screens/home/grammar_home_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String grammar = '/grammar';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    signup: (context) => const SignUpScreen(),
    grammar: (context) => const GrammarHomeScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name];
    if (builder != null) {
      return MaterialPageRoute(builder: builder);
    }

    // Default route fallback
    return MaterialPageRoute(builder: (context) => const LoginScreen());
  }

  static String getInitialRoute() {
    return login; // Start with login screen
  }
}
