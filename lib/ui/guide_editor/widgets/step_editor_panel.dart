import 'dart:async';
import 'package:flutter/material.dart' hide Step;
import 'package:lazywikis/data/models/step.dart';
import 'package:lazywikis/data/models/step_content.dart';
import 'package:lazywikis/data/services/image_handler_service.dart';
import 'package:lazywikis/ui/guide_editor/widgets/editors/text_content_editor.dart';
import 'package:lazywikis/ui/guide_editor/widgets/editors/command_content_editor.dart';
import 'package:lazywikis/ui/guide_editor/widgets/editors/screenshot_content_editor.dart';
import 'package:provider/provider.dart';

class StepEditorPanel extends StatefulWidget {
  final Step? step;
  final ValueChanged<Step> onUpdate;

  const StepEditorPanel({
    super.key,
    required this.step,
    required this.onUpdate,
  });

  @override
  State<StepEditorPanel> createState() => _StepEditorPanelState();
}

class _StepEditorPanelState extends State<StepEditorPanel> {
  late TextEditingController _titleController;
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.step?.title ?? '');
  }

  @override
  void didUpdateWidget(StepEditorPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step?.id != widget.step?.id) {
      _titleController.text = widget.step?.title ?? '';
      // Defer scroll reset to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
      _checkAndMigrateLegacy();
    }
  }

  void _checkAndMigrateLegacy() {
    if (widget.step != null && widget.step!.contents.isEmpty) {
      final legacy = <StepContent>[];
      bool migrated = false;

      // Text from description
      if (widget.step!.description != null &&
          widget.step!.description!.isNotEmpty) {
        legacy.add(StepContent.text(content: widget.step!.description));
        migrated = true;
      }

      // Command
      if (widget.step!.command != null && widget.step!.command!.isNotEmpty) {
        legacy.add(
          StepContent.command(
            command: widget.step!.command,
            language: widget.step!.commandLanguage,
            showOutput: widget.step!.showOutput,
            output: widget.step!.output,
          ),
        );
        migrated = true;
      }

      // Screenshot
      if (widget.step!.image != null) {
        legacy.add(
          StepContent.image(
            image: widget.step!.image,
            caption: widget.step!.imageCaption,
          ),
        );
        migrated = true;
      }

      // If we found content but list was empty, migrate
      if (migrated) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onUpdate(widget.step!.copyWith(contents: legacy));
        });
      } else if (legacy.isEmpty && widget.step!.contents.isEmpty) {
        // If completely empty new step, maybe add a text block by default?
        // Or leave empty. User can add content.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onUpdate(
            widget.step!.copyWith(contents: [StepContent.text()]),
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _titleController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addContent(StepContentType type) {
    if (widget.step == null) return;

    final newContent = type == StepContentType.text
        ? StepContent.text()
        : type == StepContentType.command
        ? StepContent.command()
        : StepContent.image();

    final updatedlist = List<StepContent>.from(widget.step!.contents)
      ..add(newContent);
    widget.onUpdate(widget.step!.copyWith(contents: updatedlist));

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _updateContentItem(int index, StepContent updated) {
    if (widget.step == null) return;
    final updatedList = List<StepContent>.from(widget.step!.contents);
    if (index >= 0 && index < updatedList.length) {
      updatedList[index] = updated;
      widget.onUpdate(widget.step!.copyWith(contents: updatedList));
    }
  }

  void _removeContentItem(String id) {
    if (widget.step == null) return;
    final updatedList = List<StepContent>.from(widget.step!.contents);
    updatedList.removeWhere((c) => c.id == id);
    widget.onUpdate(widget.step!.copyWith(contents: updatedList));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.step == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.touch_app_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'Select a step to edit',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Step Editor',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text('${widget.step!.contents.length} Blocks'),
                labelStyle: const TextStyle(fontSize: 10),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Step Title',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
            onChanged: (value) {
              if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
              _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                if (mounted && widget.step != null) {
                  widget.onUpdate(widget.step!.copyWith(title: value));
                }
              });
            },
          ),
          const SizedBox(height: 12),

          // Title Styling Controls
          Row(
            children: [
              const Text(
                'Title Style:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 12),
              // Bold toggle
              FilterChip(
                label: const Text('Bold'),
                selected: widget.step!.isBold,
                onSelected: (selected) {
                  widget.onUpdate(widget.step!.copyWith(isBold: selected));
                },
                avatar: Icon(
                  Icons.format_bold,
                  size: 16,
                  color: widget.step!.isBold ? Colors.white : Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              // Color picker
              const Text('Color:', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 8),
              _buildColorPicker(null, 'Default'),
              _buildColorPicker('#FF5733', 'Red'),
              _buildColorPicker('#3498DB', 'Blue'),
              _buildColorPicker('#2ECC71', 'Green'),
              _buildColorPicker('#F39C12', 'Orange'),
              _buildColorPicker('#9B59B6', 'Purple'),
              const SizedBox(width: 4),
              _buildCustomColorButton(),
            ],
          ),
          const SizedBox(height: 12),

          // Content List
          Expanded(
            child: widget.step!.contents.isEmpty
                ? _buildEmptyState()
                : ReorderableListView.builder(
                    scrollController: _scrollController,
                    buildDefaultDragHandles: false, // Custom handles
                    padding: const EdgeInsets.only(
                      bottom: 80,
                    ), // Space for FABs or buttons
                    itemCount: widget.step!.contents.length,
                    onReorder: (oldIndex, newIndex) {
                      if (oldIndex < newIndex) newIndex -= 1;
                      final items = List<StepContent>.from(
                        widget.step!.contents,
                      );
                      final item = items.removeAt(oldIndex);
                      items.insert(newIndex, item);
                      widget.onUpdate(widget.step!.copyWith(contents: items));
                    },
                    itemBuilder: (context, index) {
                      final content = widget.step!.contents[index];
                      return Padding(
                        key: ValueKey(content.id),
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ReorderableDragStartListener(
                              index: index,
                              child: const Icon(
                                Icons.drag_handle,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildEditorForContent(index, content),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Add Buttons
          const Divider(),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'Add Content:',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildAddButton(
                'Add Text Block',
                Icons.text_fields,
                () => _addContent(StepContentType.text),
              ),
              _buildAddButton(
                'Add Command',
                Icons.terminal,
                () => _addContent(StepContentType.command),
              ),
              _buildAddButton(
                'Add Screenshot',
                Icons.image,
                () => _addContent(StepContentType.image),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.layers_clear, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('No content yet. Add a block below.'),
        ],
      ),
    );
  }

  Widget _buildEditorForContent(int index, StepContent content) {
    // We pass ValueKey based on ID to ensure editors are recreated correctly
    switch (content.type) {
      case StepContentType.text:
        return TextContentEditor(
          key: ValueKey('text_${content.id}'),
          content: content,
          onUpdate: (updated) => _updateContentItem(index, updated),
          onDelete: _removeContentItem,
        );
      case StepContentType.command:
        return CommandContentEditor(
          key: ValueKey('cmd_${content.id}'),
          content: content,
          onUpdate: (updated) => _updateContentItem(index, updated),
          onDelete: _removeContentItem,
        );
      case StepContentType.image:
        return ScreenshotContentEditor(
          key: ValueKey('img_${content.id}'),
          content: content,
          onUpdate: (updated) => _updateContentItem(index, updated),
          onDelete: _removeContentItem,
          imageService: context.read<ImageHandlerService>(),
        );
    }
  }

  Widget _buildAddButton(String label, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
        elevation: 0,
      ),
    );
  }

  Widget _buildColorPicker(String? colorHex, String label) {
    final isSelected = widget.step!.titleColor == colorHex;
    Color? displayColor;
    if (colorHex != null) {
      displayColor = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    }

    return Tooltip(
      message: label,
      child: InkWell(
        onTap: () {
          widget.onUpdate(widget.step!.copyWith(titleColor: colorHex));
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: displayColor ?? Colors.grey.shade300,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? Colors.black : Colors.grey.shade400,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: isSelected
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : null,
        ),
      ),
    );
  }

  Widget _buildCustomColorButton() {
    return Tooltip(
      message: 'Custom Hex Color',
      child: InkWell(
        onTap: _showCustomColorDialog,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: const Icon(Icons.add, size: 16, color: Colors.black54),
        ),
      ),
    );
  }

  void _showCustomColorDialog() {
    final controller = TextEditingController(text: widget.step!.titleColor);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Hex Color'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Hex Code',
            hintText: '#RRGGBB',
            prefixText: '#',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              var hex = controller.text.trim();
              if (hex.isNotEmpty) {
                if (!hex.startsWith('#')) hex = '#$hex';
                // Simple validation
                if (RegExp(r'^#([0-9A-Fa-f]{6})$').hasMatch(hex)) {
                  widget.onUpdate(widget.step!.copyWith(titleColor: hex));
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid Hex Code')),
                  );
                }
              }
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
