import 'package:flutter/material.dart';

class UnknownGuide {
  static const String assetImage =
      'assets/images/empty_docs.png'; // Placeholder
}

class EmptyState extends StatelessWidget {
  final VoidCallback onCreate;

  const EmptyState({super.key, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    // Using a simple icon based empty state for now to avoid asset dependency issues
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.note_add_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No guides yet',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Create your first installation guide to get started',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create New Guide'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              elevation: 4,
              shadowColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
