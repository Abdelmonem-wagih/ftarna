import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';


extension BuildContextExtensions on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  TextTheme get textTheme => Theme.of(this).textTheme;

  Size get screenSize => MediaQuery.of(this).size;

  double get screenWidth => MediaQuery.of(this).size.width;

  double get screenHeight => MediaQuery.of(this).size.height;

  bool get isRtl => Directionality.of(this) == TextDirection.rtl;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void showErrorSnackBar(String message) {
    showSnackBar(message, isError: true);
  }

  void showSuccessSnackBar(String message) {
    showSnackBar(message, isError: false);
  }
}

extension StringExtensions on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  bool get isValidPhone {
    return RegExp(r'^\+?[0-9]{10,14}$').hasMatch(this);
  }
}

extension DoubleExtensions on double {
  String toCurrency() {
    return '${toStringAsFixed(2)} EGP';
  }
}

extension DateTimeExtensions on DateTime {
  String toDateString() {
    return '$day/$month/$year';
  }

  String toTimeString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String toDateTimeString() {
    return '${toDateString()} ${toTimeString()}';
  }

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}
