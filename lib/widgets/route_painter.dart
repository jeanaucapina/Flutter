import 'dart:math';

import 'package:flutter/material.dart';

class RoutePainter extends CustomPainter {
  final Offset startPoint;
  final Offset endPoint;

  RoutePainter({
    required this.startPoint,
    required this.endPoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withValues(alpha: 0.8)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawLine(startPoint, endPoint, paint);

    canvas.drawCircle(
      startPoint,
      6,
      Paint()
        ..color = Colors.green
        ..style = PaintingStyle.fill,
    );

    _drawArrow(canvas, endPoint, startPoint);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Ruta',
        style: TextStyle(
          color: Colors.green,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final midPoint = Offset(
      (startPoint.dx + endPoint.dx) / 2,
      (startPoint.dy + endPoint.dy) / 2,
    );
    textPainter.paint(canvas, midPoint - Offset(textPainter.width / 2, 0));
  }

  void _drawArrow(Canvas canvas, Offset endPoint, Offset startPoint) {
    final angle = (endPoint - startPoint).direction;
    const arrowSize = 20.0;

    final arrowPoint1 = Offset(
      endPoint.dx - arrowSize * cos(angle - 0.4),
      endPoint.dy - arrowSize * sin(angle - 0.4),
    );

    final arrowPoint2 = Offset(
      endPoint.dx - arrowSize * cos(angle + 0.4),
      endPoint.dy - arrowSize * sin(angle + 0.4),
    );

    final path = Path()
      ..moveTo(endPoint.dx, endPoint.dy)
      ..lineTo(arrowPoint1.dx, arrowPoint1.dy)
      ..lineTo(arrowPoint2.dx, arrowPoint2.dy)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.green.withValues(alpha: 0.8)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(RoutePainter oldDelegate) {
    return oldDelegate.startPoint != startPoint ||
        oldDelegate.endPoint != endPoint;
  }
}
