import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:lazywikis/data/models/guide.dart';
import 'package:lazywikis/data/repositories/guide_repository.dart';
import 'package:lazywikis/routing/route_names.dart';

class DashboardViewModel extends ChangeNotifier {
  final GuideRepository _repository;

  List<Guide> _guides = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Guide> get guides => _guides;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  DashboardViewModel(this._repository) {
    loadGuides();
  }

  Future<void> loadGuides() async {
    _setLoading(true);
    _clearError();

    try {
      _guides = await _repository.getAllGuides();
      _guides.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      _setError('Failed to load guides: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createGuide(BuildContext context) async {
    // Navigate to new guide route
    // The actual creation will happen in the editor view model
    await context.pushNamed(RouteNames.newGuide);
    await loadGuides();
  }

  Future<void> deleteGuide(String id) async {
    try {
      await _repository.deleteGuide(id);
      await loadGuides(); // Reload list
    } catch (e) {
      _setError('Failed to delete guide: $e');
    }
  }

  Future<void> duplicateGuide(Guide guide, BuildContext context) async {
    try {
      final now = DateTime.now();
      // Create a new guide with new ID
      final duplicate = Guide(
        id: const Uuid().v4(), // Generate new UUID
        title: '${guide.title} (Copy)',
        steps: List.from(guide.steps), // Deep copy of steps
        categories: List.from(guide.categories),
        metadata: guide.metadata,
        introduction: guide.introduction,
        hasTableOfContents: guide.hasTableOfContents,
        createdAt: now,
        updatedAt: now,
        status: guide.status,
      );

      await _repository.saveGuide(duplicate);
      await loadGuides(); // Reload list

      // Navigate to the duplicated guide
      if (context.mounted) {
        context.push(RouteNames.editGuideWithId(duplicate.id));
      }
    } catch (e) {
      _setError('Failed to duplicate guide: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
