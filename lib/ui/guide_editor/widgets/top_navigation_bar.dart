import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lazywikis/ui/guide_editor/guide_editor_viewmodel.dart';
import 'package:lazywikis/ui/shared/app_button.dart';
import 'package:provider/provider.dart';

/// Optimized version that uses internal selectors to minimize rebuilds
class TopNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  final ValueChanged<String> onTitleChanged;
  final VoidCallback onSave;
  final VoidCallback? onBack;
  final VoidCallback? onDownload;

  const TopNavigationBar({
    super.key,
    required this.onTitleChanged,
    required this.onSave,
    this.onBack,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBack ?? () => context.pop(),
      ),
      titleSpacing: 0,
      title: _TitleField(onTitleChanged: onTitleChanged),
      actions: [
        _StatusIndicator(),
        const SizedBox(width: 8),
        _SaveButton(onSave: onSave),
        const VerticalDivider(indent: 12, endIndent: 12),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: AppButton(
            label: 'Download',
            icon: Icons.download_outlined,
            type: AppButtonType.secondary,
            onPressed: onDownload,
          ),
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}

/// Rebuilds ONLY when title changes
class _TitleField extends StatelessWidget {
  final ValueChanged<String> onTitleChanged;

  const _TitleField({required this.onTitleChanged});

  @override
  Widget build(BuildContext context) {
    final title = context.select<GuideEditorViewModel, String>(
      (vm) => vm.guide?.title ?? '',
    );

    return SizedBox(
      height: 40,
      child: TextField(
        controller: TextEditingController(text: title)
          ..selection = TextSelection.collapsed(offset: title.length),
        onChanged: onTitleChanged,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          hintText: 'Guide Title',
        ),
      ),
    );
  }
}

/// Rebuilds ONLY when isDirty changes
class _StatusIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDirty = context.select<GuideEditorViewModel, bool>(
      (vm) => vm.isDirty,
    );

    if (!isDirty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        'Unsaved changes',
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontSize: 12,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

/// Rebuilds ONLY when isSaving changes
class _SaveButton extends StatelessWidget {
  final VoidCallback onSave;

  const _SaveButton({required this.onSave});

  @override
  Widget build(BuildContext context) {
    final isSaving = context.select<GuideEditorViewModel, bool>(
      (vm) => vm.isSaving,
    );

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: AppButton(
        label: 'Save',
        icon: Icons.save_outlined,
        type: AppButtonType.text,
        isLoading: isSaving,
        onPressed: onSave,
      ),
    );
  }
}