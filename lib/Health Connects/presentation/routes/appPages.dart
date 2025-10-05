import 'package:go_router/go_router.dart';

import 'appRoutes.dart';

class AppPages {
  late final GoRouter goRouter = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [],
  );
}
