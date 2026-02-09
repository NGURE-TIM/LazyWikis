import 'package:lazywikis/data/models/guide.dart';
import 'package:lazywikis/data/services/local_storage_service.dart';
import 'package:lazywikis/utils/exceptions.dart';

class GuideRepository {
  final LocalStorageService _storage;

  GuideRepository(this._storage);

  Future<List<Guide>> getAllGuides() async {
    try {
      return await _storage.getAllGuides();
    } catch (e) {
      throw StorageException('Failed to fetch guides', e);
    }
  }

  Future<Guide?> getGuide(String id) async {
    try {
      return await _storage.getGuide(id);
    } catch (e) {
      throw StorageException('Failed to fetch guide: $id', e);
    }
  }

  Future<void> saveGuide(Guide guide) async {
    try {
      // Logic could include validation or data transformation in the future
      await _storage.saveGuide(guide);
    } catch (e) {
      throw StorageException('Failed to save guide', e);
    }
  }

  Future<void> deleteGuide(String id) async {
    try {
      await _storage.deleteGuide(id);
    } catch (e) {
      throw StorageException('Failed to delete guide: $id', e);
    }
  }
}
