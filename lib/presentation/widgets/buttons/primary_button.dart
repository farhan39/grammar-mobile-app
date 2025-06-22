import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:grammar_checker/utility/constants/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Widget? icon;
  final double? elevation;
  final bool isOutlined;
  final Color? borderColor;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
    this.fontSize,
    this.fontWeight,
    this.icon,
    this.elevation,
    this.isOutlined = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive sizing
    final responsiveFontSize = fontSize ?? (screenWidth < 360 ? 14 : 16);
    final responsivePadding =
        padding ??
        EdgeInsets.symmetric(
          vertical: screenWidth < 360 ? 12 : 16,
          horizontal: screenWidth < 360 ? 16 : 20,
        );
    final indicatorSize = screenWidth < 360 ? 18.0 : 20.0;

    final buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
            foregroundColor: foregroundColor ?? AppColors.primaryColor,
            side: BorderSide(color: borderColor ?? AppColors.primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 12),
            ),
            padding: responsivePadding,
            elevation: elevation ?? 0,
          )
        : ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.primaryColor,
            foregroundColor: foregroundColor ?? Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 12),
            ),
            padding: responsivePadding,
            elevation: elevation ?? 0,
          );

    final buttonChild = isLoading
        ? SizedBox(
            height: indicatorSize,
            width: indicatorSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOutlined
                    ? (foregroundColor ?? AppColors.primaryColor)
                    : (foregroundColor ?? Colors.white),
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Flexible(
                child: AutoSizeText(
                  text,
                  maxLines: 1,
                  minFontSize: 10,
                  style: GoogleFonts.nunito(
                    fontSize: responsiveFontSize,
                    fontWeight: fontWeight ?? FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    return SizedBox(
      width: double.infinity,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: buttonStyle,
              child: buttonChild,
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: buttonStyle,
              child: buttonChild,
            ),
    );
  }
}
