import 'package:go_router/go_router.dart';
import 'package:health_connect/Health%20Connects/presentation/pages/dashboard.dart';
import 'package:health_connect/Health%20Connects/presentation/pages/permission_page.dart';
import 'package:health_connect/Health%20Connects/presentation/pages/splash_screen.dart';

import 'app_routes.dart';

class AppPages {
  late final GoRouter goRouter = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => HealthSplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => Dashboard(),
      ),
      GoRoute(
        path: AppRoutes.permissionPage,
        builder: (context, state) => PermissionsScreen(),
      ),
    ],
  );
}
