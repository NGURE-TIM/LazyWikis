import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lazywikis/config/constants.dart';
import 'package:lazywikis/data/models/guide.dart';

class LocalStorageService {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get all saved guides
  Future<List<Guide>> getAllGuides() async {
    await _ensureInitialized();
    final guidesJson =
        _prefs!.getStringList(AppConstants.storageKeyGuides) ?? [];

    return guidesJson
        .map((jsonStr) => Guide.fromJson(jsonDecode(jsonStr)))
        .toList();
  }

  /// Get a single guide by ID
  Future<Guide?> getGuide(String id) async {
    final guides = await getAllGuides();
    try {
      return guides.firstWhere((g) => g.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Save or update a guide
  Future<void> saveGuide(Guide guide) async {
    await _ensureInitialized();
    final guides = await getAllGuides();

    final index = guides.indexWhere((g) => g.id == guide.id);
    if (index >= 0) {
      guides[index] = guide;
    } else {
      guides.add(guide);
    }

    await _saveGuidesList(guides);
  }

  /// Delete a guide by ID
  Future<void> deleteGuide(String id) async {
    await _ensureInitialized();
    final guides = await getAllGuides();
    guides.removeWhere((g) => g.id == id);
    await _saveGuidesList(guides);
  }

  // Private helpers
  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await init();
    }
  }

  Future<void> _saveGuidesList(List<Guide> guides) async {
    final jsonList = guides.map((g) => jsonEncode(g.toJson())).toList();
    await _prefs!.setStringList(AppConstants.storageKeyGuides, jsonList);
  }
}
