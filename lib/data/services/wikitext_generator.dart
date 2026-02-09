import 'package:lazywikis/data/models/guide.dart';
import 'package:lazywikis/data/models/step.dart';
import 'package:lazywikis/data/models/step_content.dart';
import 'package:lazywikis/data/models/guide_metadata.dart';
import 'package:lazywikis/utils/quill_to_wikitext.dart';

class WikiTextGenerator {
  /// Converts Guide object to MediaWiki markup
  String generate(Guide guide) {
    final buffer = StringBuffer();

    // Title (Level 1 heading)
    buffer.writeln('= ${guide.title} =');
    buffer.writeln();

    // Table of Contents (if included)
    if (guide.hasTableOfContents) {
      buffer.writeln('__TOC__');
      buffer.writeln();
    }

    // Metadata section (optional)
    if (guide.metadata != null) {
      buffer.writeln(_generateMetadata(guide.metadata!));
      buffer.writeln();
    }

    // Introduction (Lead Section - no header)
    if (guide.introduction != null) {
      // Check if introduction has new content blocks
      if (guide.introduction!.contents.isNotEmpty) {
        for (var content in guide.introduction!.contents) {
          buffer.writeln(_generateContent(content));
        }
        buffer.writeln();
      } else if (guide.introduction!.description != null &&
          guide.introduction!.description!.isNotEmpty) {
        // Legacy fallback
        buffer.writeln(_formatRichText(guide.introduction!.description!));
        buffer.writeln();
        buffer.writeln(_generateStepContentLegacy(guide.introduction!));
        buffer.writeln();
      }
    }

    // Process steps
    for (var step in guide.steps) {
      buffer.writeln(_generateStep(step));
      buffer.writeln();
    }

    // Categories
    for (var category in guide.categories) {
      buffer.writeln('[[Category:$category]]');
    }

    return buffer.toString();
  }

  String _generateMetadata(GuideMetadata metadata) {
    final buffer = StringBuffer();
    if (metadata.description != null && metadata.description!.isNotEmpty) {
      buffer.writeln("''${metadata.description}''");
    }
    if (metadata.version != null) {
      buffer.writeln("* Version: ${metadata.version}");
    }
    if (metadata.author != null) {
      buffer.writeln("* Author: ${metadata.author}");
    }
    if (metadata.date != null) {
      buffer.writeln(
        "* Date: ${metadata.date!.toIso8601String().split('T')[0]}",
      );
    }
    return buffer.toString();
  }

  String _generateStep(Step step) {
    final buffer = StringBuffer();
    final level = step.level ?? 0;

    // Calculate header level: Base is 2 (==), plus indentation level
    final headerMarks = '=' * (2 + level);

    // Apply formatting to title
    String formattedTitle = step.title;

    // Apply bold if enabled
    if (step.isBold) {
      formattedTitle = "'''$formattedTitle'''";
    }

    // Apply color if set
    if (step.titleColor != null) {
      formattedTitle =
          '<span style="color:${step.titleColor}">$formattedTitle</span>';
    }

    // Step heading
    buffer.writeln('$headerMarks $formattedTitle $headerMarks');
    buffer.writeln();

    // Use new content blocks if available
    if (step.contents.isNotEmpty) {
      for (var content in step.contents) {
        buffer.write(_generateContent(content));
      }
    } else {
      // Legacy fallback
      buffer.write(_generateStepContentLegacy(step));
    }

    return buffer.toString();
  }

  String _generateContent(StepContent content) {
    final buffer = StringBuffer();

    switch (content.type) {
      case StepContentType.text:
        if (content.text != null && content.text!.isNotEmpty) {
          buffer.writeln(_formatRichText(content.text!));
          buffer.writeln();
        }
        break;

      case StepContentType.command:
        if (content.text != null && content.text!.isNotEmpty) {
          buffer.writeln('<pre>');
          buffer.writeln(content.text);
          buffer.writeln('</pre>');
          buffer.writeln();

          // Output (if enabled)
          if (content.showOutput &&
              content.output != null &&
              content.output!.isNotEmpty) {
            buffer.writeln('Output:');
            buffer.writeln('<pre>');
            buffer.writeln(content.output);
            buffer.writeln('</pre>');
            buffer.writeln();
          }
        }
        break;

      case StepContentType.image:
        if (content.image != null) {
          final caption = content.caption ?? 'Screenshot';
          buffer.writeln(
            '[[File:${content.image!.filename}|thumb|300px|$caption]]',
          );
          buffer.writeln();
        }
        break;
    }

    return buffer.toString();
  }

  // Legacy content generation for backward compatibility
  String _generateStepContentLegacy(Step step) {
    final buffer = StringBuffer();

    // Text content
    if (step.description != null && step.description!.isNotEmpty) {
      buffer.writeln(_formatRichText(step.description!));
      buffer.writeln();
    }

    // Command block
    if (step.command != null && step.command!.isNotEmpty) {
      buffer.writeln('<pre>');
      buffer.writeln(step.command);
      buffer.writeln('</pre>');
      buffer.writeln();

      // Output (if enabled)
      if (step.showOutput && step.output != null && step.output!.isNotEmpty) {
        buffer.writeln('Output:');
        buffer.writeln('<pre>');
        buffer.writeln(step.output);
        buffer.writeln('</pre>');
        buffer.writeln();
      }
    }

    // Screenshot
    if (step.image != null) {
      final caption = step.imageCaption ?? step.title;
      buffer.writeln('[[File:${step.image!.filename}|thumb|300px|$caption]]');
      buffer.writeln();
    }

    return buffer.toString();
  }

  String _formatRichText(String text) {
    // Convert Quill Delta JSON to WikiText
    return QuillToWikiText.convert(text);
  }
}
