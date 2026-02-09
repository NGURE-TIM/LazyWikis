// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'step.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Step _$StepFromJson(Map<String, dynamic> json) => Step(
  id: json['id'] as String,
  title: json['title'] as String,
  type: $enumDecode(_$StepTypeEnumMap, json['type']),
  description: json['description'] as String?,
  command: json['command'] as String?,
  commandLanguage: json['commandLanguage'] as String? ?? 'bash',
  showOutput: json['showOutput'] as bool? ?? false,
  output: json['output'] as String?,
  image: json['image'] == null
      ? null
      : ImageData.fromJson(json['image'] as Map<String, dynamic>),
  imageCaption: json['imageCaption'] as String?,
  order: (json['order'] as num).toInt(),
  level: (json['level'] as num?)?.toInt() ?? 0,
  contents:
      (json['contents'] as List<dynamic>?)
          ?.map((e) => StepContent.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  isBold: json['isBold'] as bool? ?? false,
  titleColor: json['titleColor'] as String?,
);

Map<String, dynamic> _$StepToJson(Step instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'type': _$StepTypeEnumMap[instance.type]!,
  'description': instance.description,
  'command': instance.command,
  'commandLanguage': instance.commandLanguage,
  'showOutput': instance.showOutput,
  'output': instance.output,
  'image': instance.image,
  'imageCaption': instance.imageCaption,
  'level': instance.level,
  'order': instance.order,
  'contents': instance.contents,
  'isBold': instance.isBold,
  'titleColor': instance.titleColor,
};

const _$StepTypeEnumMap = {
  StepType.textOnly: 'textOnly',
  StepType.command: 'command',
  StepType.screenshot: 'screenshot',
  StepType.textCommand: 'textCommand',
  StepType.commandScreenshot: 'commandScreenshot',
  StepType.full: 'full',
};
