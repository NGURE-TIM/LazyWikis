import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:lazywikis/config/constants.dart';
import 'step.dart';
import 'guide_metadata.dart';

part 'guide.g.dart';

enum GuideStatus { draft, published }

@JsonSerializable()
class Guide {
  final String id; // UUID
  final String title; // "Ubuntu 24.04 Server Installation"
  final List<Step> steps; // List of documentation steps
  final List<String> categories; // ["Linux", "Ubuntu", "Server"]
  final GuideMetadata? metadata; // Optional metadata
  final Step? introduction; // Intro content
  final bool hasTableOfContents; // Include TOC?
  final DateTime createdAt;
  final DateTime updatedAt;
  final GuideStatus status; // Draft | Published

  Guide({
    required this.id,
    required this.title,
    this.steps = const [],
    this.categories = const [],
    this.metadata,
    this.introduction,
    this.hasTableOfContents = false,
    required this.createdAt,
    required this.updatedAt,
    this.status = GuideStatus.draft,
  });

  // Factory for creating a new guide
  factory Guide.create({String? title}) {
    final now = DateTime.now();
    return Guide(
      id: const Uuid().v4(),
      title: title ?? AppConstants.defaultGuideTitle,
      createdAt: now,
      updatedAt: now,
      steps: [], // Empty steps
    );
  }

  // CopyWith method
  Guide copyWith({
    String? title,
    List<Step>? steps,
    List<String>? categories,
    GuideMetadata? metadata,
    Step? introduction,
    bool? hasTableOfContents,
    DateTime? updatedAt,
    GuideStatus? status,
  }) {
    return Guide(
      id: id,
      title: title ?? this.title,
      steps: steps ?? this.steps,
      categories: categories ?? this.categories,
      metadata: metadata ?? this.metadata,
      introduction: introduction ?? this.introduction,
      hasTableOfContents: hasTableOfContents ?? this.hasTableOfContents,
      createdAt: createdAt, // Never changes
      updatedAt: updatedAt ?? DateTime.now(), // Auto-update timestamp
      status: status ?? this.status,
    );
  }

  factory Guide.fromJson(Map<String, dynamic> json) => _$GuideFromJson(json);
  Map<String, dynamic> toJson() => _$GuideToJson(this);
}
