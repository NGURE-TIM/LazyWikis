// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'step_content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StepContent _$StepContentFromJson(Map<String, dynamic> json) => StepContent(
  id: json['id'] as String,
  type: $enumDecode(_$StepContentTypeEnumMap, json['type']),
  text: json['text'] as String?,
  language: json['language'] as String? ?? 'bash',
  showOutput: json['showOutput'] as bool? ?? false,
  output: json['output'] as String?,
  image: json['image'] == null
      ? null
      : ImageData.fromJson(json['image'] as Map<String, dynamic>),
  caption: json['caption'] as String?,
);

Map<String, dynamic> _$StepContentToJson(StepContent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$StepContentTypeEnumMap[instance.type]!,
      'text': instance.text,
      'language': instance.language,
      'showOutput': instance.showOutput,
      'output': instance.output,
      'image': instance.image,
      'caption': instance.caption,
    };

const _$StepContentTypeEnumMap = {
  StepContentType.text: 'text',
  StepContentType.command: 'command',
  StepContentType.image: 'image',
};
