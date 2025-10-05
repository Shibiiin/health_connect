import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_connect/Health%20Connects/presentation/manager/dashboard_controller.dart';
import 'package:health_connect/Health%20Connects/presentation/routes/appPages.dart';
import 'package:health_connect/Health%20Connects/presentation/widget/info_card.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full app flow test with permission mocked', (
    WidgetTester tester,
  ) async {
    // TODO: Mock platform channel to return permission granted or mock repository for real app

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => DashboardController(),
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

    await tester.pumpAndSettle(
      const Duration(seconds: 10),
    ); // Allow routing & UI to stabilize

    // If your app shows a permission dialog, you may detect and tap allow button here:
    final allowButton = find.text(
      'Allow',
    ); // or adapt to your permission button text
    if (allowButton.evaluate().isNotEmpty) {
      await tester.tap(allowButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    }

    // Find InfoCard with "Steps" title
    final infoCards = find.byWidgetPredicate(
      (widget) => widget is InfoCard && widget.modal.title.contains("Steps"),
    );
    expect(infoCards, findsAtLeastNWidgets(1));

    final textWidgetsFinder = find.descendant(
      of: infoCards,
      matching: find.byType(Text),
    );
    final textWidgets = textWidgetsFinder.evaluate();
    expect(textWidgets.isNotEmpty, true);
    final initialStepsText = (textWidgets.first.widget as Text).data!;
    print('Initial steps: $initialStepsText');

    // Check performance HUD info
    expect(find.textContaining('build:'), findsOneWidget);
    expect(find.textContaining('fps:'), findsOneWidget);

    print('SUCCESS: Dashboard shows steps info and performance HUD.');
  });
}
