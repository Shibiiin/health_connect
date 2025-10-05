import 'package:flutter/material.dart';

import '../../domain/entities/data_point.dart';

class LineChart extends StatefulWidget {
  final List<DataPoint> data;
  final Gradient gradient;

  const LineChart({super.key, required this.data, required this.gradient});

  @override
  _LineChartState createState() => _LineChartState();
}

class _LineChartState extends State<LineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(covariant LineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.length != widget.data.length) {
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: LineChartPainter(
        data: widget.data,
        gradient: widget.gradient,
        animation: _animationController,
      ),
      size: Size.infinite,
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<DataPoint> data;
  final Gradient gradient;
  final Animation<double> animation;

  LineChartPainter({
    required this.data,
    required this.gradient,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (data.length < 2) return;

    double minY = data.first.value;
    double maxY = data.first.value;
    for (var p in data) {
      if (p.value < minY) minY = p.value;
      if (p.value > maxY) maxY = p.value;
    }

    final range = (maxY - minY).clamp(1.0, double.infinity);
    final paddedMinY = minY - range * 0.1;
    final paddedMaxY = maxY + range * 0.2;
    final displayRange = paddedMaxY - paddedMinY;

    final coordinates = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final double x = (i / (data.length - 1)) * size.width;
      final double y =
          size.height -
          ((data[i].value - paddedMinY) / displayRange) * size.height;
      coordinates.add(Offset(x, y));
    }

    final linePath = Path();
    linePath.moveTo(coordinates.first.dx, coordinates.first.dy);
    for (int i = 1; i < coordinates.length; i++) {
      linePath.lineTo(coordinates[i].dx, coordinates[i].dy);
    }

    final fillPath = Path.from(linePath);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final animatedPath = _createAnimatedPath(linePath, animation.value);

    final fillPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    canvas.drawPath(animatedPath, fillPaint);

    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(animatedPath, linePaint);

    _drawYAxisLabels(canvas, size, paddedMinY, paddedMaxY);
  }

  Path _createAnimatedPath(Path originalPath, double animationPercent) {
    final totalLength = originalPath.computeMetrics().first.length;
    final currentLength = totalLength * animationPercent;
    return originalPath.computeMetrics().first.extractPath(0.0, currentLength);
  }

  void _drawYAxisLabels(Canvas canvas, Size size, double minY, double maxY) {
    final textStyle = TextStyle(
      color: Colors.white.withOpacity(0.5),
      fontSize: 10,
    );

    for (int i = 0; i <= 4; i++) {
      final value = minY + (maxY - minY) * (i / 4);
      final textSpan = TextSpan(
        text: value.toStringAsFixed(0),
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final y = size.height - (size.height * (i / 4)) - textPainter.height / 2;
      textPainter.paint(canvas, Offset(size.width - textPainter.width - 4, y));
    }
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) {
    return data != oldDelegate.data;
  }
}
