import 'package:flutter/material.dart';

/// Simple WikiText renderer for preview display
/// Converts basic WikiText markup to Flutter widgets
class WikiTextRenderer {
  /// Parse WikiText and return formatted widgets
  static List<Widget> render(String wikiText) {
    final widgets = <Widget>[];
    final lines = wikiText.split('\n');

    int i = 0;
    while (i < lines.length) {
      final line = lines[i];

      // Skip empty lines
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        i++;
        continue;
      }

      // Headers (= Title =, == Section ==, etc.)
      if (line.startsWith('=') && line.endsWith('=')) {
        final headerMatch = RegExp(r'^(=+)\s*(.*?)\s*\1$').firstMatch(line);
        final level = headerMatch != null
            ? headerMatch.group(1)!.length
            : _countLeadingChars(line, '=');
        String rawContent = headerMatch != null
            ? headerMatch.group(2) ?? ''
            : line.replaceAll(RegExp(r'^=+| =+$|=+$'), '').trim();

        Color? titleColor;
        bool isBoldTitle = false;

        // Parse Color Span
        final colorMatch = RegExp(
          r'<span style="color:(.+?)">(.+?)</span>',
        ).firstMatch(rawContent);
        if (colorMatch != null) {
          try {
            titleColor = Color(
              int.parse(colorMatch.group(1)!.replaceFirst('#', '0xFF')),
            );
            rawContent = colorMatch.group(2)!; // Unwrap content
          } catch (e) {
            // If color parse fails, ignore color
          }
        }

        // Parse Bold
        final boldMatch = RegExp(r"'''(.+?)'''").firstMatch(rawContent);
        if (boldMatch != null) {
          isBoldTitle = true;
          rawContent = boldMatch.group(1)!; // Unwrap content
        }

        widgets.add(
          Padding(
            padding: EdgeInsets.only(
              top: level <= 2 ? 16 : 12,
              bottom: level <= 2 ? 8 : 6,
            ),
            child: Text(
              _formatInlineMarkup(rawContent), // Clean up any remaining markup
              style: TextStyle(
                fontSize: _headingFontSize(level),
                fontWeight: isBoldTitle ? FontWeight.w900 : FontWeight.bold,
                color: titleColor,
              ),
            ),
          ),
        );
        i++;
        continue;
      }

      // Syntax highlighted code blocks
      if (line.contains('<syntaxhighlight')) {
        final codeLines = <String>[];
        i++; // Skip the opening tag

        // Collect code lines until closing tag
        while (i < lines.length && !lines[i].contains('</syntaxhighlight>')) {
          codeLines.add(lines[i]);
          i++;
        }
        i++; // Skip the closing tag

        widgets.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: SelectableText(
              codeLines.join('\n'),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
          ),
        );
        continue;
      }

      // Pre blocks (output)
      if (line.contains('<pre>')) {
        final preLines = <String>[];
        i++; // Skip the opening tag

        while (i < lines.length && !lines[i].contains('</pre>')) {
          preLines.add(lines[i]);
          i++;
        }
        i++; // Skip the closing tag

        widgets.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: SelectableText(
              preLines.join('\n'),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
        );
        continue;
      }

      // Bullet lists
      if (line.trim().startsWith('*')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: Text(
                    line.trim().substring(1).trim(),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        );
        i++;
        continue;
      }

      // Numbered lists
      if (line.trim().startsWith('#')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(
              line.trim().substring(1).trim(),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        );
        i++;
        continue;
      }

      // Regular text (with basic formatting)
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            _formatInlineMarkup(line),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      );
      i++;
    }

    return widgets;
  }

  static int _countLeadingChars(String str, String char) {
    int count = 0;
    for (int i = 0; i < str.length; i++) {
      if (str[i] == char) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  static double _headingFontSize(int level) {
    if (level <= 1) return 24;
    if (level == 2) return 20;
    if (level == 3) return 17;
    return 15;
  }

  static String _formatInlineMarkup(String text) {
    // Remove MediaWiki markup for simple display
    // This is a simplified version - full MediaWiki parsing is complex
    return text
        .replaceAll(RegExp(r"'''(.+?)'''"), r'$1') // Bold
        .replaceAll(RegExp(r"''(.+?)''"), r'$1') // Italic
        .replaceAll(RegExp(r'\[\[Category:.+?\]\]'), '') // Categories
        .replaceAll('__TOC__', ''); // Table of contents
  }
}
