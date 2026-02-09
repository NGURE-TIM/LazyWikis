// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageData _$ImageDataFromJson(Map<String, dynamic> json) => ImageData(
  filename: json['filename'] as String,
  base64Data: json['base64Data'] as String,
  mimeType: json['mimeType'] as String,
  fileSizeBytes: (json['fileSizeBytes'] as num).toInt(),
  annotations: (json['annotations'] as List<dynamic>?)
      ?.map((e) => ImageAnnotation.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ImageDataToJson(ImageData instance) => <String, dynamic>{
  'filename': instance.filename,
  'base64Data': instance.base64Data,
  'mimeType': instance.mimeType,
  'fileSizeBytes': instance.fileSizeBytes,
  'annotations': instance.annotations?.map((e) => e.toJson()).toList(),
};
