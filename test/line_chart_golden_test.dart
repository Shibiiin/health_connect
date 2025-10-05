// test/line_chart_golden_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_connect/Health%20Connects/domain/entities/data_point.dart';
import 'package:health_connect/Health%20Connects/presentation/widget/line_chart_widget.dart';

void main() {
  testWidgets('LineChart Golden Test', (WidgetTester tester) async {
    // ARRANGE: Create a fixed, predictable dataset for the chart
    final testData = [
      DataPoint(
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        value: 10,
        type: '',
      ),
      DataPoint(
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
        value: 30,
        type: '',
      ),
      DataPoint(
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
        value: 15,
        type: '',
      ),
      DataPoint(
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        value: 45,
        type: '',
      ),
      DataPoint(
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
        value: 25,
        type: '',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              height: 150,
              child: LineChart(
                data: testData,
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.green],
                ),
                startYAxisAtZero: false,
              ),
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(LineChart),
      matchesGoldenFile('goldens/line_chart.png'),
    );
  });
}
