import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grammar_checker/business_logic/cubit/auth/auth_cubit.dart';
import 'package:grammar_checker/presentation/screens/auth/components/auth_wrapper.dart';
import 'package:grammar_checker/presentation/widgets/auth/auth_text_field.dart';
import 'package:grammar_checker/utility/helpers/validators.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().register(
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
        subtitle: 'Create your account',
        cardTitle: 'Sign Up',
        buttonText: 'Sign Up',
        navigationLeadingText: "Already have an account? ",
        navigationActionText: 'Login',
        navigationRoute: '/login',
        onSubmit: _handleSignUp,
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
          const SizedBox(height: 16),
          AuthTextField(
            controller: _confirmPasswordController,
            labelText: 'Confirm Password',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            validator: (value) =>
                Validators.confirmPassword(value, _passwordController.text),
          ),
        ],
      ),
    );
  }
}
