import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:lazywikis/config/constants.dart';
import 'package:lazywikis/data/models/image_data.dart';
import 'package:lazywikis/utils/exceptions.dart';

class ImageHandlerService {
  /// Pick an image file and convert to ImageData
  Future<ImageData?> pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: AppConstants.allowedImageExtensions,
        withData: true, // Need bytes for web
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = result.files.first;

      // Validate size
      if (file.size > AppConstants.maxImageSizeBytes) {
        throw ValidationException('Image size exceeds 5MB limit');
      }

      // Convert to base64
      final bytes = file.bytes;
      if (bytes == null) {
        throw ValidationException('Could not read file data');
      }

      final base64String = base64Encode(bytes);
      final mimeType =
          'image/${file.extension ?? "png"}'; // Simplified mime type guessing

      return ImageData(
        filename: file.name,
        base64Data: base64String,
        mimeType: mimeType,
        fileSizeBytes: file.size,
      );
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw StorageException('Failed to pick image', e);
    }
  }
}
