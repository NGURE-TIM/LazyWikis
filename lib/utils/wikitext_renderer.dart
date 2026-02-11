import 'package:flutter/material.dart';
import 'package:lazywikis/utils/link_opener.dart';

/// Simple WikiText renderer for preview display
/// Converts basic WikiText markup to Flutter widgets
class WikiTextRenderer {
  /// Parse WikiText and return formatted widgets
  static List<Widget> render(String wikiText) {
    final widgets = <Widget>[];
    final lines = wikiText.split('\n');
    final orderedCounters = <int, int>{};
    String? lastListType;

    int i = 0;
    while (i < lines.length) {
      final line = lines[i];

      // Skip empty lines
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        i++;
        continue;
      }

      // MediaWiki TOC marker
      if (line.trim() == '__TOC__') {
        widgets.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Table of Contents',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.black54,
              ),
            ),
          ),
        );
        orderedCounters.clear();
        lastListType = null;
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
            child: _buildInlineRichText(
              _formatInlineMarkup(rawContent),
              style: TextStyle(
                fontSize: _headingFontSize(level),
                fontWeight: isBoldTitle ? FontWeight.w900 : FontWeight.bold,
                color: titleColor,
              ),
            ),
          ),
        );
        orderedCounters.clear();
        lastListType = null;
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
        orderedCounters.clear();
        lastListType = null;
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
        orderedCounters.clear();
        lastListType = null;
        continue;
      }

      final unorderedMatch = RegExp(r'^(\*+)\s+(.+)$').firstMatch(line.trim());
      if (unorderedMatch != null) {
        final level = unorderedMatch.group(1)!.length;
        final content = unorderedMatch.group(2)!.trim();

        orderedCounters.clear();
        lastListType = 'unordered';
        widgets.add(
          Padding(
            padding: EdgeInsets.only(left: 16.0 * level, top: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 16)),
                Expanded(child: _buildInlineRichText(content)),
              ],
            ),
          ),
        );
        i++;
        continue;
      }

      final orderedMatch = RegExp(r'^(#+)\s+(.+)$').firstMatch(line.trim());
      if (orderedMatch != null) {
        final level = orderedMatch.group(1)!.length;
        final content = orderedMatch.group(2)!.trim();

        if (lastListType != 'ordered') {
          orderedCounters.clear();
        }
        lastListType = 'ordered';

        orderedCounters.removeWhere((k, v) => k > level);
        orderedCounters[level] = (orderedCounters[level] ?? 0) + 1;
        final numberLabel = '${orderedCounters[level]}.';

        widgets.add(
          Padding(
            padding: EdgeInsets.only(left: 16.0 * level, top: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$numberLabel ', style: const TextStyle(fontSize: 14)),
                Expanded(child: _buildInlineRichText(content)),
              ],
            ),
          ),
        );
        i++;
        continue;
      }

      // Indented lines
      final indentMatch = RegExp(r'^(:+)\s*(.+)$').firstMatch(line.trim());
      if (indentMatch != null) {
        final depth = indentMatch.group(1)!.length;
        final content = indentMatch.group(2)!.trim();
        widgets.add(
          Padding(
            padding: EdgeInsets.only(left: 16.0 * depth, top: 4),
            child: _buildInlineRichText(content),
          ),
        );
        orderedCounters.clear();
        lastListType = null;
        i++;
        continue;
      }

      // Regular text (with basic formatting)
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: _buildInlineRichText(_formatInlineMarkup(line)),
        ),
      );
      orderedCounters.clear();
      lastListType = null;
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

  static Widget _buildInlineRichText(String text, {TextStyle? style}) {
    final baseStyle = style ?? const TextStyle(fontSize: 14);
    final spans = _parseInline(text, baseStyle);
    return RichText(
      text: TextSpan(style: baseStyle, children: spans),
    );
  }

  static List<InlineSpan> _parseInline(String text, TextStyle baseStyle) {
    if (text.isEmpty) {
      return [TextSpan(text: '', style: baseStyle)];
    }

    final spans = <InlineSpan>[];
    int index = 0;

    while (index < text.length) {
      final tokenData = _extractNextToken(text, index);
      if (tokenData == null) {
        spans.add(TextSpan(text: text.substring(index), style: baseStyle));
        break;
      }

      if (tokenData.start > index) {
        spans.add(
          TextSpan(
            text: text.substring(index, tokenData.start),
            style: baseStyle,
          ),
        );
      }

      spans.addAll(_tokenToSpans(tokenData.token, baseStyle));
      index = tokenData.end;
    }

    return spans;
  }

  static List<InlineSpan> _tokenToSpans(String token, TextStyle baseStyle) {
    if (token.startsWith('<span style="color:')) {
      final colorMatch = RegExp(
        r'^<span style="color:\s*(#[0-9A-Fa-f]{3,6});?">(.*)<\/span>$',
      ).firstMatch(token);
      if (colorMatch != null) {
        final color = _parseColor(colorMatch.group(1));
        final inner = colorMatch.group(2) ?? '';
        final colorStyle = baseStyle.copyWith(color: color ?? baseStyle.color);
        return _parseInline(inner, colorStyle);
      }
    }

    if (token.startsWith('[http://') || token.startsWith('[https://')) {
      final extMatch = RegExp(
        r'^\[(https?:\/\/[^\s\]]+)\s+([^\]]+)\]$',
      ).firstMatch(token);
      if (extMatch != null) {
        final url = extMatch.group(1)!;
        final label = extMatch.group(2)!;
        return [
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: InkWell(
              onTap: () => openExternalLink(url),
              child: Text(
                label,
                style: baseStyle.copyWith(
                  color: Colors.blue.shade700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ];
      }
    }

    if (token.startsWith('[[') && token.endsWith(']]')) {
      final inner = token.substring(2, token.length - 2);
      final parts = inner.split('|');
      final label = parts.length > 1 ? parts.sublist(1).join('|') : parts.first;
      return [
        TextSpan(
          text: label,
          style: baseStyle.copyWith(
            color: Colors.blue.shade700,
            decoration: TextDecoration.underline,
          ),
        ),
      ];
    }

    if (token.startsWith("'''''") && token.endsWith("'''''")) {
      final inner = token.substring(5, token.length - 5);
      return _parseInline(
        inner,
        baseStyle.copyWith(
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    if (token.startsWith("'''") && token.endsWith("'''")) {
      final inner = token.substring(3, token.length - 3);
      return _parseInline(
        inner,
        baseStyle.copyWith(fontWeight: FontWeight.bold),
      );
    }

    if (token.startsWith("''") && token.endsWith("''")) {
      final inner = token.substring(2, token.length - 2);
      return _parseInline(
        inner,
        baseStyle.copyWith(fontStyle: FontStyle.italic),
      );
    }

    return [TextSpan(text: token, style: baseStyle)];
  }

  static ({int start, int end, String token})? _extractNextToken(
    String text,
    int from,
  ) {
    final candidates = <({int start, String marker})>[];
    final markers = [
      '<span style="color:',
      '[http://',
      '[https://',
      '[[',
      "'''''",
      "'''",
      "''",
    ];

    for (final marker in markers) {
      final idx = text.indexOf(marker, from);
      if (idx >= 0) {
        candidates.add((start: idx, marker: marker));
      }
    }

    if (candidates.isEmpty) return null;
    candidates.sort((a, b) => a.start.compareTo(b.start));
    final next = candidates.first;

    if (next.marker == '<span style="color:') {
      final end = text.indexOf('</span>', next.start);
      if (end >= 0) {
        final close = end + '</span>'.length;
        return (
          start: next.start,
          end: close,
          token: text.substring(next.start, close),
        );
      }
      return null;
    }

    if (next.marker == '[http://' ||
        next.marker == '[https://' ||
        next.marker == '[[') {
      final end = text.indexOf(']', next.start + 1);
      if (next.marker == '[[') {
        final doubleEnd = text.indexOf(']]', next.start + 2);
        if (doubleEnd >= 0) {
          final close = doubleEnd + 2;
          return (
            start: next.start,
            end: close,
            token: text.substring(next.start, close),
          );
        }
        return null;
      }
      if (end >= 0) {
        final close = end + 1;
        return (
          start: next.start,
          end: close,
          token: text.substring(next.start, close),
        );
      }
      return null;
    }

    // Apostrophe-based styles
    final marker = next.marker;
    final start = next.start;
    final end = text.indexOf(marker, start + marker.length);
    if (end >= 0) {
      final close = end + marker.length;
      return (start: start, end: close, token: text.substring(start, close));
    }

    return null;
  }

  static Color? _parseColor(String? hex) {
    if (hex == null) return null;
    final value = hex.trim();
    if (RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(value)) {
      return Color(int.parse(value.replaceFirst('#', '0xFF')));
    }
    if (RegExp(r'^#[0-9A-Fa-f]{3}$').hasMatch(value)) {
      final expanded =
          '#${value[1]}${value[1]}${value[2]}${value[2]}${value[3]}${value[3]}';
      return Color(int.parse(expanded.replaceFirst('#', '0xFF')));
    }
    return null;
  }

  static String _formatInlineMarkup(String text) {
    // Remove MediaWiki markup for simple display
    // This is a simplified version - full MediaWiki parsing is complex
    return text
        .replaceAll(RegExp(r'\[\[Category:.+?\]\]'), '') // Categories
        .replaceAll('__TOC__', ''); // Table of contents
  }
}
