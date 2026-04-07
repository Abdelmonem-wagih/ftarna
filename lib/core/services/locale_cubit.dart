import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleState {
  final Locale locale;

  const LocaleState(this.locale);
}

class LocaleCubit extends Cubit<LocaleState> {
  static const String _localeKey = 'locale';

  LocaleCubit() : super(const LocaleState(Locale('en'))) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey) ?? 'en';
    emit(LocaleState(Locale(localeCode)));
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    emit(LocaleState(locale));
  }

  void toggleLocale() {
    final newLocale = state.locale.languageCode == 'en'
        ? const Locale('ar')
        : const Locale('en');
    setLocale(newLocale);
  }
}
