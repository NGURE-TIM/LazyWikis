// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_annotation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageAnnotation _$ImageAnnotationFromJson(Map<String, dynamic> json) =>
    ImageAnnotation(
      id: json['id'] as String,
      type: $enumDecode(_$AnnotationTypeEnumMap, json['type']),
      start: ImageAnnotation._offsetFromJson(
        json['start'] as Map<String, dynamic>,
      ),
      end: ImageAnnotation._offsetFromJson(json['end'] as Map<String, dynamic>),
      color: ImageAnnotation._colorFromJson((json['color'] as num).toInt()),
      strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 3.0,
    );

Map<String, dynamic> _$ImageAnnotationToJson(ImageAnnotation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$AnnotationTypeEnumMap[instance.type]!,
      'start': ImageAnnotation._offsetToJson(instance.start),
      'end': ImageAnnotation._offsetToJson(instance.end),
      'color': ImageAnnotation._colorToJson(instance.color),
      'strokeWidth': instance.strokeWidth,
    };

const _$AnnotationTypeEnumMap = {
  AnnotationType.arrow: 'arrow',
  AnnotationType.circle: 'circle',
  AnnotationType.rectangle: 'rectangle',
};
