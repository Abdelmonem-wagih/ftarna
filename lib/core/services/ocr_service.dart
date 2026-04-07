import 'dart:io';

import 'package:flutter/foundation.dart';

/// Extracted menu item from OCR
class ExtractedMenuItem {
  final String nameAr;
  final String nameEn;
  final double? price;
  final String? description;
  final String? category;
  final double confidence;

  const ExtractedMenuItem({
    required this.nameAr,
    required this.nameEn,
    this.price,
    this.description,
    this.category,
    this.confidence = 1.0,
  });

  @override
  String toString() => 'ExtractedMenuItem($nameEn, $price)';
}

/// Extracted category from OCR
class ExtractedCategory {
  final String nameAr;
  final String nameEn;
  final List<ExtractedMenuItem> items;

  const ExtractedCategory({
    required this.nameAr,
    required this.nameEn,
    this.items = const [],
  });
}

/// OCR extraction result
class MenuExtractionResult {
  final List<ExtractedCategory> categories;
  final List<ExtractedMenuItem> uncategorizedItems;
  final List<String> phoneNumbers;
  final String? restaurantName;
  final String rawText;
  final bool success;
  final String? errorMessage;

  const MenuExtractionResult({
    this.categories = const [],
    this.uncategorizedItems = const [],
    this.phoneNumbers = const [],
    this.restaurantName,
    this.rawText = '',
    this.success = true,
    this.errorMessage,
  });

  factory MenuExtractionResult.error(String message) {
    return MenuExtractionResult(
      success: false,
      errorMessage: message,
    );
  }

  int get totalItems =>
      categories.fold(0, (sum, c) => sum + c.items.length) +
      uncategorizedItems.length;
}

/// OCR Service for menu extraction
/// Note: This is a simplified implementation. For production,
/// integrate with Google ML Kit or Cloud Vision API.
class OcrService {
  /// Extract menu data from an image file
  Future<MenuExtractionResult> extractFromImage(File imageFile) async {
    try {
      // TODO: Implement with Google ML Kit or Cloud Vision API
      // Example with ML Kit:
      // final inputImage = InputImage.fromFile(imageFile);
      // final textRecognizer = TextRecognizer();
      // final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      // final text = recognizedText.text;
      // textRecognizer.close();

      // For now, return a mock result
      debugPrint('OCR: Processing image ${imageFile.path}');

      // Simulate processing delay
      await Future.delayed(const Duration(seconds: 2));

      return const MenuExtractionResult(
        success: true,
        rawText: 'Sample extracted text',
        categories: [],
        uncategorizedItems: [],
      );
    } catch (e) {
      return MenuExtractionResult.error('Failed to extract text: $e');
    }
  }

  /// Extract menu data from image bytes
  Future<MenuExtractionResult> extractFromBytes(Uint8List imageBytes) async {
    try {
      // TODO: Implement with Google ML Kit or Cloud Vision API
      debugPrint('OCR: Processing ${imageBytes.length} bytes');

      await Future.delayed(const Duration(seconds: 2));

      return const MenuExtractionResult(
        success: true,
        rawText: 'Sample extracted text',
        categories: [],
        uncategorizedItems: [],
      );
    } catch (e) {
      return MenuExtractionResult.error('Failed to extract text: $e');
    }
  }

  /// Parse raw OCR text into structured menu data
  MenuExtractionResult parseMenuText(String rawText) {
    final lines = rawText.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    final categories = <ExtractedCategory>[];
    final uncategorizedItems = <ExtractedMenuItem>[];
    final phoneNumbers = <String>[];
    String? currentCategory;
    final currentCategoryItems = <ExtractedMenuItem>[];

    for (final line in lines) {
      // Check for phone numbers
      final phoneMatches = RegExp(r'[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}')
          .allMatches(line);
      for (final match in phoneMatches) {
        phoneNumbers.add(match.group(0)!);
      }

      // Try to extract price
      final priceMatch = RegExp(r'(\d+(?:\.\d{1,2})?)\s*(?:EGP|جنيه|ج\.م|LE)?').firstMatch(line);

      if (priceMatch != null) {
        // This is likely a menu item
        final price = double.tryParse(priceMatch.group(1)!);
        final name = line.replaceFirst(priceMatch.group(0)!, '').trim();

        if (name.isNotEmpty && price != null) {
          final item = ExtractedMenuItem(
            nameAr: _detectArabic(name) ? name : '',
            nameEn: _detectArabic(name) ? '' : name,
            price: price,
          );

          if (currentCategory != null) {
            currentCategoryItems.add(item);
          } else {
            uncategorizedItems.add(item);
          }
        }
      } else if (_isPotentialCategory(line)) {
        // Save previous category
        if (currentCategory != null && currentCategoryItems.isNotEmpty) {
          categories.add(ExtractedCategory(
            nameAr: _detectArabic(currentCategory) ? currentCategory : '',
            nameEn: _detectArabic(currentCategory) ? '' : currentCategory,
            items: List.from(currentCategoryItems),
          ));
          currentCategoryItems.clear();
        }
        currentCategory = line;
      }
    }

    // Save last category
    if (currentCategory != null && currentCategoryItems.isNotEmpty) {
      categories.add(ExtractedCategory(
        nameAr: _detectArabic(currentCategory) ? currentCategory : '',
        nameEn: _detectArabic(currentCategory) ? '' : currentCategory,
        items: List.from(currentCategoryItems),
      ));
    }

    return MenuExtractionResult(
      categories: categories,
      uncategorizedItems: uncategorizedItems,
      phoneNumbers: phoneNumbers,
      rawText: rawText,
      success: true,
    );
  }

  /// Check if text contains Arabic characters
  bool _detectArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  /// Check if a line is potentially a category header
  bool _isPotentialCategory(String line) {
    // Categories are usually:
    // - All caps
    // - No price
    // - Short (less than 30 chars)
    // - Followed by items with prices
    if (line.length > 30) return false;
    if (RegExp(r'\d+(?:\.\d{1,2})?\s*(?:EGP|جنيه|ج\.م|LE)?').hasMatch(line)) return false;
    if (line == line.toUpperCase() && line.length > 3) return true;
    // Common category keywords
    final categoryKeywords = [
      'appetizers', 'starters', 'salads', 'soups', 'main', 'mains',
      'desserts', 'drinks', 'beverages', 'sides', 'sandwiches',
      'مقبلات', 'سلطات', 'شوربات', 'أطباق', 'حلويات', 'مشروبات',
      'ساندويتشات', 'وجبات',
    ];
    return categoryKeywords.any((k) => line.toLowerCase().contains(k));
  }
}
