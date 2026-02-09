import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lazywikis/data/models/guide.dart';
import 'package:lazywikis/routing/route_names.dart';
import 'package:lazywikis/ui/dashboard/dashboard_viewmodel.dart';
import 'package:lazywikis/ui/dashboard/widgets/empty_state.dart';
import 'package:lazywikis/ui/dashboard/widgets/guide_card.dart';
import 'package:lazywikis/ui/shared/error_banner.dart';
import 'package:lazywikis/ui/shared/loading_indicator.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static final RouteObserver<ModalRoute<void>> routeObserver =
      RouteObserver<ModalRoute<void>>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DashboardViewModel(context.read()),
      child: const _DashboardContent(),
    );
  }
}

class _DashboardContent extends StatefulWidget {
  const _DashboardContent();

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      DashboardScreen.routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().loadGuides();
    });
  }

  @override
  void dispose() {
    DashboardScreen.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.auto_stories,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            const Text('LazyWikis'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: FilledButton.icon(
              onPressed: () => viewModel.createGuide(context),
              icon: const Icon(Icons.add),
              label: const Text('New Guide'),
            ),
          ),
        ],
      ),
      body: _buildBody(context, viewModel),
    );
  }

  Widget _buildBody(BuildContext context, DashboardViewModel viewModel) {
    if (viewModel.isLoading && viewModel.guides.isEmpty) {
      return const LoadingIndicator(message: 'Loading guides...');
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ErrorBanner(
              message: viewModel.errorMessage!,
              onRetry: viewModel.loadGuides,
            ),
          ),
        ),
      );
    }

    if (viewModel.guides.isEmpty) {
      return EmptyState(onCreate: () => viewModel.createGuide(context));
    }

    return RefreshIndicator(
      onRefresh: viewModel.loadGuides,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: GridView.builder(
              itemCount: viewModel.guides.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 350,
                childAspectRatio: 1.5,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
              ),
              itemBuilder: (context, index) {
                final guide = viewModel.guides[index];
                return GuideCard(
                  guide: guide,
                  onTap: () =>
                      context.push(RouteNames.editGuideWithId(guide.id)),
                  onDelete: () => _confirmDelete(context, viewModel, guide),
                  onDuplicate: () => viewModel.duplicateGuide(guide, context),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    DashboardViewModel viewModel,
    Guide guide,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Guide?'),
        content: Text(
          'Are you sure you want to delete "${guide.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await viewModel.deleteGuide(guide.id);
    }
  }
}
