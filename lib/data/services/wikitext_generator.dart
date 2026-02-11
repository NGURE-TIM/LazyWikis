import 'package:lazywikis/data/models/guide.dart';
import 'package:lazywikis/data/models/guide_metadata.dart';
import 'package:lazywikis/data/models/image_data.dart';
import 'package:lazywikis/data/models/step.dart';
import 'package:lazywikis/data/models/step_content.dart';
import 'package:lazywikis/config/constants.dart';
import 'package:lazywikis/utils/image_filename_helper.dart';
import 'package:lazywikis/utils/quill_to_wikitext.dart';

class WikiTextGenerator {
  /// Converts Guide object to MediaWiki markup
  String generate(Guide guide, {bool includeToc = true}) {
    final buffer = StringBuffer();
    final guideTitle = _sanitizeHeadingText(guide.title, fallback: 'Guide');

    // Title (Level 1 heading)
    buffer.writeln('= $guideTitle =');
    buffer.writeln();

    // Table of Contents (if included)
    if (includeToc && guide.hasTableOfContents) {
      buffer.writeln('__TOC__');
      buffer.writeln();
    }

    // Metadata section (optional)
    if (guide.metadata != null) {
      _appendSection(buffer, _generateMetadata(guide.metadata!));
    }

    // Introduction section
    if (guide.introduction != null) {
      final introBuffer = StringBuffer();
      introBuffer.writeln('== Introduction ==');
      final introStepIndex = 0;

      if (guide.introduction!.contents.isNotEmpty) {
        final introContent = _joinContentBlocks(
          guide.introduction!.contents,
          stepIndex: introStepIndex,
          guideTitle: guide.title,
        );
        if (introContent.isNotEmpty) {
          introBuffer.writeln();
          introBuffer.writeln(introContent);
        }
      } else {
        final introBlocks = <String>[];
        if (guide.introduction!.description != null &&
            guide.introduction!.description!.isNotEmpty) {
          final introText = _normalizeBlock(
            _formatRichText(guide.introduction!.description!),
          );
          if (introText.isNotEmpty) {
            introBlocks.add(introText);
          }
        }

        final introLegacy = _normalizeBlock(
          _generateStepContentLegacy(
            guide.introduction!,
            stepIndex: introStepIndex,
            guideTitle: guide.title,
          ),
        );
        if (introLegacy.isNotEmpty) {
          introBlocks.add(introLegacy);
        }

        if (introBlocks.isNotEmpty) {
          introBuffer.writeln();
          introBuffer.writeln(introBlocks.join('\n\n'));
        }
      }

      _appendSection(buffer, introBuffer.toString());
    }

    // Process steps
    final stepStartIndex = guide.introduction != null ? 1 : 0;
    for (var i = 0; i < guide.steps.length; i++) {
      final step = guide.steps[i];
      final stepIndex = stepStartIndex + i;
      _appendSection(
        buffer,
        _generateStep(step, stepIndex: stepIndex, guideTitle: guide.title),
      );
    }

    // Categories
    for (final category in guide.categories) {
      buffer.writeln('[[Category:$category]]');
    }

    return buffer.toString();
  }

  String _generateMetadata(GuideMetadata metadata) {
    final lines = <String>[];
    if (metadata.description != null && metadata.description!.isNotEmpty) {
      lines.add("''${metadata.description}''");
    }
    if (metadata.version != null) {
      lines.add('* Version: ${metadata.version}');
    }
    if (metadata.author != null) {
      lines.add('* Author: ${metadata.author}');
    }
    if (metadata.date != null) {
      lines.add('* Date: ${metadata.date!.toIso8601String().split('T')[0]}');
    }
    return lines.join('\n');
  }

  String _generateStep(
    Step step, {
    required int stepIndex,
    required String? guideTitle,
  }) {
    final buffer = StringBuffer();
    final level = step.level ?? 0;

    // MediaWiki section levels:
    // - top-level step: level 2
    // - nested step(s): level 3
    final headingLevel = level <= 0 ? 2 : 3;
    final headerMarks = '=' * headingLevel;
    final plainTitle = _sanitizeHeadingText(step.title);
    var formattedTitle = plainTitle;

    if (step.isBold) {
      formattedTitle = "'''$formattedTitle'''";
    }
    if (step.titleColor != null &&
        RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(step.titleColor!)) {
      formattedTitle =
          '<span style="color:${step.titleColor!.toUpperCase()};">$formattedTitle</span>';
    }

    // Step heading
    buffer.writeln('$headerMarks $formattedTitle $headerMarks');

    // Use new content blocks if available
    if (step.contents.isNotEmpty) {
      final contentBody = _joinContentBlocks(
        step.contents,
        stepIndex: stepIndex,
        guideTitle: guideTitle,
      );
      if (contentBody.isNotEmpty) {
        buffer.writeln();
        buffer.writeln(contentBody);
      }
    } else {
      // Legacy fallback
      final legacyBody = _normalizeBlock(
        _generateStepContentLegacy(
          step,
          stepIndex: stepIndex,
          guideTitle: guideTitle,
        ),
      );
      if (legacyBody.isNotEmpty) {
        buffer.writeln();
        buffer.writeln(legacyBody);
      }
    }

    return buffer.toString();
  }

  String _generateContent(
    StepContent content, {
    required int stepIndex,
    required int contentIndex,
    required String? guideTitle,
  }) {
    final buffer = StringBuffer();

    switch (content.type) {
      case StepContentType.text:
        if (content.text != null && content.text!.isNotEmpty) {
          final text = _normalizeBlock(_formatRichText(content.text!));
          if (text.isNotEmpty) {
            buffer.write(text);
          }
        }
        break;

      case StepContentType.command:
        if (content.text != null && content.text!.isNotEmpty) {
          buffer.writeln(';Command:');
          buffer.writeln('<pre>');
          buffer.writeln(content.text);
          buffer.writeln('</pre>');

          // Output (if enabled)
          if (content.showOutput &&
              content.output != null &&
              content.output!.isNotEmpty) {
            buffer.writeln();
            buffer.writeln(';Output:');
            buffer.writeln('<pre>');
            buffer.writeln(content.output);
            buffer.writeln('</pre>');
          }
        }
        break;

      case StepContentType.image:
        if (content.image != null) {
          final caption = _normalizeCaption(
            content.caption ?? content.image!.caption,
          );
          final filename = _resolveImageFilename(
            content.image!,
            stepIndex: stepIndex,
            contentIndex: contentIndex,
            guideTitle: guideTitle,
            caption: caption,
          );
          buffer.write(_buildImageMarkup(filename, caption));
        }
        break;
    }

    return buffer.toString();
  }

  // Legacy content generation for backward compatibility
  String _generateStepContentLegacy(
    Step step, {
    required int stepIndex,
    required String? guideTitle,
  }) {
    final blocks = <String>[];

    // Text content
    if (step.description != null && step.description!.isNotEmpty) {
      final text = _normalizeBlock(_formatRichText(step.description!));
      if (text.isNotEmpty) {
        blocks.add(text);
      }
    }

    // Command block
    if (step.command != null && step.command!.isNotEmpty) {
      final command = StringBuffer();
      command.writeln(';Command:');
      command.writeln('<pre>');
      command.writeln(step.command);
      command.writeln('</pre>');

      // Output (if enabled)
      if (step.showOutput && step.output != null && step.output!.isNotEmpty) {
        command.writeln();
        command.writeln(';Output:');
        command.writeln('<pre>');
        command.writeln(step.output);
        command.writeln('</pre>');
      }

      blocks.add(_normalizeBlock(command.toString()));
    }

    // Screenshot
    if (step.image != null) {
      final caption = _normalizeCaption(
        step.imageCaption ?? step.image!.caption,
      );
      final filename = _resolveImageFilename(
        step.image!,
        stepIndex: stepIndex,
        contentIndex: 0,
        guideTitle: guideTitle,
        caption: caption,
      );
      blocks.add(_buildImageMarkup(filename, caption));
    }

    return blocks.join('\n\n');
  }

  String _joinContentBlocks(
    List<StepContent> contents, {
    required int stepIndex,
    required String? guideTitle,
  }) {
    final blocks = <String>[];
    for (var contentIndex = 0; contentIndex < contents.length; contentIndex++) {
      final content = contents[contentIndex];
      final block = _normalizeBlock(
        _generateContent(
          content,
          stepIndex: stepIndex,
          contentIndex: contentIndex,
          guideTitle: guideTitle,
        ),
      );
      if (block.isNotEmpty) {
        blocks.add(block);
      }
    }
    return blocks.join('\n\n');
  }

  void _appendSection(StringBuffer buffer, String section) {
    final normalized = _normalizeBlock(section);
    if (normalized.isEmpty) return;
    buffer.writeln(normalized);
    buffer.writeln();
  }

  String _normalizeBlock(String text) {
    return text.replaceAll(RegExp(r'[ \t]+\n'), '\n').trimRight();
  }

  String _formatRichText(String text) {
    // Convert Quill Delta JSON to WikiText
    return QuillToWikiText.convert(text);
  }

  String _resolveImageFilename(
    ImageData image, {
    required int stepIndex,
    required int contentIndex,
    required String? guideTitle,
    String? caption,
  }) {
    return ImageFilenameHelper.generateImageFilename(
      image,
      stepIndex: stepIndex,
      contentIndex: contentIndex,
      guideTitle: guideTitle,
      caption: caption,
    );
  }

  String? _normalizeCaption(String? caption) {
    final value = caption?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  String _sanitizeHeadingText(String text, {String fallback = 'Untitled'}) {
    final withoutHtml = text.replaceAll(RegExp(r'<[^>]*>'), '');
    final withoutWikiFormatting = withoutHtml.replaceAll(RegExp(r"'{2,}"), '');
    final withoutHeadingChars = withoutWikiFormatting.replaceAll('=', '');
    final normalized = withoutHeadingChars
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return normalized.isEmpty ? fallback : normalized;
  }

  String _buildImageMarkup(String filename, String? caption) {
    final params = <String>[
      'center',
      'none',
      '${AppConstants.wikiImageWidthPx}px',
    ];
    if (caption != null && caption.isNotEmpty) {
      params.add(caption);
    }
    return '[[File:$filename|${params.join('|')}]]';
  }
}
