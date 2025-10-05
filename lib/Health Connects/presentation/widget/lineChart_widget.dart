import 'dart:math';

import 'package:flutter/material.dart';
import 'package:health_connect/Health%20Connects/presentation/manager/dashboard_controller.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/data_point.dart';

class LineChart extends StatefulWidget {
  final List<DataPoint> data;
  final Gradient gradient;
  final bool startYAxisAtZero;

  const LineChart({
    super.key,
    required this.data,
    required this.gradient,
    required this.startYAxisAtZero,
  });

  @override
  _LineChartState createState() => _LineChartState();
}

class _LineChartState extends State<LineChart>
    with SingleTickerProviderStateMixin {
  double _zoom = 1.0;
  double _offset = 0.0;
  Offset? _tapPosition;

  // Gesture start points
  double _startZoom = 1.0;
  double _startOffset = 0.0;
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
    final controller = context.watch<DashboardController>();
    return GestureDetector(
      onScaleStart: (details) {
        setState(() {
          _startZoom = _zoom;
          _startOffset = _offset;
        });
      },
      onScaleUpdate: (details) {
        setState(() {
          _zoom = (_startZoom * details.scale).clamp(1.0, 5.0);
          _offset = _startOffset + details.focalPointDelta.dx;
          _tapPosition = null;
        });
      },
      onTapDown: (details) {
        setState(() {
          _tapPosition = details.localPosition;
        });
      },
      // onTapUp: (details) {
      //   setState(() {
      //     _tapPosition = null;
      //   });
      // },
      child: ClipRRect(
        child: CustomPaint(
          painter: LineChartPainter(
            data: widget.data,
            gradient: widget.gradient,
            zoom: _zoom,
            offset: _offset,
            tapPosition: _tapPosition,
            animation: _animationController,
            context: context,
            startYAxisAtZero: widget.startYAxisAtZero,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<DataPoint> data;
  final Gradient gradient;
  final double zoom;
  final double offset;
  final Offset? tapPosition;
  final Animation<double> animation;
  final BuildContext context;
  final bool startYAxisAtZero;

  LineChartPainter({
    required this.data,
    required this.gradient,
    required this.animation,
    required this.zoom,
    required this.offset,
    required this.tapPosition,
    required this.context,
    required this.startYAxisAtZero,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    _drawGridAndLabels(canvas, size);

    if (data.length < 2) return;

    final (minY, maxY) = _calculateMinMaxY();
    final displayRange = (maxY - minY).clamp(1.0, double.infinity);
    final coordinates = _getTransformedCoordinates(size, minY, displayRange);
    final linePath = _createLinePath(coordinates);

    linePath.moveTo(coordinates.first.dx, coordinates.first.dy);
    for (int i = 1; i < coordinates.length; i++) {
      linePath.lineTo(coordinates[i].dx, coordinates[i].dy);
    }

    /// Draw the gradient fill
    _drawGradientFill(canvas, size, linePath);

    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(linePath, linePaint);

    ///draw Tooltip if a tap has occurred
    if (tapPosition != null) {
      _drawTooltip(canvas, size, coordinates);
    }
  }

  /// y axis
  void _drawGridAndLabels(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    final (minY, maxY) = _calculateMinMaxY();

    for (int i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);

      final value = maxY - (maxY - minY) * (i / 4);
      _drawText(
        canvas,
        value.toStringAsFixed(0),
        Offset(size.width - 4, y - 12),
        textAlign: TextAlign.right,
      );
    }
    _drawXAxisLabels(canvas, size);
  }

  /// time - x axis
  void _drawXAxisLabels(Canvas canvas, Size size) {
    const timeWindow = Duration(minutes: 60);
    final now = DateTime.now();
    int labelCount = 4;

    for (int i = 0; i < labelCount; i++) {
      final double fraction = i / (labelCount - 1);
      final x = size.width * fraction;

      final timeAgo = Duration(
        minutes: (timeWindow.inMinutes * (1 - fraction)).round(),
      );
      final labelTime = now.subtract(timeAgo);

      final timeString = _formatTime(labelTime);

      _drawText(
        canvas,
        timeString,
        Offset(x, size.height + 4),
        textAlign: TextAlign.center,
      );
    }
  }

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position, {
    TextAlign textAlign = TextAlign.center,
  }) {
    final textStyle = TextStyle(
      color: Colors.white.withOpacity(0.5),
      fontSize: 10,
    );
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: textAlign,
      textDirection: TextDirection.ltr,
    )..layout();

    var effectivePosition = position;
    if (textAlign == TextAlign.right) {
      effectivePosition = Offset(position.dx - textPainter.width, position.dy);
    } else if (textAlign == TextAlign.center) {
      effectivePosition = Offset(
        position.dx - textPainter.width / 2,
        position.dy,
      );
    }
    textPainter.paint(canvas, effectivePosition);
  }

  (double, double) _calculateMinMaxY() {
    if (data.isEmpty) return (0, 100);

    if (startYAxisAtZero) {
      double maxY = 0;
      for (var p in data) {
        maxY = max(maxY, p.value);
      }

      return (0, (maxY * 1.2).clamp(10.0, double.infinity));
    } else {
      double minY = data.first.value;
      double maxY = data.first.value;
      for (var p in data) {
        minY = min(minY, p.value);
        maxY = max(maxY, p.value);
      }
      final range = (maxY - minY).clamp(1.0, double.infinity);
      return (minY - range * 0.1, maxY + range * 0.2);
    }
  }

  List<Offset> _getTransformedCoordinates(
    Size size,
    double minY,
    double displayRange,
  ) {
    final coordinates = <Offset>[];
    // Calculate the full width of the chart content if it were all on screen
    final totalContentWidth = size.width * zoom;
    // Calculate the maximum possible offset (how far you can pan left)
    final maxHorizontalOffset = (totalContentWidth - size.width).clamp(
      0.0,
      double.infinity,
    );
    // Clamp the current offset to ensure you can't pan past the content boundaries
    final clampedOffset = offset.clamp(-maxHorizontalOffset, 0.0);

    for (int i = 0; i < data.length; i++) {
      final double x =
          (i / (data.length - 1)) * totalContentWidth + clampedOffset;
      final double y =
          size.height - ((data[i].value - minY) / displayRange) * size.height;
      coordinates.add(Offset(x, y));
    }
    return coordinates;
  }

  Path _createLinePath(List<Offset> coordinates) {
    final path = Path();
    if (coordinates.isEmpty) return path;
    path.moveTo(coordinates.first.dx, coordinates.first.dy);
    for (int i = 1; i < coordinates.length; i++) {
      path.lineTo(coordinates[i].dx, coordinates[i].dy);
    }
    return path;
  }

  void _drawGradientFill(Canvas canvas, Size size, Path linePath) {
    final fillPath = Path.from(linePath);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    canvas.drawPath(fillPath, fillPaint);
  }

  void _drawTooltip(Canvas canvas, Size size, List<Offset> coordinates) {
    // ... (This function is correct, no changes, but I'll use the _formatTime helper for consistency)
    int closestIndex = -1;
    double minDistance = double.infinity;

    for (int i = 0; i < coordinates.length; i++) {
      final distance = (coordinates[i].dx - tapPosition!.dx).abs();
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    if (closestIndex == -1) return;

    final targetPoint = coordinates[closestIndex];
    final targetData = data[closestIndex];

    final linePaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(targetPoint.dx, targetPoint.dy),
      Offset(targetPoint.dx, size.height),
      linePaint,
    );
    canvas.drawCircle(targetPoint, 6, Paint()..color = Colors.white);
    canvas.drawCircle(targetPoint, 4, Paint()..color = Colors.blue.shade300);

    final timeString = _formatTime(targetData.timestamp);
    final textSpan = TextSpan(
      text: "${targetData.value.toStringAsFixed(0)} at $timeString",
      style: TextStyle(color: Colors.white, fontSize: 12),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    double tooltipX = targetPoint.dx + 10;
    if (tooltipX + textPainter.width > size.width) {
      tooltipX = targetPoint.dx - textPainter.width - 10;
    }

    final tooltipY = targetPoint.dy - textPainter.height - 5;
    final rect = Rect.fromPoints(
      Offset(tooltipX - 4, tooltipY - 4),
      Offset(
        tooltipX + textPainter.width + 4,
        tooltipY + textPainter.height + 4,
      ),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(4)),
      Paint()..color = Colors.black.withOpacity(0.7),
    );
    textPainter.paint(canvas, Offset(tooltipX, tooltipY));
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.zoom != zoom ||
        oldDelegate.offset != offset ||
        oldDelegate.tapPosition != tapPosition;
    oldDelegate.startYAxisAtZero != startYAxisAtZero;
  }
}
