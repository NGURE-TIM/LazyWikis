import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lazywikis/data/models/image_annotation.dart';

class AnnotationPainter extends CustomPainter {
  final List<ImageAnnotation> annotations;
  final ImageAnnotation? currentAnnotation; // Preview while drawing

  AnnotationPainter({required this.annotations, this.currentAnnotation});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw all finalized annotations
    for (var annotation in annotations) {
      _drawAnnotation(canvas, annotation, size);
    }

    // Draw current annotation preview
    if (currentAnnotation != null) {
      _drawAnnotation(canvas, currentAnnotation!, size);
    }
  }

  void _drawAnnotation(Canvas canvas, ImageAnnotation annotation, Size size) {
    final start = _toCanvasOffset(annotation.start, size);
    final end = _toCanvasOffset(annotation.end, size);
    final paint = Paint()
      ..color = annotation.color
      ..strokeWidth = annotation.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    switch (annotation.type) {
      case AnnotationType.arrow:
        _drawArrow(canvas, start, end, paint);
        break;
      case AnnotationType.circle:
        _drawCircle(canvas, start, end, paint);
        break;
      case AnnotationType.rectangle:
        _drawRectangle(canvas, start, end, paint);
        break;
    }
  }

  Offset _toCanvasOffset(Offset point, Size size) {
    if (_isRelative(point)) {
      return Offset(point.dx * size.width, point.dy * size.height);
    }
    return point;
  }

  bool _isRelative(Offset point) {
    return point.dx >= 0 && point.dx <= 1 && point.dy >= 0 && point.dy <= 1;
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    // Draw line
    canvas.drawLine(start, end, paint);

    // Draw arrowhead
    const arrowSize = 15.0;
    final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);

    final arrowPath = Path();
    arrowPath.moveTo(end.dx, end.dy);
    arrowPath.lineTo(
      end.dx - arrowSize * math.cos(angle - math.pi / 6),
      end.dy - arrowSize * math.sin(angle - math.pi / 6),
    );
    arrowPath.moveTo(end.dx, end.dy);
    arrowPath.lineTo(
      end.dx - arrowSize * math.cos(angle + math.pi / 6),
      end.dy - arrowSize * math.sin(angle + math.pi / 6),
    );

    canvas.drawPath(arrowPath, paint);
  }

  void _drawCircle(Canvas canvas, Offset start, Offset end, Paint paint) {
    final center = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
    final radiusX = (end.dx - start.dx).abs() / 2;
    final radiusY = (end.dy - start.dy).abs() / 2;

    canvas.drawOval(
      Rect.fromCenter(center: center, width: radiusX * 2, height: radiusY * 2),
      paint,
    );
  }

  void _drawRectangle(Canvas canvas, Offset start, Offset end, Paint paint) {
    final rect = Rect.fromPoints(start, end);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(AnnotationPainter oldDelegate) {
    return annotations != oldDelegate.annotations ||
        currentAnnotation != oldDelegate.currentAnnotation;
  }
}
