// test/dashboard_controller_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:health_connect/Health%20Connects/presentation/manager/dashboard_controller.dart';

void main() {
  group('DashboardController Unit Tests', () {
    test('Initial state is correct', () {
      final controller = DashboardController();

      /// ACT & ASSERT: Check if the initial values are as expected
      expect(controller.isSimulating, isFalse);
      expect(controller.totalSteps, isA<int>()); // Check type
      expect(controller.stepDataPoints, isEmpty);
      expect(controller.heartRateDataPoints, isEmpty);
    });

    test('toggleSimulation correctly starts and stops the simulation', () {
      final controller = DashboardController();

      /// ACT: Call the method to start the simulation
      controller.toggleSimulation();

      /// ASSERT: The state should now be 'simulating'
      expect(controller.isSimulating, isTrue);

      /// ACT: Call the method again to stop it
      controller.toggleSimulation();

      /// ASSERT: The state should be 'not simulating'
      expect(controller.isSimulating, isFalse);
    });

    test('Generating fake data updates the state', () async {
      /// ARRANGE
      final controller = DashboardController();
      final initialStepCount = controller.totalSteps;

      controller.toggleSimulation();
      await Future.delayed(const Duration(seconds: 3));
      expect(controller.totalSteps, isNot(equals(initialStepCount)));
      expect(controller.stepDataPoints, isNotEmpty);
      expect(controller.heartRateDataPoints, isNotEmpty);
      controller.dispose();
    });
  });
}
