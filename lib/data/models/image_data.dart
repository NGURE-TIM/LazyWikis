import 'package:json_annotation/json_annotation.dart';
import 'image_annotation.dart';

part 'image_data.g.dart';

@JsonSerializable(explicitToJson: true)
class ImageData {
  final String filename; // "ubuntu_boot_screen.png"
  final String base64Data; // Base64 encoded image
  final String mimeType; // "image/png"
  final int fileSizeBytes;
  final String? caption; // Optional caption for filename/display
  final List<ImageAnnotation>? annotations; // Optional drawing annotations

  ImageData({
    required this.filename,
    required this.base64Data,
    required this.mimeType,
    required this.fileSizeBytes,
    this.caption,
    this.annotations,
  });

  // Max 5MB validation
  bool get isValid => fileSizeBytes <= 5 * 1024 * 1024;

  ImageData copyWith({
    String? filename,
    String? caption,
    List<ImageAnnotation>? annotations,
  }) {
    return ImageData(
      filename: filename ?? this.filename,
      base64Data: base64Data,
      mimeType: mimeType,
      fileSizeBytes: fileSizeBytes,
      caption: caption ?? this.caption,
      annotations: annotations ?? this.annotations,
    );
  }

  factory ImageData.fromJson(Map<String, dynamic> json) =>
      _$ImageDataFromJson(json);
  Map<String, dynamic> toJson() => _$ImageDataToJson(this);
}
