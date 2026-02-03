import 'package:flutter/material.dart';

/// App-wide constants
class AppConstants {
  // App Info
  static const String appName = 'LazyWikis';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'MediaWiki Documentation Builder';

  // File Limits
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageExtensions = [
    'png',
    'jpg',
    'jpeg',
    'gif',
  ];

  // Default Values
  static const String defaultGuideTitle = 'New Guide';
  static const String defaultStepTitle = 'New Step';
  static const String defaultCommandLanguage = 'bash';

  // Storage Keys
  static const String storageKeyGuides = 'guides';
  static const String storageKeyWikiConnection = 'wiki_connection';
  static const String storageKeyThemeMode = 'theme_mode';
}
