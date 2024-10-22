import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:nawa_niwasa/service/preferences.dart';

class AppLocaleHandler extends ValueNotifier<Locale?> {
  AppLocaleHandler(Locale? locale, {required this.preference}) : super(locale);

  final AppPreference preference;

  Future<AppLocaleHandler> readLocate() async {
    final l0 = await preference.readLocalePreference();
    if (l0 != null) setLocale(l0);
    return this;
  }

  setLocale(Locale locale) {
    value = locale;
    notifyListeners();
  }

  bool get hasLocale => value != null;
}
