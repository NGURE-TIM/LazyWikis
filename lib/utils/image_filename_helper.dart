import 'package:lazywikis/data/models/image_data.dart';

class ImageFilenameHelper {
  static const int _maxBaseLength = 100;
  static const Set<String> _ignoredGuideWords = {
    'the',
    'a',
    'an',
    'installation',
    'setup',
    'guide',
    'configuration',
    'tutorial',
    'how',
    'to',
  };

  static String generateImageFilename(
    ImageData image, {
    required int stepIndex,
    required int contentIndex,
    String? guideTitle,
    String? caption,
  }) {
    final extension = _getExtension(
      image.mimeType,
      originalName: image.filename,
    );
    final captionSource = caption ?? image.caption;
    final captionBase = _sanitizeFilename(
      _stripKnownImageExtension(captionSource),
    );

    if (captionBase.isNotEmpty) {
      final prefix = _generateGuidePrefix(guideTitle);
      return '${captionBase}_$prefix$extension';
    }

    var guideBase = _sanitizeFilename(guideTitle);
    if (guideBase.isEmpty) {
      guideBase = 'image';
    }

    return '${guideBase}_step${stepIndex + 1}_${contentIndex + 1}$extension';
  }

  static String _generateGuidePrefix(String? guideTitle) {
    if (guideTitle == null || guideTitle.trim().isEmpty) {
      return 'img';
    }

    final normalized = guideTitle.trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      ' ',
    );
    final allTokens = normalized
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList();
    if (allTokens.isEmpty) return 'img';

    final filteredTokens = allTokens
        .where((token) => !_ignoredGuideWords.contains(token))
        .toList();
    final relevantTokens = filteredTokens.isNotEmpty
        ? filteredTokens
        : allTokens;
    final wordTokens = relevantTokens
        .where((token) => RegExp(r'[a-z]').hasMatch(token))
        .toList();
    final versionMatch = RegExp(r'\d+').firstMatch(relevantTokens.join(' '));
    var versionPart = versionMatch?.group(0) ?? '';
    if (versionPart.length > 3) {
      versionPart = versionPart.substring(0, 3);
    }

    String letters;
    if (wordTokens.isEmpty) {
      letters = relevantTokens.first.substring(0, 1);
    } else if (wordTokens.length == 1) {
      final word = wordTokens.first;
      if (versionPart.isNotEmpty) {
        if (word.endsWith('bsd') && word.length > 3) {
          letters = '${word[0]}b';
        } else {
          letters = word.substring(0, 1);
        }
      } else {
        final letterCount = word.length >= 4 ? 4 : word.length;
        letters = word.substring(0, letterCount);
      }
    } else {
      final letterLimit = versionPart.isNotEmpty ? 2 : 3;
      letters = wordTokens.take(letterLimit).map((word) => word[0]).join();
    }

    String prefix;
    if (versionPart.isNotEmpty) {
      final maxLetters = 4 - versionPart.length;
      if (maxLetters <= 0) {
        prefix = versionPart.substring(0, 4);
      } else {
        final clippedLetters = letters.isEmpty
            ? 'i'
            : letters.substring(
                0,
                letters.length > maxLetters ? maxLetters : letters.length,
              );
        prefix = '$clippedLetters$versionPart';
      }
    } else {
      final safeLetters = letters.isEmpty ? 'img' : letters;
      prefix = safeLetters.length > 4
          ? safeLetters.substring(0, 4)
          : safeLetters;
    }

    prefix = prefix.toLowerCase();
    return prefix.isEmpty ? 'img' : prefix;
  }

  static String _sanitizeFilename(String? input) {
    if (input == null) return '';

    var value = input.trim();
    if (value.isEmpty) return '';

    // Normalize spacing before stripping unsupported characters.
    value = value.replaceAll(RegExp(r'\s+'), '_');
    // Remove MediaWiki-problematic characters and other special symbols.
    value = value.replaceAll(RegExp("[#<>\\[\\]|{}\\\\/:\"'?]"), '');
    // Keep only alphanumeric, underscore, hyphen, and period.
    value = value.replaceAll(RegExp(r'[^A-Za-z0-9_.-]'), '');
    // Collapse repeated separators.
    value = value.replaceAll(RegExp(r'_+'), '_');
    value = value.replaceAll(RegExp(r'-+'), '-');
    // Avoid leading/trailing separators.
    value = value.replaceAll(RegExp(r'^[_\-.]+|[_\-.]+$'), '');

    if (value.length > _maxBaseLength) {
      value = value.substring(0, _maxBaseLength);
      value = value.replaceAll(RegExp(r'^[_\-.]+|[_\-.]+$'), '');
    }

    return value;
  }

  static String _stripKnownImageExtension(String? input) {
    if (input == null) return '';
    return input.replaceFirst(
      RegExp(r'\.(png|jpg|jpeg|gif|webp)$', caseSensitive: false),
      '',
    );
  }

  static String _getExtension(String? mimeType, {String? originalName}) {
    final normalized = mimeType?.toLowerCase().trim() ?? '';
    switch (normalized) {
      case 'image/png':
        return '.png';
      case 'image/jpeg':
      case 'image/jpg':
        return '.jpg';
      case 'image/gif':
        return '.gif';
      case 'image/webp':
        return '.webp';
      default:
        final original = (originalName ?? '').toLowerCase();
        if (original.endsWith('.png')) return '.png';
        if (original.endsWith('.jpg') || original.endsWith('.jpeg')) {
          return '.jpg';
        }
        if (original.endsWith('.gif')) return '.gif';
        if (original.endsWith('.webp')) return '.webp';
        return '.png';
    }
  }
}
