import 'package:flutter/material.dart';

class ResponsiveHelper {
  static ResponsiveHelper? _instance;
  late Size _screenSize;
  late double _screenWidth;
  late double _screenHeight;

  ResponsiveHelper._internal();

  static ResponsiveHelper get instance {
    _instance ??= ResponsiveHelper._internal();
    return _instance!;
  }

  // Initialize with screen size from MediaQuery
  void init(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    _screenWidth = _screenSize.width;
    _screenHeight = _screenSize.height;
  }

  // Breakpoint definitions
  bool get isVerySmallScreen => _screenWidth < 360;
  bool get isSmallScreen => _screenWidth < 600;
  bool get isMediumScreen => _screenWidth >= 600 && _screenWidth < 768;
  bool get isTablet => _screenWidth >= 768;
  bool get isLargeTablet => _screenWidth >= 1024;
  bool get isDesktop => _screenWidth >= 1200;

  // Screen size getters
  double get screenWidth => _screenWidth;
  double get screenHeight => _screenHeight;
  Size get screenSize => _screenSize;

  // Responsive spacing
  double get horizontalPadding {
    if (isVerySmallScreen) return 12.0;
    if (isSmallScreen) return 16.0;
    if (isTablet) return 32.0;
    return 20.0;
  }

  double get verticalPadding {
    if (isVerySmallScreen) return 12.0;
    if (isSmallScreen) return 16.0;
    if (isTablet) return 24.0;
    return 20.0;
  }

  double get cardPadding {
    if (isVerySmallScreen) return 16.0;
    if (isSmallScreen) return 18.0;
    if (isTablet) return 24.0;
    return 20.0;
  }

  double get sectionSpacing {
    if (isSmallScreen) return 16.0;
    if (isTablet) return 40.0;
    return 32.0;
  }

  double get cardSpacing {
    if (isSmallScreen) return 16.0;
    if (isTablet) return 32.0;
    return 24.0;
  }

  double get smallSpacing {
    if (isSmallScreen) return 12.0;
    return 16.0;
  }

  double get mediumSpacing {
    if (isVerySmallScreen) return 12.0;
    if (isSmallScreen) return 16.0;
    return 20.0;
  }

  double get largeSpacing {
    if (isSmallScreen) return 20.0;
    if (isTablet) return 32.0;
    return 24.0;
  }

  // Responsive font sizes
  double get headerTitleSize {
    if (isVerySmallScreen) return 24.0;
    if (isSmallScreen) return 28.0;
    if (isTablet) return 36.0;
    return 32.0;
  }

  double get headerSubtitleSize {
    if (isVerySmallScreen) return 14.0;
    if (isTablet) return 18.0;
    return 16.0;
  }

  double get pageTitle {
    if (isVerySmallScreen) return 20.0;
    if (isSmallScreen) return 22.0;
    if (isTablet) return 28.0;
    return 24.0;
  }

  double get cardTitle {
    if (isVerySmallScreen) return 20.0;
    if (isSmallScreen) return 22.0;
    if (isTablet) return 26.0;
    return 24.0;
  }

  double get sectionTitle {
    if (isVerySmallScreen) return 14.0;
    if (isSmallScreen) return 15.0;
    if (isTablet) return 18.0;
    return 16.0;
  }

  double get bodyText {
    if (isVerySmallScreen) return 12.0;
    if (isSmallScreen) return 13.0;
    if (isTablet) return 16.0;
    return 14.0;
  }

  double get smallText {
    if (isVerySmallScreen) return 10.0;
    if (isTablet) return 12.0;
    return 11.0;
  }

  double get buttonText {
    if (isVerySmallScreen) return 14.0;
    if (isTablet) return 18.0;
    return 16.0;
  }

  // Icon sizes
  double get smallIcon {
    if (isVerySmallScreen) return 16.0;
    if (isTablet) return 22.0;
    return 20.0;
  }

  double get mediumIcon {
    if (isVerySmallScreen) return 20.0;
    if (isTablet) return 28.0;
    return 24.0;
  }

  double get largeIcon {
    if (isVerySmallScreen) return 24.0;
    if (isTablet) return 36.0;
    return 32.0;
  }

  // Layout helpers
  double get maxContentWidth {
    if (isTablet) return 1000.0;
    if (isLargeTablet) return 1200.0;
    return double.infinity;
  }

  double get authCardMaxWidth {
    if (isSmallScreen) return double.infinity;
    if (isTablet) return 500.0;
    return 400.0;
  }

  // Responsive heights
  double get textFieldLines {
    if (isSmallScreen) return 4.0;
    if (isTablet) return 8.0;
    return 6.0;
  }

  // Auth screen specific spacing
  double get authTopSpacing => isSmallScreen ? (_screenHeight * 0.05) : 60.0;
  double get authHeaderSpacing => isSmallScreen ? (_screenHeight * 0.04) : 60.0;
  double get authBottomSpacing => isSmallScreen ? 20.0 : 40.0;

  // Button padding
  EdgeInsets get buttonPadding {
    if (isVerySmallScreen) {
      return const EdgeInsets.symmetric(vertical: 12, horizontal: 16);
    }
    if (isTablet) {
      return const EdgeInsets.symmetric(vertical: 18, horizontal: 24);
    }
    return const EdgeInsets.symmetric(vertical: 16, horizontal: 20);
  }

  // Layout decisions
  bool get shouldUseTabletLayout => isTablet;
  bool get shouldStackButtonsVertically => isVerySmallScreen;
  bool get shouldUseSideBarLayout => isLargeTablet;

  // Custom spacing method
  double getSpacing(double small, double medium, double large) {
    if (isVerySmallScreen || isSmallScreen) return small;
    if (isTablet) return large;
    return medium;
  }

  // Custom font size method
  double getFontSize(double small, double medium, double large) {
    if (isVerySmallScreen) return small;
    if (isSmallScreen) return medium;
    if (isTablet) return large;
    return medium;
  }

  // Edge insets helpers
  EdgeInsets get screenPadding => EdgeInsets.all(horizontalPadding);

  EdgeInsets get cardMargin {
    return EdgeInsets.symmetric(
      horizontal: horizontalPadding,
      vertical: verticalPadding / 2,
    );
  }

  EdgeInsets get sectionPadding {
    return EdgeInsets.symmetric(
      horizontal: horizontalPadding,
      vertical: sectionSpacing,
    );
  }
}

// Extension for easy access in widgets
extension ResponsiveContext on BuildContext {
  ResponsiveHelper get responsive {
    ResponsiveHelper.instance.init(this);
    return ResponsiveHelper.instance;
  }
}
