import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grammar_checker/presentation/widgets/common/card_container.dart';
import 'package:grammar_checker/utility/constants/app_colors.dart';
import 'package:grammar_checker/utility/helpers/responsive_helper.dart';

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
    final responsive = context.responsive;

    return CardContainer(
      padding: padding ?? EdgeInsets.all(responsive.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: responsive.cardTitle,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.mediumSpacing),
          ...children,
        ],
      ),
    );
  }
}
