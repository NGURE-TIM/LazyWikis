import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'image_data.dart';
import 'step_content.dart';

part 'step.g.dart';

enum StepType {
  textOnly,
  command,
  screenshot,
  textCommand,
  commandScreenshot,
  full, // Text + Command + Screenshot
}

@JsonSerializable()
class Step {
  final String id; // UUID
  final String title; // "Download ISO"
  final StepType type; // text, command, screenshot, mixed
  final String? description; // Rich text content (HTML or Delta)
  final String? command; // Command text
  final String? commandLanguage; // bash, python, etc.
  final bool showOutput; // Display command output?
  final String? output; // Command output text
  final ImageData? image; // Screenshot data
  final String? imageCaption; // Image caption
  final int? level; // Indentation level (0, 1, 2...)
  final int order; // Step order (for sorting)
  final List<StepContent> contents; // New flexible content list
  final bool isBold; // Bold title in sidebar
  final String? titleColor; // Hex color for title (e.g., '#FF5733')

  Step({
    required this.id,
    required this.title,
    required this.type,
    this.description,
    this.command,
    this.commandLanguage = 'bash',
    this.showOutput = false,
    this.output,
    this.image,
    this.imageCaption,
    required this.order,
    this.level = 0,
    this.contents = const [],
    this.isBold = false,
    this.titleColor,
  });

  // Factory constructor for creating a new empty step
  factory Step.create(StepType type, int order) {
    // Pre-populate content based on type
    final List<StepContent> initialContents = [];
    switch (type) {
      case StepType.textOnly:
        initialContents.add(StepContent.text());
        break;
      case StepType.command:
        initialContents.add(StepContent.command());
        break;
      case StepType.screenshot:
        initialContents.add(StepContent.image());
        break;
      case StepType.textCommand:
        initialContents.add(StepContent.text());
        initialContents.add(StepContent.command());
        break;
      case StepType.commandScreenshot:
        initialContents.add(StepContent.command());
        initialContents.add(StepContent.image());
        break;
      case StepType.full:
        initialContents.add(StepContent.text());
        initialContents.add(StepContent.command());
        initialContents.add(StepContent.image());
        break;
    }

    return Step(
      id: const Uuid().v4(),
      title: 'New Step',
      type: type,
      order: order,
      level: 0,
      contents: initialContents,
    );
  }

  Step copyWith({
    String? title,
    StepType? type,
    String? description,
    String? command,
    String? commandLanguage,
    bool? showOutput,
    String? output,
    ImageData? image,
    String? imageCaption,
    int? order,
    int? level,
    List<StepContent>? contents,
    bool? isBold,
    String? titleColor,
  }) {
    return Step(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      description: description ?? this.description,
      command: command ?? this.command,
      commandLanguage: commandLanguage ?? this.commandLanguage,
      showOutput: showOutput ?? this.showOutput,
      output: output ?? this.output,
      image: image ?? this.image,
      imageCaption: imageCaption ?? this.imageCaption,
      order: order ?? this.order,
      level: level ?? this.level,
      contents: contents ?? this.contents,
      isBold: isBold ?? this.isBold,
      titleColor: titleColor ?? this.titleColor,
    );
  }

  factory Step.fromJson(Map<String, dynamic> json) => _$StepFromJson(json);
  Map<String, dynamic> toJson() => _$StepToJson(this);
}
