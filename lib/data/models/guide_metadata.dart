import 'package:json_annotation/json_annotation.dart';

part 'guide_metadata.g.dart';

@JsonSerializable()
class GuideMetadata {
  final String? version; // "24.04 LTS"
  final String? author; // "John Doe"
  final DateTime? date;
  final String? description; // Brief summary

  GuideMetadata({this.version, this.author, this.date, this.description});

  // Create copyWith
  GuideMetadata copyWith({
    String? version,
    String? author,
    DateTime? date,
    String? description,
  }) {
    return GuideMetadata(
      version: version ?? this.version,
      author: author ?? this.author,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }

  factory GuideMetadata.fromJson(Map<String, dynamic> json) =>
      _$GuideMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$GuideMetadataToJson(this);
}
