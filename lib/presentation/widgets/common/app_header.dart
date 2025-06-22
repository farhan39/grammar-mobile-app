import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grammar_checker/utility/constants/app_colors.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final TextAlign textAlign;
  final double titleFontSize;
  final double? subtitleFontSize;
  final Color? titleColor;
  final Color? subtitleColor;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.textAlign = TextAlign.center,
    this.titleFontSize = 32,
    this.subtitleFontSize,
    this.titleColor,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: textAlign == TextAlign.center
          ? CrossAxisAlignment.center
          : textAlign == TextAlign.start
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: titleColor ?? AppColors.primaryColor,
          ),
          textAlign: textAlign,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: GoogleFonts.nunito(
              fontSize: subtitleFontSize ?? 16,
              color: subtitleColor ?? AppColors.textSecondaryColor,
            ),
            textAlign: textAlign,
          ),
        ],
      ],
    );
  }
}
