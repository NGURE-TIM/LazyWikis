import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lazywikis/data/models/step_content.dart';

class CommandContentEditor extends StatefulWidget {
  final StepContent content;
  final ValueChanged<StepContent> onUpdate;
  final ValueChanged<String>? onDelete;

  const CommandContentEditor({
    super.key,
    required this.content,
    required this.onUpdate,
    this.onDelete,
  });

  @override
  State<CommandContentEditor> createState() => _CommandContentEditorState();
}

class _CommandContentEditorState extends State<CommandContentEditor> {
  late TextEditingController _commandController;
  late TextEditingController _outputController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _commandController = TextEditingController(text: widget.content.text ?? '');
    _outputController = TextEditingController(
      text: widget.content.output ?? '',
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _commandController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _updateContent() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      widget.onUpdate(
        widget.content.copyWith(
          text: _commandController.text,
          output: _outputController.text,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.terminal, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Command',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                DropdownButton<String>(
                  value: widget.content.language ?? 'bash',
                  items:
                      [
                            'bash',
                            'python',
                            'javascript',
                            'sql',
                            'html',
                            'css',
                            'json',
                          ]
                          .map(
                            (lang) => DropdownMenuItem(
                              value: lang,
                              child: Text(lang),
                            ),
                          )
                          .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      widget.onUpdate(widget.content.copyWith(language: val));
                    }
                  },
                ),
                if (widget.onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey),
                    onPressed: () => widget.onDelete!(widget.content.id),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commandController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Command / Code',
                hintText: 'Enter command here...',
              ),
              style: const TextStyle(fontFamily: 'monospace'),
              onChanged: (_) => _updateContent(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: widget.content.showOutput,
                  onChanged: (val) {
                    widget.onUpdate(widget.content.copyWith(showOutput: val));
                  },
                ),
                const Text('Include Output'),
              ],
            ),
            if (widget.content.showOutput) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _outputController,
                maxLines: null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Command Output',
                  hintText: 'Paste command output here...',
                  filled: true,
                ),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                onChanged: (_) => _updateContent(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
