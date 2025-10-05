import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../data/repository/health_repository.dart';
import '../../domain/entities/chart_modal.dart';
import '../../domain/entities/data_point.dart';

class DashboardController extends ChangeNotifier {
  void init() {
    listenToHealthData();
    initPerformanceListener();
  }

  final HealthRepository _healthRepository = HealthRepository();
  StreamSubscription? _healthSubscription;

  int _totalSteps = 0;
  int _currentHeartRate = 0;
  DateTime _lastHeartRateTimestamp = DateTime.now();

  Timer? _simulationTimer;
  bool _isSimulating = false;
  final Random _random = Random();

  String _averageBuildTimeMs = '';
  String _fps = '';
  final Queue<FrameTiming> _frameTimings = Queue();

  String get averageBuildTimeMs => _averageBuildTimeMs;
  String get fps => _fps;

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

  void initPerformanceListener() {
    SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
  }

  void _onFrameTimings(List<FrameTiming> timings) {
    for (var timing in timings) {
      _frameTimings.add(timing);
      if (_frameTimings.length > 60) {
        _frameTimings.removeFirst();
      }
    }
    _calculatePerformanceMetrics();
  }

  void _calculatePerformanceMetrics() {
    if (_frameTimings.isEmpty) return;

    final totalBuildTime = _frameTimings.fold<Duration>(
      Duration.zero,
      (prev, timing) => prev + timing.buildDuration,
    );
    final avgBuildTime = totalBuildTime.inMicroseconds / _frameTimings.length;
    _averageBuildTimeMs = '${(avgBuildTime / 1000).toStringAsFixed(1)}ms';
    final totalFrameSpan = _frameTimings.fold<Duration>(
      Duration.zero,
      (prev, timing) => prev + timing.totalSpan,
    );
    final avgFrameTime = totalFrameSpan.inMicroseconds / _frameTimings.length;

    _fps = (1000000 / avgFrameTime).toStringAsFixed(0);

    notifyListeners();
  }

  void toggleSimulation() {
    if (_isSimulating) {
      _stopSimulation();
      listenToHealthData();
    } else {
      _healthSubscription?.cancel();
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
      DataPoint(
        timestamp: now,
        value: (_random.nextInt(20) + 5).toDouble(),
        type: 'Step',
      ),
    );
    heartRateDataPoints.add(
      DataPoint(
        timestamp: now,
        value: _currentHeartRate.toDouble(),
        type: 'Heart Rate',
      ),
    );

    if (stepDataPoints.length > 100) {
      stepDataPoints.removeAt(0);
    }
    if (heartRateDataPoints.length > 100) {
      heartRateDataPoints.removeAt(0);
    }

    notifyListeners();
  }

  int _lastStepCount = 0;

  void listenToHealthData() {
    _healthSubscription?.cancel();
    _healthSubscription = _healthRepository.healthDataStream.listen((
      dataPoint,
    ) {
      if (dataPoint.type == "steps") {
        final currentStepCount = dataPoint.value.toInt();
        final delta = currentStepCount - _lastStepCount;
        if (delta > 0) {
          _totalSteps += delta;
          _lastStepCount = currentStepCount;
          stepDataPoints.add(dataPoint);
          if (stepDataPoints.length > 100) stepDataPoints.removeAt(0);

          debugPrint(
            "Step count received: $currentStepCount, delta: $delta, totalSteps: $_totalSteps",
          );
        }
      } else if (dataPoint.type == "heartRate") {
        _currentHeartRate = dataPoint.value.toInt();
        _lastHeartRateTimestamp = dataPoint.timestamp;
        heartRateDataPoints.add(dataPoint);
        if (heartRateDataPoints.length > 100) heartRateDataPoints.removeAt(0);

        debugPrint(
          "Heart rate received: $_currentHeartRate bpm at $_lastHeartRateTimestamp",
        );
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
    _simulationTimer?.cancel();
    _simulationTimer?.cancel();
    _healthSubscription?.cancel();
    super.dispose();
  }
}
