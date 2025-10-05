import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_connect/Health%20Connects/presentation/manager/dashboard_controller.dart';
import 'package:health_connect/Health%20Connects/presentation/routes/app_pages.dart';
import 'package:health_connect/Health%20Connects/presentation/widget/info_card.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel(
    'com.example.health_connect/method_channel',
  );

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'checkPermissions' ||
              methodCall.method == 'requestPermissions') {
            return true;
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('Full app flow test with permissions mocked', (
    WidgetTester tester,
  ) async {
    final dashboardController = DashboardController();

    // Pump the widget tree with the provider
    await tester.pumpWidget(
      ChangeNotifierProvider<DashboardController>.value(
        value: dashboardController,
        child: ScreenUtilInit(
          designSize: const Size(360, 690),
          builder: (_, child) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              routerConfig: AppPages().goRouter,
            );
          },
        ),
      ),
    );

    // Wait long enough for animations, routing, and rendering
    await tester.pumpAndSettle(const Duration(seconds: 10));

    // Find InfoCard widget with title containing "Steps"
    final infoCardFinder = find.byWidgetPredicate(
      (widget) => widget is InfoCard && widget.modal.title.contains("Steps"),
    );

    // Verify at least one InfoCard found
    expect(infoCardFinder, findsWidgets);

    // Find Text widgets inside that InfoCard
    final textFinder = find.descendant(
      of: infoCardFinder,
      matching: find.byType(Text),
    );

    final textWidgets = textFinder.evaluate();
    expect(textWidgets.isNotEmpty, true);

    // Get the text data from first Text widget of the InfoCard
    final initialStepText = (textWidgets.first.widget as Text).data!;
    if (kDebugMode) {
      print('Initial Steps Text: $initialStepText');
    }

    // Verify presence of Performance HUD with build and fps data
    expect(find.textContaining('build:'), findsOneWidget);
    expect(find.textContaining('fps:'), findsOneWidget);

    if (kDebugMode) {
      print('SUCCESS: Dashboard rendered with step info and performance HUD.');
    }
  });
}
