import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LocalizationService {
  static const String vi = 'vi';
  static const String en = 'en';
  static const String path = 'assets/translations';

  static Future<void> initialize(BuildContext context) async {
    await EasyLocalization.ensureInitialized();
  }

  static void changeLocale(BuildContext context, String locale) {
    context.setLocale(Locale(locale));
  }

  static String getCurrentLocale(BuildContext context) {
    return context.locale.languageCode;
  }
}
