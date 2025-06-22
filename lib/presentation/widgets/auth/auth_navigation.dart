import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grammar_checker/utility/constants/app_colors.dart';

class AuthNavigation extends StatelessWidget {
  final String leadingText;
  final String actionText;
  final VoidCallback onPressed;
  final bool isEnabled;

  const AuthNavigation({
    super.key,
    required this.leadingText,
    required this.actionText,
    required this.onPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isEnabled ? onPressed : null,
      child: RichText(
        text: TextSpan(
          text: leadingText,
          style: GoogleFonts.nunito(
            color: AppColors.textSecondaryColor,
            fontSize: 14,
          ),
          children: [
            TextSpan(
              text: actionText,
              style: GoogleFonts.nunito(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
