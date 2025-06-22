import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grammar_checker/business_logic/cubit/auth/auth_cubit.dart';
import 'package:grammar_checker/presentation/screens/auth/components/auth_wrapper.dart';
import 'package:grammar_checker/presentation/widgets/auth/auth_text_field.dart';
import 'package:grammar_checker/utility/helpers/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AuthScreenWrapper(
        title: 'Grammar Checker',
        subtitle: 'Welcome back!',
        cardTitle: 'Login',
        buttonText: 'Login',
        navigationLeadingText: "Don't have an account? ",
        navigationActionText: 'Sign up',
        navigationRoute: '/signup',
        onSubmit: _handleLogin,
        formFields: [
          AuthTextField(
            controller: _emailController,
            labelText: 'Email',
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _passwordController,
            labelText: 'Password',
            prefixIcon: Icons.lock,
            isPassword: true,
            validator: Validators.password,
          ),
        ],
      ),
    );
  }
}
