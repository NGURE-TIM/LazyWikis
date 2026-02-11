import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lazywikis/utils/wikitext_renderer.dart';

class PreviewPanel extends StatefulWidget {
  final String wikiText;

  const PreviewPanel({super.key, required this.wikiText});

  @override
  State<PreviewPanel> createState() => _PreviewPanelState();
}

class _PreviewPanelState extends State<PreviewPanel> {
  bool _showRendered = true; // Default to rendered view

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(left: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Preview',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Toggle between rendered and raw
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: true,
                      icon: Icon(Icons.visibility, size: 16),
                      tooltip: 'Rendered',
                    ),
                    ButtonSegment(
                      value: false,
                      icon: Icon(Icons.code, size: 16),
                      tooltip: 'Raw',
                    ),
                  ],
                  selected: {_showRendered},
                  onSelectionChanged: (Set<bool> selection) {
                    setState(() {
                      _showRendered = selection.first;
                    });
                  },
                  style: ButtonStyle(visualDensity: VisualDensity.compact),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.wikiText));
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Copied')));
                  },
                  tooltip: 'Copy',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: _showRendered
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: WikiTextRenderer.render(
                        context,
                        widget.wikiText,
                      ),
                    )
                  : SelectableText(
                      widget.wikiText,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
