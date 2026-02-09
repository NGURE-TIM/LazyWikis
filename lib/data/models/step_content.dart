import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'image_data.dart';

part 'step_content.g.dart';

enum StepContentType { text, command, image }

@JsonSerializable()
class StepContent {
  final String id;
  final StepContentType type;

  // Text Content
  final String? text; // Rich text JSON or plain text

  // Command Content
  final String? language; // 'bash', 'python', etc.
  final bool showOutput;
  final String? output; // Command output text

  // Image Content
  final ImageData? image;
  final String? caption;

  StepContent({
    required this.id,
    required this.type,
    this.text,
    this.language = 'bash',
    this.showOutput = false,
    this.output,
    this.image,
    this.caption,
  });

  factory StepContent.text({String? content}) {
    return StepContent(
      id: const Uuid().v4(),
      type: StepContentType.text,
      text: content ?? '',
    );
  }

  factory StepContent.command({
    String? command,
    String? language,
    bool showOutput = false,
    String? output,
  }) {
    return StepContent(
      id: const Uuid().v4(),
      type: StepContentType.command,
      text:
          command ?? '', // Using 'text' field for command string to save space
      language: language ?? 'bash',
      showOutput: showOutput,
      output: output,
    );
  }

  factory StepContent.image({ImageData? image, String? caption}) {
    return StepContent(
      id: const Uuid().v4(),
      type: StepContentType.image,
      image: image,
      caption: caption,
    );
  }

  StepContent copyWith({
    String? text,
    String? language,
    bool? showOutput,
    String? output,
    ImageData? image,
    bool clearImage = false,
    String? caption,
  }) {
    return StepContent(
      id: id,
      type: type,
      text: text ?? this.text,
      language: language ?? this.language,
      showOutput: showOutput ?? this.showOutput,
      output: output ?? this.output,
      image: clearImage ? null : (image ?? this.image),
      caption: caption ?? this.caption,
    );
  }

  factory StepContent.fromJson(Map<String, dynamic> json) =>
      _$StepContentFromJson(json);
  Map<String, dynamic> toJson() => _$StepContentToJson(this);
}
