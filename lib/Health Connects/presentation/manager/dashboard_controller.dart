import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../domain/entities/chart_modal.dart';
import '../../domain/entities/infoCard_modal.dart';

class DashboardController extends ChangeNotifier {
  final List<InfoCardModal> infoCards = [
    InfoCardModal(
      title: "Today's Steps",
      value: "10,452",
      icon: Icons.directions_walk,
      subValue: null,
      gradient: const LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF45C7C1)],
      ),
    ),
    InfoCardModal(
      title: "Current Heart Rate",
      value: "72 bpm",
      subValue: "just now",
      icon: Icons.favorite,
      gradient: const LinearGradient(
        colors: [Color(0xFFF44336), Color(0xFFFF7597)],
      ),
    ),
  ];

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
    ChartModal(
      title: 'Calories Burned Over Time',
      gradient: LinearGradient(
        colors: [
          const Color(0xFFFF9800).withOpacity(0.3),
          const Color(0xFFFFC107).withOpacity(0.1),
        ],
      ),
    ),
  ];

  int _totalSteps = 1500;
  int _currentHeartRate = 72;
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
    _totalSteps += _random.nextInt(20) + 5;

    _currentHeartRate = 70 + _random.nextInt(15) - 7;
    _lastHeartRateTimestamp = DateTime.now();
    notifyListeners();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}
