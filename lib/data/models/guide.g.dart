// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guide.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Guide _$GuideFromJson(Map<String, dynamic> json) => Guide(
  id: json['id'] as String,
  title: json['title'] as String,
  steps:
      (json['steps'] as List<dynamic>?)
          ?.map((e) => Step.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  metadata: json['metadata'] == null
      ? null
      : GuideMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
  introduction: json['introduction'] == null
      ? null
      : Step.fromJson(json['introduction'] as Map<String, dynamic>),
  hasTableOfContents: json['hasTableOfContents'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  status:
      $enumDecodeNullable(_$GuideStatusEnumMap, json['status']) ??
      GuideStatus.draft,
);

Map<String, dynamic> _$GuideToJson(Guide instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'steps': instance.steps,
  'categories': instance.categories,
  'metadata': instance.metadata,
  'introduction': instance.introduction,
  'hasTableOfContents': instance.hasTableOfContents,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'status': _$GuideStatusEnumMap[instance.status]!,
};

const _$GuideStatusEnumMap = {
  GuideStatus.draft: 'draft',
  GuideStatus.published: 'published',
};
