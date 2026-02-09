import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart' hide Step;
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:lazywikis/data/models/step_content.dart';

class TextContentEditor extends StatefulWidget {
  final StepContent content;
  final ValueChanged<StepContent> onUpdate;
  final ValueChanged<String>? onDelete;

  const TextContentEditor({
    super.key,
    required this.content,
    required this.onUpdate,
    this.onDelete,
  });

  @override
  State<TextContentEditor> createState() => _TextContentEditorState();
}

class _TextContentEditorState extends State<TextContentEditor> {
  late quill.QuillController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    quill.Document doc;
    if (widget.content.text != null && widget.content.text!.isNotEmpty) {
      try {
        final json = jsonDecode(widget.content.text!);
        if (json is List) {
          doc = quill.Document.fromJson(json);
        } else {
          doc = quill.Document()..insert(0, widget.content.text!);
        }
      } catch (e) {
        doc = quill.Document()..insert(0, widget.content.text!);
      }
    } else {
      doc = quill.Document();
    }

    _controller = quill.QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );

    _controller.document.changes.listen((event) {
      if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), _saveContent);
    });
  }

  void _saveContent() {
    if (!mounted) return;
    final json = jsonEncode(_controller.document.toDelta().toJson());
    // Only update if changed (though delta listen implies change)
    if (widget.content.text != json) {
      widget.onUpdate(widget.content.copyWith(text: json));
    }
  }

  @override
  void dispose() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
      // Attempt to save final state if dirty?
      // For performance safety, we skip force-save on dispose for now
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.onDelete != null)
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.grey),
              onPressed: () => widget.onDelete!(widget.content.id),
              tooltip: 'Remove Text Block',
            ),
          ),
        Container(
          height: 400,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            children: [
              quill.QuillToolbar.simple(
                configurations: quill.QuillSimpleToolbarConfigurations(
                  controller: _controller,
                  showAlignmentButtons: false,
                  showDirection: false,
                  showSearchButton: false,
                  showSubscript: false,
                  showSuperscript: false,
                  showInlineCode: true,
                  showCodeBlock: true,
                  showLink: true, // User requested link support
                  showQuote: true,
                  showIndent: true,
                  showHeaderStyle: true,
                  showListBullets: true,
                  showListNumbers: true,
                  showListCheck: false,
                  showBoldButton: true,
                  showItalicButton: true,
                  showUnderLineButton: true,
                  showStrikeThrough: true,
                  showColorButton: true,
                  showBackgroundColorButton: true,
                  showFontFamily: true,
                  showFontSize: true,
                  showClearFormat: true,
                ),
              ),
              const Divider(),
              Expanded(
                child: quill.QuillEditor.basic(
                  configurations: quill.QuillEditorConfigurations(
                    controller: _controller,
                    padding: const EdgeInsets.all(8),
                    placeholder: 'Enter step description...',
                    autoFocus: false,
                    expands: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
