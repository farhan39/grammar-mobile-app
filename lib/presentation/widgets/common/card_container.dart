import 'package:flutter/material.dart';
import 'package:grammar_checker/utility/constants/app_colors.dart';

class CardContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Color? backgroundColor;

  const CardContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.boxShadow,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
      ),
      child: child,
    );
  }
}
