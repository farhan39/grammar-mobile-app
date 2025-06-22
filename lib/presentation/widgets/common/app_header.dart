import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grammar_checker/utility/constants/app_colors.dart';
import 'package:grammar_checker/utility/helpers/responsive_helper.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final TextAlign textAlign;
  final double? titleFontSize;
  final double? subtitleFontSize;
  final Color? titleColor;
  final Color? subtitleColor;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.textAlign = TextAlign.center,
    this.titleFontSize,
    this.subtitleFontSize,
    this.titleColor,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    // Use provided font sizes or responsive defaults
    final responsiveTitleFontSize = titleFontSize ?? responsive.headerTitleSize;
    final responsiveSubtitleFontSize =
        subtitleFontSize ?? responsive.headerSubtitleSize;

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
            fontSize: responsiveTitleFontSize,
            fontWeight: FontWeight.bold,
            color: titleColor ?? AppColors.primaryColor,
          ),
          textAlign: textAlign,
        ),
        if (subtitle != null) ...[
          SizedBox(height: responsive.getSpacing(4, 6, 8)),
          Text(
            subtitle!,
            style: GoogleFonts.nunito(
              fontSize: responsiveSubtitleFontSize,
              color: subtitleColor ?? AppColors.textSecondaryColor,
            ),
            textAlign: textAlign,
          ),
        ],
      ],
    );
  }
}
