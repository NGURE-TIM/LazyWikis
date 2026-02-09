import 'dart:convert';

/// Utility class to convert Quill Delta JSON to MediaWiki markup
class QuillToWikiText {
  /// Convert Quill Delta JSON string to WikiText
  static String convert(String? deltaJson) {
    if (deltaJson == null || deltaJson.isEmpty) return '';

    try {
      final delta = jsonDecode(deltaJson);
      if (delta is! List) return '';

      final buffer = StringBuffer();

      for (var op in delta) {
        if (op is! Map || !op.containsKey('insert')) continue;

        final String text = op['insert'].toString();
        final Map<String, dynamic>? attributes = op['attributes'];

        // Handle newlines and special characters
        if (text == '\n') {
          buffer.write('\n');
          continue;
        }

        String formattedText = text;

        // Apply formatting based on attributes
        if (attributes != null) {
          // Bold
          if (attributes['bold'] == true) {
            formattedText = "'''$formattedText'''";
          }

          // Italic
          if (attributes['italic'] == true) {
            formattedText = "''$formattedText''";
          }

          // Underline (MediaWiki uses HTML for this)
          if (attributes['underline'] == true) {
            formattedText = '<u>$formattedText</u>';
          }

          // Strikethrough
          if (attributes['strike'] == true) {
            formattedText = '<s>$formattedText</s>';
          }

          // Code (inline)
          if (attributes['code'] == true) {
            formattedText = '<code>$formattedText</code>';
          }

          // Color (using HTML span)
          if (attributes['color'] != null) {
            final color = attributes['color'];
            formattedText = '<span style="color:$color">$formattedText</span>';
          }

          // Background color
          if (attributes['background'] != null) {
            final bg = attributes['background'];
            formattedText =
                '<span style="background-color:$bg">$formattedText</span>';
          }

          // Font family
          if (attributes['font'] != null) {
            final font = attributes['font'];
            formattedText =
                '<span style="font-family:$font">$formattedText</span>';
          }

          // Font size
          if (attributes['size'] != null) {
            final size = attributes['size'];
            formattedText =
                '<span style="font-size:$size">$formattedText</span>';
          }

          // Headers
          if (attributes['header'] != null) {
            final level = attributes['header'];
            final headerMarks = '=' * (level + 1);
            formattedText = '$headerMarks $text $headerMarks\n';
          }

          // Lists
          if (attributes['list'] == 'bullet') {
            formattedText = '* $text';
          } else if (attributes['list'] == 'ordered') {
            formattedText = '# $text';
          }

          // Blockquote
          if (attributes['blockquote'] == true) {
            formattedText = '<blockquote>$text</blockquote>';
          }

          // Code block
          if (attributes['code-block'] == true) {
            formattedText = '<syntaxhighlight>\n$text\n</syntaxhighlight>';
          }
        }

        buffer.write(formattedText);
      }

      return buffer.toString();
    } catch (e) {
      // If parsing fails, return the original string
      return deltaJson;
    }
  }

  /// Convert plain text to simple WikiText (fallback)
  static String fromPlainText(String text) {
    return text;
  }
}
