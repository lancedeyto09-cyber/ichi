import 'package:flutter/material.dart';

class AdminResponsive {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width < 1200 &&
        MediaQuery.of(context).size.width >= 600;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  static double getResponsiveWidth(BuildContext context, double mobileWidth,
      double tabletWidth, double desktopWidth) {
    if (isMobile(context)) return mobileWidth;
    if (isTablet(context)) return tabletWidth;
    return desktopWidth;
  }
}
