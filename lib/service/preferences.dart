import 'dart:async';
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

class AppPreference {
  SharedPreferences? instance;
  Locale? _locale;

  init() async {
    instance = await SharedPreferences.getInstance();
  }

  FutureOr _initIfNot() async {
    if (instance == null) await init();
  }

  Future<Locale?> readLocalePreference() async {
    if (_locale != null) return _locale;

    await _initIfNot();
    final String? locale = instance!.getString("locale");
    if (locale != null) _locale = Locale(locale);
    return _locale;
  }

  writeLocalePreference(String value) async {
    await _initIfNot();
    await instance!.setString("locale", value);
  }
}
