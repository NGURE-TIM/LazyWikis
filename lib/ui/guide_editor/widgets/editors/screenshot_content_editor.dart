import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:lazywikis/data/models/step_content.dart';
import 'package:lazywikis/data/models/image_annotation.dart';
import 'package:lazywikis/data/services/image_handler_service.dart';
import 'package:lazywikis/ui/guide_editor/widgets/editors/annotation_painter.dart';

class ScreenshotContentEditor extends StatefulWidget {
  final StepContent content;
  final ValueChanged<StepContent> onUpdate;
  final ValueChanged<String>? onDelete;
  final ImageHandlerService imageService;

  const ScreenshotContentEditor({
    super.key,
    required this.content,
    required this.onUpdate,
    required this.imageService,
    this.onDelete,
  });

  @override
  State<ScreenshotContentEditor> createState() =>
      _ScreenshotContentEditorState();
}

class _ScreenshotContentEditorState extends State<ScreenshotContentEditor> {
  final TextEditingController _captionController = TextEditingController();
  Timer? _debounceTimer;

  // Annotation state
  AnnotationType _selectedTool = AnnotationType.arrow;
  Color _selectedColor = Colors.red;
  double _strokeWidth = 3.0;
  bool _isAnnotating = false;

  Offset? _drawStart;
  ImageAnnotation? _currentAnnotation;
  List<ImageAnnotation> _annotations = [];
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    if (widget.content.caption != null) {
      _captionController.text = widget.content.caption!;
    }
    _annotations = List.from(widget.content.image?.annotations ?? []);
    if (widget.content.image?.base64Data != null) {
      _imageBytes = base64Decode(widget.content.image!.base64Data);
    }
  }

  @override
  void didUpdateWidget(ScreenshotContentEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content.caption != widget.content.caption) {
      if (_captionController.text != widget.content.caption) {
        _captionController.text = widget.content.caption ?? '';
      }
    }
    if (oldWidget.content.image != widget.content.image) {
      _annotations = List.from(widget.content.image?.annotations ?? []);
      if (widget.content.image?.base64Data !=
          oldWidget.content.image?.base64Data) {
        if (widget.content.image?.base64Data != null) {
          _imageBytes = base64Decode(widget.content.image!.base64Data);
        } else {
          _imageBytes = null;
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final image = await widget.imageService.pickImage();
    if (image != null) {
      final caption = widget.content.caption?.trim();
      final imageWithCaption = (caption != null && caption.isNotEmpty)
          ? image.copyWith(caption: caption)
          : image;
      widget.onUpdate(widget.content.copyWith(image: imageWithCaption));
    }
  }

  void _removeImage() {
    widget.onUpdate(widget.content.copyWith(clearImage: true));
  }

  void _onPanStart(DragStartDetails details) {
    if (!_isAnnotating) return;
    setState(() {
      _drawStart = details.localPosition;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isAnnotating || _drawStart == null) return;
    setState(() {
      _currentAnnotation = ImageAnnotation.create(
        type: _selectedTool,
        start: _drawStart!,
        end: details.localPosition,
        color: _selectedColor,
        strokeWidth: _strokeWidth,
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isAnnotating || _currentAnnotation == null) return;
    setState(() {
      _annotations = List.from(_annotations)..add(_currentAnnotation!);
      _currentAnnotation = null;
      _drawStart = null;
      _saveAnnotations();
    });
  }

  void _saveAnnotations() {
    if (widget.content.image != null) {
      final updatedImage = widget.content.image!.copyWith(
        annotations: _annotations,
      );
      widget.onUpdate(widget.content.copyWith(image: updatedImage));
    }
  }

  void _undoLastAnnotation() {
    if (_annotations.isNotEmpty) {
      setState(() {
        // Create new list to ensure reference change for CustomPainter
        _annotations = List.from(_annotations)..removeLast();
        _saveAnnotations();
      });
    }
  }

  void _clearAllAnnotations() {
    setState(() {
      _annotations = [];
      _saveAnnotations();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.image, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Screenshot',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (widget.onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey),
                    onPressed: () => widget.onDelete!(widget.content.id),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Image or placeholder
            if (widget.content.image != null) ...[
              // Annotation toolbar
              _buildAnnotationToolbar(),
              const SizedBox(height: 8),

              // Image with annotations
              Container(
                constraints: const BoxConstraints(maxHeight: 400),
                child: RawGestureDetector(
                  gestures: _isAnnotating
                      ? {
                          ImmediatePanGestureRecognizer:
                              GestureRecognizerFactoryWithHandlers<
                                ImmediatePanGestureRecognizer
                              >(() => ImmediatePanGestureRecognizer(), (
                                ImmediatePanGestureRecognizer instance,
                              ) {
                                instance.onStart = _onPanStart;
                                instance.onUpdate = _onPanUpdate;
                                instance.onEnd = _onPanEnd;
                              }),
                        }
                      : {},
                  child: Stack(
                    children: [
                      if (_imageBytes != null)
                        Image.memory(
                          _imageBytes!,
                          fit: BoxFit.contain,
                          gaplessPlayback: true,
                        ),
                      Positioned.fill(
                        child: CustomPaint(
                          painter: AnnotationPainter(
                            annotations: _annotations,
                            currentAnnotation: _currentAnnotation,
                          ),
                        ),
                      ),
                      if (!_isAnnotating)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _removeImage,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Caption
              TextField(
                controller: _captionController,
                decoration: const InputDecoration(
                  labelText: 'Caption',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  if (_debounceTimer?.isActive ?? false)
                    _debounceTimer!.cancel();
                  _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                    if (mounted) {
                      final updatedImage = widget.content.image?.copyWith(
                        caption: value.trim().isEmpty ? null : value,
                      );
                      widget.onUpdate(
                        widget.content.copyWith(
                          caption: value,
                          image: updatedImage,
                        ),
                      );
                    }
                  });
                },
              ),
            ] else ...[
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade300,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Add Screenshot'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnnotationToolbar() {
    return Card(
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Annotation Tools:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Switch(
                  value: _isAnnotating,
                  onChanged: (value) => setState(() => _isAnnotating = value),
                ),
                const Text('Draw Mode'),
              ],
            ),
            if (_isAnnotating) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Tool selection
                  _buildToolButton(
                    AnnotationType.arrow,
                    Icons.arrow_forward,
                    'Arrow',
                  ),
                  _buildToolButton(
                    AnnotationType.circle,
                    Icons.circle_outlined,
                    'Circle',
                  ),
                  _buildToolButton(
                    AnnotationType.rectangle,
                    Icons.rectangle_outlined,
                    'Rectangle',
                  ),

                  const SizedBox(width: 16),

                  // Color picker
                  _buildColorButton(Colors.red),
                  _buildColorButton(Colors.blue),
                  _buildColorButton(Colors.green),
                  _buildColorButton(Colors.orange),
                  _buildColorButton(Colors.purple),

                  const SizedBox(width: 16),

                  // Actions
                  // Actions
                  ElevatedButton.icon(
                    icon: const Icon(Icons.undo, size: 16),
                    label: const Text('Undo'),
                    onPressed: _annotations.isNotEmpty
                        ? _undoLastAnnotation
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade100,
                      foregroundColor: Colors.orange.shade900,
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: const Text('Clear'),
                    onPressed: _annotations.isNotEmpty
                        ? _clearAllAnnotations
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      foregroundColor: Colors.red.shade900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Stroke Width:'),
                  Expanded(
                    child: Slider(
                      value: _strokeWidth,
                      min: 1.0,
                      max: 10.0,
                      divisions: 9,
                      label: _strokeWidth.toStringAsFixed(0),
                      onChanged: (value) =>
                          setState(() => _strokeWidth = value),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton(AnnotationType type, IconData icon, String label) {
    final isSelected = _selectedTool == type;
    return ElevatedButton.icon(
      onPressed: () => setState(() => _selectedTool = type),
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    final isSelected = _selectedColor == color;
    return InkWell(
      onTap: () => setState(() => _selectedColor = color),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey,
            width: isSelected ? 3 : 1,
          ),
        ),
      ),
    );
  }
}

class ImmediatePanGestureRecognizer extends PanGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }

  @override
  String get debugDescription => 'immediate pan';
}
