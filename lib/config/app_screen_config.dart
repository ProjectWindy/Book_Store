import 'package:flutter/material.dart';

class AppScreenConfig {
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double blockSizeHorizontal(BuildContext context) {
    return screenWidth(context) / 100;
  }

  static double blockSizeVertical(BuildContext context) {
    return screenHeight(context) / 100;
  }

  static double safeBlockHorizontal(BuildContext context) {
    return (screenWidth(context) -
            MediaQuery.of(context).padding.left -
            MediaQuery.of(context).padding.right) /
        100;
  }

  static double safeBlockVertical(BuildContext context) {
    return (screenHeight(context) -
            MediaQuery.of(context).padding.top -
            MediaQuery.of(context).padding.bottom) /
        100;
  }
}
