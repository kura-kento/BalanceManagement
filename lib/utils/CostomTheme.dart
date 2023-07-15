import 'package:balancemanagement_app/utils/shared_prefs.dart';
import 'package:flutter/material.dart';

class CustomTheme {
  static int kBluePrimaryValue = SharedPrefs.isInstance() ? 0xDD000000 : int.parse(SharedPrefs.getCustomColor());
  // static int kBluePrimaryValue = 0xDD000000;
  static  MaterialColor primaryColor = MaterialColor(
    kBluePrimaryValue,
    <int, Color>{
      50: Color(kBluePrimaryValue),
      100: Color(kBluePrimaryValue),
      200: Color(kBluePrimaryValue),
      300: Color(kBluePrimaryValue),
      400: Color(kBluePrimaryValue),
      500: Color(kBluePrimaryValue),
      600: const Color(0xFF1E88E5),
      700: const Color(0xFF1976D2),
      800: const Color(0xFF1565C0),
      900: const Color(0xFF0D47A1),
    },
  );
}
