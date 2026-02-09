import 'package:flutter/material.dart';

enum AppButtonType { primary, secondary, danger, text }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final IconData? icon;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // If loading, show disabled button with spinner
    if (isLoading) {
      return ElevatedButton(
        onPressed: null,
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
          ),
        ),
      );
    }

    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon ?? Icons.check, size: 18),
          label: Text(label),
        );

      case AppButtonType.secondary:
        return OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon ?? Icons.arrow_right_alt, size: 18),
          label: Text(label),
        );

      case AppButtonType.danger:
        return ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          icon: Icon(icon ?? Icons.delete_outline, size: 18),
          label: Text(label),
        );

      case AppButtonType.text:
        return TextButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          label: Text(label),
        );
    }
  }
}
