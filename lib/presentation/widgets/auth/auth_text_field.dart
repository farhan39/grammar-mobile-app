import 'package:flutter/material.dart';
import 'package:grammar_checker/presentation/widgets/forms/custom_text_field.dart';
import 'package:grammar_checker/utility/constants/app_colors.dart';

class AuthTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String labelText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      labelText: widget.labelText,
      prefixIcon: widget.prefixIcon,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      obscureText: widget.isPassword ? _obscureText : false,
      suffixIcon: widget.isPassword
          ? IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
                color: AppColors.textSecondaryColor,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            )
          : null,
    );
  }
}
