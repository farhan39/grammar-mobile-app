import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grammar_checker/presentation/widgets/common/card_container.dart';
import 'package:grammar_checker/utility/constants/app_colors.dart';

class AuthCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const AuthCard({
    super.key,
    required this.title,
    required this.children,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      padding: padding ?? const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }
}
