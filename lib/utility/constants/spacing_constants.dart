import 'dart:io';

import 'package:flutter/material.dart';

class DesignSystem {
  static final bool isIOS = Platform.isIOS;
  static final bool isAndroid = Platform.isAndroid;

  static bool hasNotch(BuildContext context) {
    return MediaQuery.of(context).viewPadding.top > 20;
  }

  static bool hasDynamicIsland(BuildContext context) {
    final padding = MediaQuery.of(context).viewPadding;
    return isIOS && padding.top >= 54;
  }
}

class DeviceBreakpoints {
  static const double iPhoneSE = 320.0;
  static const double iPhoneMini = 360.0;
  static const double iPhone = 390.0;
  static const double iPhonePlus = 428.0;

  static const double androidCompact = 360.0;
  static const double androidMedium = 392.0;
  static const double androidExpanded = 412.0;
  static const double androidFoldable = 540.0;
}

class PlatformSpacing {
  static const double xs2 = 2.0;
  static const double xs4 = 4.0;
  static const double sm8 = 8.0;
  static const double sm12 = 12.0;
  static const double md16 = 16.0;
  static const double md20 = 20.0;
  static const double lg24 = 24.0;
  static const double lg28 = 28.0;
  static const double lg32 = 32.0;
  static const double xl36 = 36.0;
  static const double xl44 = 44.0;
  static const double xl40 = 40.0;
  static const double xl60 = 60.0;
  static const double xxl72 = 72.0;

  static const double xl48 = 48.0;
  static const double xxl56 = 56.0;
  static const double xxl64 = 64.0;
  static const double xxxl100 = 100.0;
  static const double xxxl120 = 120.0;
  static const double xxx140 = 140.0;
  static const double xxxl160 = 160.0;
  static const double xxxl180 = 180.0;
  static const double xxxl200 = 200.0;

  static const double iosTouchTarget = 44.0;
  static const double androidTouchTarget = 48.0;

  static const double iosNavBarHeight = 44.0;
  static const double androidToolbarHeight = 56.0;

  static const double iosTabBarHeight = 49.0;
  static const double androidNavBarHeight = 48.0;
}

class ResponsiveSpacing {
  static double getAdaptiveSpacing(
    BuildContext context,
    double baseSize, {
    bool allowNegative = false,
    double minScale = 0.75,
    double maxScale = 1.25,
    bool respectPlatform = true,
    bool considerDensity = true,
    bool adjustForFontScale = true,
    EdgeInsets? safeAreaOverride,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    final textScaleFactor = mediaQuery.textScaler.scale(1.0);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final viewInsets = mediaQuery.viewInsets;
    final viewPadding = safeAreaOverride ?? mediaQuery.viewPadding;
    final density = mediaQuery.devicePixelRatio;

    final availableWidth = screenWidth - viewPadding.left - viewPadding.right;
    final availableHeight =
        screenHeight - viewPadding.top - viewPadding.bottom - viewInsets.bottom;

    double scaleFactor = _calculateBaseScaleFactor(
      availableWidth,
      respectPlatform ? DesignSystem.isIOS : false,
    );

    if (respectPlatform) {
      scaleFactor *= DesignSystem.isIOS ? 0.95 : 1.0;
    }

    if (isLandscape) {
      scaleFactor *= _calculateLandscapeScale(availableHeight);
    }

    if (considerDensity) {
      scaleFactor *= _calculateDensityScale(density);
    }

    if (adjustForFontScale) {
      scaleFactor *= _calculateFontScale(textScaleFactor);
    }

    double finalSpacing = baseSize * scaleFactor;
    finalSpacing = finalSpacing.clamp(
      allowNegative ? -PlatformSpacing.xl48 : PlatformSpacing.xs2,
      PlatformSpacing.xxl64,
    );

    return finalSpacing;
  }

  static double _calculateBaseScaleFactor(double width, bool isIOS) {
    if (isIOS) {
      if (width <= DeviceBreakpoints.iPhoneSE) return 0.85;
      if (width <= DeviceBreakpoints.iPhoneMini) return 0.9;
      if (width <= DeviceBreakpoints.iPhone) return 1.0;
      if (width <= DeviceBreakpoints.iPhonePlus) return 1.1;
      return 1.15;
    } else {
      if (width <= DeviceBreakpoints.androidCompact) return 0.9;
      if (width <= DeviceBreakpoints.androidMedium) return 1.0;
      if (width <= DeviceBreakpoints.androidExpanded) return 1.1;
      return 1.15;
    }
  }

  static double _calculateLandscapeScale(double height) {
    if (height < 400) return 0.85;
    if (height < 500) return 0.9;
    return 0.95;
  }

  static double _calculateDensityScale(double density) {
    if (density <= 1.5) return 0.95;
    if (density <= 2.0) return 1.0;
    if (density <= 3.0) return 1.05;
    return 1.1;
  }

  static double _calculateFontScale(double textScale) {
    if (textScale <= 1.0) return 1.0;
    if (textScale <= 1.2) return 1.1;
    if (textScale <= 1.4) return 1.2;
    return 1.25;
  }
}

extension SpacingContextExtension on BuildContext {
  double get standardSpacing =>
      ResponsiveSpacing.getAdaptiveSpacing(this, PlatformSpacing.md16);

  double adaptiveSpacing(
    double value, {
    bool allowNegative = false,
    bool respectPlatform = true,
  }) {
    return ResponsiveSpacing.getAdaptiveSpacing(
      this,
      value,
      allowNegative: allowNegative,
      respectPlatform: respectPlatform,
    );
  }

  EdgeInsets get standardPadding => EdgeInsets.all(standardSpacing);
}

class ComponentSpacing {
  static EdgeInsets getListItemPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: context.adaptiveSpacing(PlatformSpacing.md16),
      vertical: context.adaptiveSpacing(PlatformSpacing.sm12),
    );
  }

  static EdgeInsets getButtonPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: context.adaptiveSpacing(PlatformSpacing.md16),
      vertical: context.adaptiveSpacing(
          DesignSystem.isIOS ? PlatformSpacing.sm12 : PlatformSpacing.sm8),
    );
  }
}
