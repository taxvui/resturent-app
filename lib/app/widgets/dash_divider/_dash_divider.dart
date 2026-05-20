import 'package:flutter/material.dart';

class DashedDivider extends StatelessWidget {
  final Color color;
  final double thickness;
  final double dashWidth;
  final double gapWidth;

  const DashedDivider({
    super.key,
    this.color = Colors.grey,
    this.thickness = 1.0,
    this.dashWidth = 4.0,
    this.gapWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, thickness),
          painter: _DashedLinePainter(
            color: color,
            thickness: thickness,
            dashWidth: dashWidth,
            gapWidth: gapWidth,
          ),
        );
      },
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double thickness;
  final double dashWidth;
  final double gapWidth;

  _DashedLinePainter({
    required this.color,
    required this.thickness,
    required this.dashWidth,
    required this.gapWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke;

    final totalLength = dashWidth + gapWidth;
    double currentX = 0.0;

    while (currentX < size.width) {
      canvas.drawLine(
        Offset(currentX, 0),
        Offset(currentX + dashWidth, 0),
        paint,
      );
      currentX += totalLength;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
