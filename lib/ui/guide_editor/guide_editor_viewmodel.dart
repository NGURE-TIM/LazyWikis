import 'dart:async';
import 'package:flutter/material.dart' hide Step;
import 'package:lazywikis/data/models/guide.dart';
import 'package:lazywikis/data/models/step.dart';
import 'package:lazywikis/data/repositories/guide_repository.dart';
import 'package:lazywikis/data/services/wikitext_generator.dart';

/// Represents what is currently selected in the editor
sealed class EditorSelection {
  const EditorSelection();
}

class IntroSelected extends EditorSelection {
  const IntroSelected();
  
  @override
  bool operator ==(Object other) => other is IntroSelected;
  
  @override
  int get hashCode => 0;
}

class StepSelected extends EditorSelection {
  final String stepId;
  
  const StepSelected(this.stepId);
  
  @override
  bool operator ==(Object other) =>
      other is StepSelected && other.stepId == stepId;
  
  @override
  int get hashCode => stepId.hashCode;
}

class NothingSelected extends EditorSelection {
  const NothingSelected();
  
  @override
  bool operator ==(Object other) => other is NothingSelected;
  
  @override
  int get hashCode => 1;
}

/// Immutable state container for the editor
class EditorState {
  final Guide? guide;
  final EditorSelection selection;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final bool isDirty;
  final String cachedWikiText;
  
  const EditorState({
    this.guide,
    this.selection = const NothingSelected(),
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.isDirty = false,
    this.cachedWikiText = '',
  });
  
  EditorState copyWith({
    Guide? guide,
    EditorSelection? selection,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool? isDirty,
    String? cachedWikiText,
    bool clearError = false,
  }) {
    return EditorState(
      guide: guide ?? this.guide,
      selection: selection ?? this.selection,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isDirty: isDirty ?? this.isDirty,
      cachedWikiText: cachedWikiText ?? this.cachedWikiText,
    );
  }
  
  // Computed properties
  List<Step> get steps => guide?.steps ?? [];
  
  Step? get selectedStep {
    if (guide == null) return null;
    
    return switch (selection) {
      IntroSelected() => guide!.introduction,
      StepSelected(:final stepId) => steps.cast<Step?>().firstWhere(
          (s) => s?.id == stepId,
          orElse: () => null,
        ),
      NothingSelected() => null,
    };
  }
}

class GuideEditorViewModel extends ChangeNotifier {
  final GuideRepository _repository;
  final WikiTextGenerator _generator;
  
  // Start in loading state to prevent error flash
  EditorState _state = const EditorState(isLoading: true);
  Timer? _autoSaveTimer;
  Timer? _debounceTimer;
  
  // Public getters
  EditorState get state => _state;
  Guide? get guide => _state.guide;
  List<Step> get steps => _state.steps;
  Step? get selectedStep => _state.selectedStep;
  EditorSelection get selection => _state.selection;
  bool get isLoading => _state.isLoading;
  bool get isSaving => _state.isSaving;
  String? get errorMessage => _state.errorMessage;
  bool get isDirty => _state.isDirty;
  String get wikiText => _state.cachedWikiText;
  
  GuideEditorViewModel(this._repository, this._generator);
  
  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }
  
  // --- Initialization ---
  
  Future<void> loadGuide(String? id) async {
    _updateState(_state.copyWith(isLoading: true, clearError: true));
    
    try {
      Guide loadedGuide;
      bool markDirty = false;
      
      if (id != null) {
        final existingGuide = await _repository.getGuide(id);
        if (existingGuide == null) {
          throw Exception('Guide not found');
        }
        loadedGuide = existingGuide;
      } else {
        // Create new guide
        loadedGuide = Guide.create();
        //markDirty = true;
      }
      
      // Ensure introduction exists
      if (loadedGuide.introduction == null) {
        loadedGuide = loadedGuide.copyWith(
          introduction: Step.create(StepType.full, -1).copyWith(
            title: 'Introduction',
          ),
        );
        //  markDirty = true;
      }
      
      // Determine initial selection
      final initialSelection = _determineInitialSelection(loadedGuide);
      
      // Generate initial wiki text
      final wikiText = _generator.generate(loadedGuide);
      
      _updateState(
        EditorState(
          guide: loadedGuide,
          selection: initialSelection,
          isDirty: markDirty,
          cachedWikiText: wikiText,
        ),
      );
      
      // Start auto-save for new guides
//      if (markDirty) {
//        _scheduleAutoSave();
//      }
    } catch (e) {
      _updateState(
        _state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load guide: $e',
        ),
      );
    }
  }
  
  EditorSelection _determineInitialSelection(Guide guide) {
    if (guide.steps.isNotEmpty) {
      return StepSelected(guide.steps.first.id);
    } else if (guide.introduction != null) {
      return const IntroSelected();
    }
    return const NothingSelected();
  }
  
  // --- Step Management ---
  
  void addStep(StepType type) {
    if (_state.guide == null) return;
    
    final newOrder = _state.steps.length;
    final newStep = Step.create(type, newOrder);
    
    final updatedGuide = _state.guide!.copyWith(
      steps: [..._state.steps, newStep],
    );
    
    _applyGuideUpdate(
      updatedGuide,
      newSelection: StepSelected(newStep.id),
    );
  }
  
  void updateStep(Step updatedStep) {
    if (_state.guide == null) return;
    
    // Check if updating intro
    if (_state.guide!.introduction?.id == updatedStep.id) {
      _applyGuideUpdate(
        _state.guide!.copyWith(introduction: updatedStep),
      );
      return;
    }
    
    final index = _state.steps.indexWhere((s) => s.id == updatedStep.id);
    if (index == -1) return;
    
    final updatedSteps = List<Step>.from(_state.steps);
    updatedSteps[index] = updatedStep;
    
    _applyGuideUpdate(
      _state.guide!.copyWith(steps: updatedSteps),
    );
  }
  
  void deleteStep(String stepId) {
    if (_state.guide == null) return;
    
    // Prevent deleting intro
    if (_state.guide!.introduction?.id == stepId) {
      _showError('Cannot delete introduction');
      return;
    }
    
    final updatedSteps = _state.steps
        .where((s) => s.id != stepId)
        .toList()
        .asMap()
        .entries
        .map((entry) => entry.value.copyWith(order: entry.key))
        .toList();
    
    // Determine new selection
    EditorSelection newSelection = _state.selection;
    if (_state.selection is StepSelected &&
        ((_state.selection as StepSelected).stepId == stepId)) {
      if (updatedSteps.isNotEmpty) {
        newSelection = StepSelected(updatedSteps.first.id);
      } else if (_state.guide!.introduction != null) {
        newSelection = const IntroSelected();
      } else {
        newSelection = const NothingSelected();
      }
    }
    
    _applyGuideUpdate(
      _state.guide!.copyWith(steps: updatedSteps),
      newSelection: newSelection,
    );
  }
  
  void reorderSteps(int oldIndex, int newIndex) {
    if (_state.guide == null) return;
    
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    final steps = List<Step>.from(_state.steps);
    final item = steps.removeAt(oldIndex);
    steps.insert(newIndex, item);
    
    // Update order
    for (var i = 0; i < steps.length; i++) {
      steps[i] = steps[i].copyWith(order: i);
    }
    
    _applyGuideUpdate(_state.guide!.copyWith(steps: steps));
  }
  
  void indentStep(String stepId) {
    final step = _state.steps.cast<Step?>().firstWhere(
      (s) => s?.id == stepId,
      orElse: () => null,
    );
    
    if (step == null) return;
    
    final currentLevel = step.level ?? 0;
    if (currentLevel < 2) {
      updateStep(step.copyWith(level: currentLevel + 1));
    }
  }
  
  void outdentStep(String stepId) {
    final step = _state.steps.cast<Step?>().firstWhere(
      (s) => s?.id == stepId,
      orElse: () => null,
    );
    
    if (step == null) return;
    
    final currentLevel = step.level ?? 0;
    if (currentLevel > 0) {
      updateStep(step.copyWith(level: currentLevel - 1));
    }
  }
  
  // --- Selection ---
  
  void selectStep(String stepId) {
    _updateState(_state.copyWith(selection: StepSelected(stepId)));
  }
  
  void selectIntro() {
    if (_state.guide?.introduction != null) {
      _updateState(_state.copyWith(selection: const IntroSelected()));
    }
  }
  
  // --- Guide Metadata ---
  
  void updateTitle(String title) {
    if (_state.guide == null) return;
    _applyGuideUpdate(_state.guide!.copyWith(title: title));
  }
  
  // --- Persistence ---
  
  Future<bool> save() async {
    if (_state.guide == null || !_state.isDirty) {
      return true; // Nothing to save
    }
    
    _updateState(_state.copyWith(isSaving: true, clearError: true));
    
    try {
      await _repository.saveGuide(_state.guide!);
      _updateState(
        _state.copyWith(
          isSaving: false,
          isDirty: false,
        ),
      );
      _autoSaveTimer?.cancel(); // Cancel auto-save after manual save
      return true;
    } catch (e) {
      _updateState(
        _state.copyWith(
          isSaving: false,
          errorMessage: 'Failed to save: $e',
        ),
      );
      return false;
    }
  }
  
  Future<bool> saveIfDirty() async {
    if (_state.isDirty) {
      return await save();
    }
    return true;
  }
  
  // --- Private Helpers ---
  
  void _applyGuideUpdate(Guide updatedGuide, {EditorSelection? newSelection}) {
    final wikiText = _generator.generate(updatedGuide);
    
    _updateState(
      _state.copyWith(
        guide: updatedGuide,
        selection: newSelection,
        isDirty: true,
        cachedWikiText: wikiText,
      ),
    );
    
    // Debounced auto-save
    _scheduleAutoSave();
  }
  
  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 3), () {
      if (_state.isDirty && !_state.isSaving) {
        save();
      }
    });
  }
  
  void _updateState(EditorState newState) {
    _state = newState;
    notifyListeners();
  }
  
  void _showError(String message) {
    _updateState(_state.copyWith(errorMessage: message));
    
    // Auto-clear error after 5 seconds (increased for better UX)
    Future.delayed(const Duration(seconds: 5), () {
      // Only clear if the error message hasn't changed
      if (_state.errorMessage == message) {
        _updateState(_state.copyWith(clearError: true));
      }
    });
  }
  
  void clearError() {
    _updateState(_state.copyWith(clearError: true));
  }
}