import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lazywikis/ui/dashboard/dashboard_screen.dart';
import 'package:lazywikis/ui/guide_editor/guide_editor_screen.dart';
import 'route_names.dart';

/// GoRouter configuration for app navigation
class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: RouteNames.dashboard,
      routes: [
        GoRoute(
          path: RouteNames.dashboard,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: DashboardScreen()),
          name: RouteNames.dashboard,
        ),
        GoRoute(
          path: RouteNames.newGuide,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: GuideEditorScreen(guideId: null)),
          name: RouteNames.newGuide,
        ),
        GoRoute(
          path: RouteNames.editGuide,
          pageBuilder: (context, state) {
            final id = state.pathParameters['id']!;
            return NoTransitionPage(child: GuideEditorScreen(guideId: id));
          },
          name: 'edit_guide',
        ),
        GoRoute(
          path: RouteNames.settings,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SettingsPlaceholder()),
          name: RouteNames.settings,
        ),
      ],
      observers: [
    DashboardScreen.routeObserver,
  ],
    );
  }
}

class SettingsPlaceholder extends StatelessWidget {
  const SettingsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings - Coming in Phase 5')),
    );
  }
}
