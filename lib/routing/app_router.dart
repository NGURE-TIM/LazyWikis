import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';

/// GoRouter configuration for app navigation
class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: RouteNames.dashboard,
      routes: [
        GoRoute(
          path: RouteNames.dashboard,
          builder: (context, state) => const DashboardPlaceholder(),
        ),
        GoRoute(
          path: RouteNames.newGuide,
          builder: (context, state) =>
              const GuideEditorPlaceholder(isNew: true),
        ),
        GoRoute(
          path: RouteNames.editGuide,
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return GuideEditorPlaceholder(isNew: false, guideId: id);
          },
        ),
        GoRoute(
          path: RouteNames.settings,
          builder: (context, state) => const SettingsPlaceholder(),
        ),
      ],
    );
  }
}

// Placeholder screens - will be replaced in later phases
class DashboardPlaceholder extends StatelessWidget {
  const DashboardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: const Center(child: Text('Dashboard - Coming in Phase 2')),
    );
  }
}

class GuideEditorPlaceholder extends StatelessWidget {
  final bool isNew;
  final String? guideId;

  const GuideEditorPlaceholder({super.key, required this.isNew, this.guideId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isNew ? 'New Guide' : 'Edit Guide: $guideId')),
      body: const Center(child: Text('Guide Editor - Coming in Phase 3')),
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
