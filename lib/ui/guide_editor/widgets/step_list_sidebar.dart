import 'package:flutter/material.dart' hide Step;
import 'package:lazywikis/data/models/step.dart';
import 'package:lazywikis/ui/guide_editor/guide_editor_viewmodel.dart';
import 'package:provider/provider.dart';

/// Optimized version that uses internal selectors to minimize rebuilds
class StepListSidebar extends StatelessWidget {
  final ValueChanged<String> onStepSelected;
  final VoidCallback onIntroSelected;
  final ReorderCallback onReorder;
  final Function(StepType) onAddStep;
  final ValueChanged<String> onDeleteStep;
  final ValueChanged<String> onIndentStep;
  final ValueChanged<String> onOutdentStep;

  const StepListSidebar({
    super.key,
    required this.onStepSelected,
    required this.onIntroSelected,
    required this.onReorder,
    required this.onAddStep,
    required this.onDeleteStep,
    required this.onIndentStep,
    required this.onOutdentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        children: [
          // Header - never rebuilds
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  'Structure',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Introduction - rebuilds only when intro changes or selection changes
          _IntroductionItem(onIntroSelected: onIntroSelected),

          const Divider(height: 1),

          // Steps list - rebuilds only when steps change
          Expanded(
            child: _StepsList(
              onStepSelected: onStepSelected,
              onReorder: onReorder,
              onDeleteStep: onDeleteStep,
              onIndentStep: onIndentStep,
              onOutdentStep: onOutdentStep,
            ),
          ),

          const Divider(height: 1),

          // Add buttons - never rebuilds
          _AddStepButtons(onAddStep: onAddStep),
        ],
      ),
    );
  }
}

/// Rebuilds ONLY when intro or intro selection changes
class _IntroductionItem extends StatelessWidget {
  final VoidCallback onIntroSelected;

  const _IntroductionItem({required this.onIntroSelected});

  @override
  Widget build(BuildContext context) {
    // Single selector for both intro and selection
    final introData = context.select<GuideEditorViewModel, ({Step? intro, bool isSelected})>(
      (vm) {
        final intro = vm.guide?.introduction;
        final isSelected = intro != null && vm.selection is IntroSelected;
        return (intro: intro, isSelected: isSelected);
      },
    );

    if (introData.intro == null) return const SizedBox.shrink();

    return ListTile(
      title: const Text(
        'Introduction',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      leading: const Icon(Icons.info_outline, size: 20),
      selected: introData.isSelected,
      selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      onTap: onIntroSelected,
      dense: true,
    );
  }
}

/// Rebuilds ONLY when steps list changes
class _StepsList extends StatelessWidget {
  final ValueChanged<String> onStepSelected;
  final ReorderCallback onReorder;
  final ValueChanged<String> onDeleteStep;
  final ValueChanged<String> onIndentStep;
  final ValueChanged<String> onOutdentStep;

  const _StepsList({
    required this.onStepSelected,
    required this.onReorder,
    required this.onDeleteStep,
    required this.onIndentStep,
    required this.onOutdentStep,
  });

  @override
  Widget build(BuildContext context) {
    final steps = context.select<GuideEditorViewModel, List<Step>>(
      (vm) => vm.steps,
    );

    if (steps.isEmpty) {
      return Center(
        child: Text(
          'No steps yet',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    return ReorderableListView.builder(
      itemCount: steps.length,
      onReorder: onReorder,
      itemBuilder: (context, index) {
        final step = steps[index];
        
        // Each item rebuilds independently when its selection changes
        return _StepItem(
          key: ValueKey(step.id),
          step: step,
          index: index,
          onTap: () => onStepSelected(step.id),
          onDelete: () => onDeleteStep(step.id),
          onIndent: () => onIndentStep(step.id),
          onOutdent: () => onOutdentStep(step.id),
        );
      },
    );
  }
}

/// Individual step item - rebuilds ONLY when this specific step's selection changes
class _StepItem extends StatelessWidget {
  final Step step;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onIndent;
  final VoidCallback onOutdent;

  const _StepItem({
    super.key,
    required this.step,
    required this.index,
    required this.onTap,
    required this.onDelete,
    required this.onIndent,
    required this.onOutdent,
  });

  @override
  Widget build(BuildContext context) {
    // Only rebuild THIS item when its selection changes
    final isSelected = context.select<GuideEditorViewModel, bool>(
      (vm) => vm.selection is StepSelected && 
              (vm.selection as StepSelected).stepId == step.id,
    );

    final level = step.level ?? 0;

    return Container(
      decoration: BoxDecoration(
        border: isSelected
            ? Border(
                left: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3,
                ),
              )
            : null,
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 8.0 + (level * 24.0)),
        child: Row(
          children: [
            // Order number / Drag Handle
            ReorderableDragStartListener(
              index: index,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 12.0,
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title.isEmpty ? 'Untitled Step' : step.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: (isSelected || step.isBold)
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 13,
                          color: step.titleColor != null
                              ? Color(
                                  int.parse(
                                    step.titleColor!.replaceFirst('#', '0xFF'),
                                  ),
                                )
                              : null,
                        ),
                      ),
                      if (step.description != null &&
                          step.description!.isNotEmpty)
                        Text(
                          'Text',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                fontSize: 9,
                                color: Colors.grey,
                              ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_horiz,
                size: 16,
                color: Colors.grey,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
              onSelected: (value) {
                switch (value) {
                  case 'indent':
                    onIndent();
                    break;
                  case 'outdent':
                    onOutdent();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'indent',
                  child: Row(
                    children: [
                      Icon(Icons.chevron_right, size: 18),
                      SizedBox(width: 8),
                      Text('Indent'),
                    ],
                  ),
                ),
                if (level > 0)
                  const PopupMenuItem(
                    value: 'outdent',
                    child: Row(
                      children: [
                        Icon(Icons.chevron_left, size: 18),
                        SizedBox(width: 8),
                        Text('Outdent'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Add buttons - static, never rebuilds
class _AddStepButtons extends StatelessWidget {
  final Function(StepType) onAddStep;

  const _AddStepButtons({required this.onAddStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Add Step:',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAddButton(
                context,
                Icons.text_fields,
                'Text Step',
                StepType.textOnly,
              ),
              const SizedBox(width: 8),
              _buildAddButton(
                context,
                Icons.terminal,
                'Cmd Step',
                StepType.command,
              ),
              const SizedBox(width: 8),
              _buildAddButton(
                context,
                Icons.image,
                'Img Step',
                StepType.screenshot,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(
    BuildContext context,
    IconData icon,
    String label,
    StepType type,
  ) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onAddStep(type),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(fontSize: 10),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}