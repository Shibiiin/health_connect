import 'package:flutter_test/flutter_test.dart';
import 'package:health_connect/Health%20Connects/presentation/manager/dashboard_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DashboardController Unit Tests', () {
    test('Initial state is correct', () {
      final controller = DashboardController();
      expect(controller.isSimulating, isFalse);
      expect(controller.stepDataPoints, isEmpty);
    });

    test('toggleSimulation correctly starts and stops', () {
      final controller = DashboardController();

      controller.init();

      controller.toggleSimulation();
      expect(controller.isSimulating, isTrue);

      controller.toggleSimulation();
      expect(controller.isSimulating, isFalse);

      controller.dispose();
    });

    test('Fake data generation updates state after a delay', () async {
      final controller = DashboardController();
      final initialSteps = controller.totalSteps;

      // FIX: Initialize the controller so its listeners are active.
      controller.init();

      controller.toggleSimulation();
      await Future.delayed(const Duration(seconds: 3));

      expect(controller.totalSteps, greaterThan(initialSteps));
      expect(controller.stepDataPoints, isNotEmpty);
      expect(controller.heartRateDataPoints, isNotEmpty);

      controller.dispose();
    });
  });
}
