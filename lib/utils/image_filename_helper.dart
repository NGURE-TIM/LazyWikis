import 'package:lazywikis/data/models/image_data.dart';

class ImageFilenameHelper {
  static const int _maxBaseLength = 100;

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
      return '$captionBase$extension';
    }

    var guideBase = _sanitizeFilename(guideTitle);
    if (guideBase.isEmpty) {
      guideBase = 'image';
    }

    return '${guideBase}_step${stepIndex + 1}_${contentIndex + 1}$extension';
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
