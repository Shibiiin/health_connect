import 'package:flutter/material.dart';
import 'package:health_connect/Health%20Connects/presentation/manager/dashboard_controller.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/data_point.dart';
import 'line_chart_widget.dart';

class ChartContainer extends StatelessWidget {
  final String title;
  final Gradient? gradient;
  final List<DataPoint> data;
  final bool startYAxisAtZero;

  const ChartContainer({
    super.key,
    required this.title,
    this.gradient,
    required this.data,
    this.startYAxisAtZero = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.read<DashboardController>();

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: data.isEmpty
                  ? Center(
                      child: Text(
                        'No data to display',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                    )
                  : LineChart(
                      data: data,
                      gradient: LinearGradient(
                        colors: [
                          gradient?.colors.first.withValues(alpha: 0.4) ??
                              Colors.white,
                          gradient?.colors.last.withValues(alpha: 0.0) ??
                              Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      startYAxisAtZero: startYAxisAtZero,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
