import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'image_annotation.g.dart';

enum AnnotationType { arrow, circle, rectangle }

@JsonSerializable()
class ImageAnnotation {
  final String id;
  final AnnotationType type;

  @JsonKey(fromJson: _offsetFromJson, toJson: _offsetToJson)
  final Offset start;

  @JsonKey(fromJson: _offsetFromJson, toJson: _offsetToJson)
  final Offset end;

  @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
  final Color color;

  final double strokeWidth;

  ImageAnnotation({
    required this.id,
    required this.type,
    required this.start,
    required this.end,
    required this.color,
    this.strokeWidth = 3.0,
  });

  factory ImageAnnotation.create({
    required AnnotationType type,
    required Offset start,
    required Offset end,
    Color? color,
    double? strokeWidth,
  }) {
    return ImageAnnotation(
      id: const Uuid().v4(),
      type: type,
      start: start,
      end: end,
      color: color ?? Colors.red,
      strokeWidth: strokeWidth ?? 3.0,
    );
  }

  ImageAnnotation copyWith({
    Offset? start,
    Offset? end,
    Color? color,
    double? strokeWidth,
  }) {
    return ImageAnnotation(
      id: id,
      type: type,
      start: start ?? this.start,
      end: end ?? this.end,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }

  // JSON serialization helpers for Offset
  static Offset _offsetFromJson(Map<String, dynamic> json) {
    return Offset(
      (json['dx'] as num).toDouble(),
      (json['dy'] as num).toDouble(),
    );
  }

  static Map<String, dynamic> _offsetToJson(Offset offset) {
    return {'dx': offset.dx, 'dy': offset.dy};
  }

  // JSON serialization helpers for Color
  static Color _colorFromJson(int value) {
    return Color(value);
  }

  static int _colorToJson(Color color) {
    return color.value;
  }

  factory ImageAnnotation.fromJson(Map<String, dynamic> json) =>
      _$ImageAnnotationFromJson(json);
  Map<String, dynamic> toJson() => _$ImageAnnotationToJson(this);
}
