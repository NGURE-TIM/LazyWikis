import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:lazywikis/data/models/image_annotation.dart';

class AnnotationBaker {
  /// Renders annotations onto the provided image bytes and returns the new PNG bytes.
  static Future<Uint8List> bake(
    Uint8List imageData,
    List<ImageAnnotation> annotations,
  ) async {
    // 1. Decode image (async)
    final codec = await ui.instantiateImageCodec(imageData);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    // 2. Setup Canvas
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(
      recorder,
      ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
    );

    // 3. Draw Background Image
    canvas.drawImage(image, ui.Offset.zero, ui.Paint());

    // 4. Draw Annotations
    for (var annotation in annotations) {
      final start = _toImageOffset(
        annotation.start,
        image.width.toDouble(),
        image.height.toDouble(),
      );
      final end = _toImageOffset(
        annotation.end,
        image.width.toDouble(),
        image.height.toDouble(),
      );
      final paint = ui.Paint()
        ..color = annotation.color
        ..strokeWidth = annotation.strokeWidth
        ..style = ui.PaintingStyle.stroke; // Outline only

      switch (annotation.type) {
        case AnnotationType.rectangle:
          final rect = ui.Rect.fromPoints(start, end);
          canvas.drawRect(rect, paint);
          break;
        case AnnotationType.circle:
          final rect = ui.Rect.fromPoints(start, end);
          canvas.drawOval(rect, paint);
          break;
        case AnnotationType.arrow:
          _drawArrow(canvas, start, end, paint);
          break;
      }
    }

    // 5. Finish and Encode
    final picture = recorder.endRecording();
    final bakedImage = await picture.toImage(image.width, image.height);
    final byteData = await bakedImage.toByteData(
      format: ui.ImageByteFormat.png,
    );

    // Dispose resources
    image.dispose();
    picture.dispose();
    bakedImage.dispose();

    if (byteData == null) {
      throw Exception('Failed to encode baked image');
    }
    return byteData.buffer.asUint8List();
  }

  static void _drawArrow(
    ui.Canvas canvas,
    ui.Offset start,
    ui.Offset end,
    ui.Paint paint,
  ) {
    // Draw main line
    canvas.drawLine(start, end, paint);

    // Draw arrow head at end
    const arrowHeadLength = 15.0;
    const arrowHeadAngle = 30 * math.pi / 180; // 30 degrees

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final angle = math.atan2(dy, dx);

    // Left wing
    final x1 = end.dx - arrowHeadLength * math.cos(angle - arrowHeadAngle);
    final y1 = end.dy - arrowHeadLength * math.sin(angle - arrowHeadAngle);

    // Right wing
    final x2 = end.dx - arrowHeadLength * math.cos(angle + arrowHeadAngle);
    final y2 = end.dy - arrowHeadLength * math.sin(angle + arrowHeadAngle);

    final path = ui.Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(x1, y1)
      ..moveTo(end.dx, end.dy)
      ..lineTo(x2, y2);

    // Use stroke cap round for better look
    final arrowPaint = ui.Paint()
      ..color = paint.color
      ..strokeWidth = paint.strokeWidth
      ..style = ui.PaintingStyle.stroke
      ..strokeCap = ui.StrokeCap.round
      ..strokeJoin = ui.StrokeJoin.round;

    canvas.drawPath(path, arrowPaint);
  }

  static ui.Offset _toImageOffset(
    ui.Offset point,
    double width,
    double height,
  ) {
    if (_isRelative(point)) {
      return ui.Offset(point.dx * width, point.dy * height);
    }
    return point;
  }

  static bool _isRelative(ui.Offset point) {
    return point.dx >= 0 && point.dx <= 1 && point.dy >= 0 && point.dy <= 1;
  }
}
