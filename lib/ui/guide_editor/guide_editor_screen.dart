import 'package:flutter/material.dart' hide Step;
import 'package:lazywikis/data/models/step.dart';
import 'package:lazywikis/data/services/export_service.dart';
import 'package:lazywikis/ui/guide_editor/guide_editor_viewmodel.dart';
import 'package:lazywikis/ui/guide_editor/widgets/preview_panel.dart';
import 'package:lazywikis/ui/guide_editor/widgets/step_editor_panel.dart';
import 'package:lazywikis/ui/guide_editor/widgets/step_list_sidebar.dart';
import 'package:lazywikis/ui/guide_editor/widgets/top_navigation_bar.dart';
import 'package:lazywikis/ui/shared/error_banner.dart';
import 'package:lazywikis/ui/shared/loading_indicator.dart';
import 'package:provider/provider.dart';

class GuideEditorScreen extends StatefulWidget {
  final String? guideId;

  const GuideEditorScreen({super.key, this.guideId});

  @override
  State<GuideEditorScreen> createState() => _GuideEditorScreenState();
}

class _GuideEditorScreenState extends State<GuideEditorScreen> {
  late final GuideEditorViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    
    _viewModel = GuideEditorViewModel(
      context.read(), // GuideRepository
      context.read(), // WikiTextGenerator
    );
    
    // Load guide after first frame
    Future.microtask(() {
      if (mounted) {
        _viewModel.loadGuide(widget.guideId);
      }
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: const _GuideEditorContent(),
    );
  }
}

class _GuideEditorContent extends StatelessWidget {
  const _GuideEditorContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<GuideEditorViewModel>(
      builder: (context, viewModel, child) {
        final isLoading = viewModel.isLoading;
        final hasGuide = viewModel.guide != null;
        final errorMessage = viewModel.errorMessage;

        // Loading State - show spinner
        if (isLoading) {
          return const Scaffold(
            body: LoadingIndicator(message: 'Loading guide...'),
          );
        }

        // Error State - only show if we have an error AND no guide
        if (errorMessage != null && !hasGuide) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const _ErrorView(),
          );
        }

        // Success State - Editor (show even if there's a transient error)
        return const Scaffold(
          appBar: _EditorAppBar(),
          body: Column(
            children: [
              // Error banner at top if there's an error
              _ErrorBannerWidget(),
              // Main editor content
              Expanded(child: _EditorBody()),
            ],
          ),
        );
      },
    );
  }
}

class _ErrorBannerWidget extends StatelessWidget {
  const _ErrorBannerWidget();

  @override
  Widget build(BuildContext context) {
    final errorMessage = context.select<GuideEditorViewModel, String?>(
      (vm) => vm.errorMessage,
    );

    if (errorMessage == null) return const SizedBox.shrink();

    return Material(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                errorMessage,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              color: Theme.of(context).colorScheme.onErrorContainer,
              onPressed: () {
                context.read<GuideEditorViewModel>().clearError();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView();

  @override
  Widget build(BuildContext context) {
    final errorMessage = context.select<GuideEditorViewModel, String?>(
      (vm) => vm.errorMessage,
    );

    return Center(
      child: ErrorBanner(
        message: errorMessage ?? 'An unexpected error occurred',
        onRetry: () {
          final vm = context.read<GuideEditorViewModel>();
          vm.loadGuide(vm.guide?.id);
        },
      ),
    );
  }
}

class _EditorBody extends StatelessWidget {
  const _EditorBody();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left: Step List
        _StepListSection(),
        
        // Center: Step Editor
        Expanded(
          flex: 2,
          child: _StepEditorSection(),
        ),
        
        // Right: Preview
        _PreviewSection(),
      ],
    );
  }
}

// ============================================================================
// OPTIMIZED: Step List Section - widget handles its own selectors internally
// ============================================================================

class _StepListSection extends StatelessWidget {
  const _StepListSection();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<GuideEditorViewModel>();
    
    // Widget handles its own selectors internally for optimal rebuilds
    return StepListSidebar(
      onStepSelected: viewModel.selectStep,
      onIntroSelected: viewModel.selectIntro,
      onReorder: viewModel.reorderSteps,
      onAddStep: viewModel.addStep,
      onDeleteStep: viewModel.deleteStep,
      onIndentStep: viewModel.indentStep,
      onOutdentStep: viewModel.outdentStep,
    );
  }
}

// ============================================================================
// OPTIMIZED: Step Editor with minimal rebuilds and key stability
// ============================================================================

class _StepEditorSection extends StatelessWidget {
  const _StepEditorSection();

  @override
  Widget build(BuildContext context) {
    // Use a more efficient selector that includes step ID for key stability
    final stepData = context.select<GuideEditorViewModel, ({Step? step, String? id})?>(
      (vm) {
        final step = vm.selectedStep;
        return step != null ? (step: step, id: step.id) : null;
      },
    );

    if (stepData == null) {
      return const Center(
        child: Text('Select a step to edit'),
      );
    }

    return StepEditorPanel(
      key: ValueKey(stepData.id), // Preserve widget state when switching steps
      step: stepData.step,
      onUpdate: context.read<GuideEditorViewModel>().updateStep,
    );
  }
}

// ============================================================================
// OPTIMIZED: Preview with key to prevent unnecessary internal rebuilds
// ============================================================================

class _PreviewSection extends StatelessWidget {
  const _PreviewSection();

  @override
  Widget build(BuildContext context) {
    final wikiText = context.select<GuideEditorViewModel, String>(
      (vm) => vm.wikiText,
    );

    // Use key to prevent unnecessary internal rebuilds
    return PreviewPanel(
      key: ValueKey(wikiText.hashCode),
      wikiText: wikiText,
    );
  }
}

// ============================================================================
// OPTIMIZED: App Bar - widget handles its own selectors internally
// ============================================================================

class _EditorAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _EditorAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<GuideEditorViewModel>();
    
    // Widget handles its own selectors internally for optimal rebuilds
    return TopNavigationBar(
      onTitleChanged: viewModel.updateTitle,
      onSave: viewModel.save,
      onDownload: () => _ExportDialog.show(context, viewModel),
      onBack: () => _handleBack(context, viewModel),
    );
  }

  Future<void> _handleBack(
    BuildContext context,
    GuideEditorViewModel viewModel,
  ) async {
    if (!viewModel.isDirty) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      return;
    }

    // Save before navigating
    final saved = await viewModel.save();
    
    if (!saved) {
      // Save failed, show error and don't navigate
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              viewModel.errorMessage ?? 'Failed to save',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () async {
                final retried = await viewModel.save();
                if (retried && context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
        );
      }
      return;
    }

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}

// ============================================================================
// Export Dialog (unchanged)
// ============================================================================

class _ExportDialog {
  static void show(BuildContext context, GuideEditorViewModel viewModel) {
    if (viewModel.guide == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export Guide'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose export format:'),
            SizedBox(height: 16),
            Text('• WikiText: Plain text file for manual copy-paste.'),
            Text('• Bundle: ZIP archive with text and all images.'),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _exportWikiText(context, viewModel);
            },
            child: const Text('WikiText (.txt)'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _exportZip(context, viewModel);
            },
            child: const Text('Bundle (.zip)'),
          ),
        ],
      ),
    );
  }

  static void _exportWikiText(
    BuildContext context,
    GuideEditorViewModel viewModel,
  ) {
    final guide = viewModel.guide;
    if (guide == null) return;
    
    try {
      ExportService().exportWikiText(guide);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Downloading WikiText...'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  static void _exportZip(
    BuildContext context,
    GuideEditorViewModel viewModel,
  ) {
    final guide = viewModel.guide;
    if (guide == null) return;
    
    try {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Generating ZIP bundle...'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      ExportService().exportZip(guide);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}