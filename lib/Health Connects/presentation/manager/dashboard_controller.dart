import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../domain/entities/chart_modal.dart';
import '../../domain/entities/data_point.dart';

class DashboardController extends ChangeNotifier {
  int _totalSteps = 0;
  int _currentHeartRate = 0;
  DateTime _lastHeartRateTimestamp = DateTime.now();

  Timer? _simulationTimer;
  bool _isSimulating = false;
  final Random _random = Random();

  int get totalSteps => _totalSteps;
  int get currentHeartRate => _currentHeartRate;
  bool get isSimulating => _isSimulating;

  String get heartRateTimestampAge {
    final difference = DateTime.now().difference(_lastHeartRateTimestamp);
    if (difference.inSeconds < 1) return "Just Now";
    return "${difference.inSeconds}s ago";
  }

  final List<ChartModal> chartData = [
    ChartModal(
      title: 'Steps vs. Time (Last 60 min)',
      gradient: LinearGradient(
        colors: [
          const Color(0xFF4CAF50).withOpacity(0.3),
          const Color(0xFF45C7C1).withOpacity(0.1),
        ],
      ),
    ),
    ChartModal(
      title: 'Heart Rate vs. Time',
      gradient: LinearGradient(
        colors: [
          const Color(0xFFF44336).withOpacity(0.3),
          const Color(0xFFFF7597).withOpacity(0.1),
        ],
      ),
    ),
  ];

  final List<DataPoint> stepDataPoints = [];
  final List<DataPoint> heartRateDataPoints = [];

  void toggleSimulation() {
    if (_isSimulating) {
      _stopSimulation();
    } else {
      _startSimulation();
    }
    _isSimulating = !_isSimulating;
    notifyListeners();
  }

  void _startSimulation() {
    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _generateFakeData();
    });
  }

  void _stopSimulation() {
    _simulationTimer?.cancel();
  }

  void _generateFakeData() {
    final now = DateTime.now();

    _totalSteps += _random.nextInt(20) + 5;
    _currentHeartRate = 70 + _random.nextInt(15) - 7;
    _lastHeartRateTimestamp = now;

    stepDataPoints.add(
      DataPoint(timestamp: now, value: (_random.nextInt(20) + 5).toDouble()),
    );
    heartRateDataPoints.add(
      DataPoint(timestamp: now, value: _currentHeartRate.toDouble()),
    );

    if (stepDataPoints.length > 100) {
      stepDataPoints.removeAt(0);
    }
    if (heartRateDataPoints.length > 100) {
      heartRateDataPoints.removeAt(0);
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}
