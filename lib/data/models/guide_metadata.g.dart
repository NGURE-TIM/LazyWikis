// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guide_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GuideMetadata _$GuideMetadataFromJson(Map<String, dynamic> json) =>
    GuideMetadata(
      version: json['version'] as String?,
      author: json['author'] as String?,
      date: json['date'] == null
          ? null
          : DateTime.parse(json['date'] as String),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$GuideMetadataToJson(GuideMetadata instance) =>
    <String, dynamic>{
      'version': instance.version,
      'author': instance.author,
      'date': instance.date?.toIso8601String(),
      'description': instance.description,
    };
