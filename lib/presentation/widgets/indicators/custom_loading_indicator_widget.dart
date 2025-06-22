import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomLoadingIndicator extends StatelessWidget {
  final double sizePercentage;

  final String? loadingText;

  final List<Color>? gradientColors;

  final TextStyle? textStyle;

  final Color? progressColor;

  final bool isDark;

  const CustomLoadingIndicator({
    super.key,
    this.sizePercentage = 0.4,
    this.loadingText = "Please wait...",
    this.gradientColors,
    this.textStyle,
    this.progressColor,
    this.isDark = false,
  }) : assert(
         sizePercentage > 0 && sizePercentage <= 1.0,
         "sizePercentage must be between 0 and 1",
       );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = MediaQuery.of(context).size;
        final shortestSide = screenSize.shortestSide;

        final baseSize = shortestSide * sizePercentage;

        final containerSize = baseSize.clamp(
          48.0,
          constraints.maxWidth < constraints.maxHeight
              ? constraints.maxWidth
              : constraints.maxHeight,
        );

        final proportions = _LoadingIndicatorProportions(containerSize);

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: containerSize * 1.2,
              maxHeight: containerSize * 1.5,
            ),
            child: Padding(
              padding: EdgeInsets.all(proportions.padding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: proportions.containerWidth,
                    height: proportions.containerHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors:
                            gradientColors ??
                            [
                              Colors.blue,
                              Colors.green,
                            ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(
                        proportions.borderRadius,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: proportions.borderRadius / 2,
                          offset: Offset(0, proportions.borderRadius / 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: SizedBox(
                        width: proportions.progressSize,
                        height: proportions.progressSize,
                        child: CupertinoActivityIndicator(
                          animating: true,
                          color:
                              progressColor ??
                              Color(0xff212121).withValues(alpha: 0.5),
                          radius: proportions.progressSize / 3,
                        ),
                      ),
                    ),
                  ),
                  if (loadingText != null || textStyle != null) ...[
                    SizedBox(height: proportions.spacing),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        loadingText ?? "Please wait...",
                        textAlign: TextAlign.center,
                        style:
                            textStyle?.copyWith(
                              fontSize: proportions.fontSize,
                              color: isDark
                                  ? const Color(0xffF9F9F9)
                                  : const Color(0xff212121),
                            ) ??
                            TextStyle(
                              fontSize: proportions.fontSize,
                              color: isDark
                                  ? const Color(0xffF9F9F9)
                                  : const Color(0xff212121),
                              fontWeight: FontWeight.w400,
                              fontFamily: GoogleFonts.poppins().fontFamily,
                            ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LoadingIndicatorProportions {
  final double containerSize;

  const _LoadingIndicatorProportions(this.containerSize);

  double get padding => containerSize * 0.08;
  double get progressSize => containerSize * 0.35;
  double get fontSize => containerSize * 0.09;
  double get spacing => containerSize * 0.12;
  double get borderRadius => containerSize * 0.1;
  double get strokeWidth => containerSize * 0.01;
  double get containerWidth => containerSize * 0.45;
  double get containerHeight => containerSize * 0.45;
}
