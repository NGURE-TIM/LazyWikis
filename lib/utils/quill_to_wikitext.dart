import 'dart:convert';

/// Utility class to convert Quill Delta JSON to MediaWiki markup
class QuillToWikiText {
  /// Convert Quill Delta JSON string to WikiText
  static String convert(String? deltaJson) {
    if (deltaJson == null || deltaJson.isEmpty) return '';

    try {
      final delta = jsonDecode(deltaJson);
      if (delta is! List) return '';

      final outputLines = <String>[];
      final lineBuffer = StringBuffer();
      var inSyntaxBlock = false;

      void flushLine([Map<String, dynamic>? lineAttributes]) {
        var line = lineBuffer.toString();
        lineBuffer.clear();

        final attrs = lineAttributes ?? const <String, dynamic>{};
        final isCodeBlock = attrs['code-block'] == true;

        if (isCodeBlock) {
          if (!inSyntaxBlock) {
            outputLines.add('<syntaxhighlight>');
            inSyntaxBlock = true;
          }
          outputLines.add(line);
          return;
        }

        if (inSyntaxBlock) {
          outputLines.add('</syntaxhighlight>');
          inSyntaxBlock = false;
        }

        // Keep empty paragraph lines as-is.
        if (line.trim().isEmpty) {
          outputLines.add('');
          return;
        }

        final headerLevel = _asInt(attrs['header']);
        if (headerLevel != null) {
          final marks = '=' * (headerLevel + 1);
          outputLines.add('$marks ${line.trim()} $marks');
          return;
        }

        final indent = (_asInt(attrs['indent']) ?? 0) + 1;
        final listType = attrs['list'];
        if (listType == 'bullet') {
          outputLines.add('${'*' * indent} ${line.trim()}');
          return;
        }
        if (listType == 'ordered') {
          outputLines.add('${'#' * indent} ${line.trim()}');
          return;
        }

        if (attrs['blockquote'] == true ||
            (attrs['indent'] != null && indent > 1)) {
          final depth = attrs['blockquote'] == true ? indent : indent - 1;
          outputLines.add('${':' * depth} ${line.trim()}');
          return;
        }

        outputLines.add(line.trimRight());
      }

      for (final op in delta) {
        if (op is! Map || !op.containsKey('insert')) continue;

        final insert = op['insert'];
        if (insert is! String) continue;

        final attributes = op['attributes'];
        final inlineAttrs = attributes is Map
            ? attributes.map((key, value) => MapEntry(key.toString(), value))
            : const <String, dynamic>{};

        if (insert == '\n') {
          flushLine(inlineAttrs);
          continue;
        }

        if (!insert.contains('\n')) {
          lineBuffer.write(_formatInline(insert, inlineAttrs));
          continue;
        }

        final parts = insert.split('\n');
        for (var i = 0; i < parts.length; i++) {
          final part = parts[i];
          if (part.isNotEmpty) {
            lineBuffer.write(_formatInline(part, inlineAttrs));
          }
          if (i < parts.length - 1) {
            flushLine();
          }
        }
      }

      if (lineBuffer.isNotEmpty) {
        flushLine();
      }
      if (inSyntaxBlock) {
        outputLines.add('</syntaxhighlight>');
      }

      return outputLines.join('\n');
    } catch (e) {
      // If parsing fails, return the original string
      return deltaJson;
    }
  }

  /// Convert plain text to simple WikiText (fallback)
  static String fromPlainText(String text) {
    return text;
  }

  static String _formatInline(String text, Map<String, dynamic> attributes) {
    if (text.isEmpty) return text;

    var formatted = text;

    final link = attributes['link'];
    if (link is String && link.trim().isNotEmpty) {
      final target = link.trim();
      if (target.startsWith('http://') || target.startsWith('https://')) {
        formatted = '[$target $formatted]';
      } else {
        formatted = target == formatted
            ? '[[$target]]'
            : '[[$target|$formatted]]';
      }
    } else {
      formatted = formatted.replaceAllMapped(
        RegExp(r'https?://[^\s\]]+'),
        (match) => '[${match.group(0)} ${match.group(0)}]',
      );
    }

    if (attributes['bold'] == true && attributes['italic'] == true) {
      formatted = "'''''$formatted'''''";
    } else if (attributes['bold'] == true) {
      formatted = "'''$formatted'''";
    } else if (attributes['italic'] == true) {
      formatted = "''$formatted''";
    }

    if (attributes['underline'] == true) {
      formatted = '<u>$formatted</u>';
    }
    if (attributes['strike'] == true) {
      formatted = '<s>$formatted</s>';
    }
    if (attributes['code'] == true) {
      formatted = '<code>$formatted</code>';
    }

    final normalizedColor = _normalizeHexColor(attributes['color']?.toString());
    if (normalizedColor != null) {
      formatted = '<span style="color:$normalizedColor;">$formatted</span>';
    }

    return formatted;
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }

  static String? _normalizeHexColor(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final color = value.trim();

    if (RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(color)) {
      return color.toUpperCase();
    }
    if (RegExp(r'^#[0-9A-Fa-f]{3}$').hasMatch(color)) {
      final r = color[1];
      final g = color[2];
      final b = color[3];
      return '#$r$r$g$g$b$b'.toUpperCase();
    }
    return null;
  }
}
