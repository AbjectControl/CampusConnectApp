import 'package:cconnect/data/models/lost_found_item.dart';
import 'package:cconnect/data/repositories/interfaces/ilost_found.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class LostFoundProvider extends ChangeNotifier {
  final ILostFoundRepository _repository;

  LostFoundProvider({required ILostFoundRepository repository})
    : _repository = repository;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get stream of all lost and found items
  Stream<List<LostFoundItem>> getLostFoundItems() {
    return _repository.getRecentLostFoundItems();
  }

  /// Get a specific item by ID
  Future<LostFoundItem?> getItemById(String id) async {
    return await _repository.getLostFoundItemById(id);
  }

  /// Report a lost item
  Future<void> reportLostItem({
    required String title,
    required String description,
    required String location,
    required String contactInfo,
    required String userId,
  }) async {
    await _reportItem(
      title: title,
      description: description,
      location: location,
      contactInfo: contactInfo,
      userId: userId,
      type: LostFoundType.lost,
    );
  }

  /// Report a found item
  Future<void> reportFoundItem({
    required String title,
    required String description,
    required String location,
    required String contactInfo,
    required String userId,
  }) async {
    await _reportItem(
      title: title,
      description: description,
      location: location,
      contactInfo: contactInfo,
      userId: userId,
      type: LostFoundType.found,
    );
  }

  /// Internal method to report an item
  Future<void> _reportItem({
    required String title,
    required String description,
    required String location,
    required String contactInfo,
    required String userId,
    required LostFoundType type,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final itemId = const Uuid().v4();

      final item = LostFoundItem(
        id: itemId,
        title: title,
        description: description,
        type: type,
        location: location,
        imageUrl: null, // No image support
        contactInfo: contactInfo,
        reportedBy: userId,
      );

      await _repository.createLostFoundItem(item);
    } catch (e) {
      _setError('Failed to report item: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Mark an item as resolved
  Future<void> markAsResolved(String itemId) async {
    _setLoading(true);
    _clearError();

    try {
      final item = await _repository.getLostFoundItemById(itemId);
      if (item == null) {
        throw Exception('Item not found');
      }

      final updatedItem = item.copyWith(status: LostFoundStatus.resolved);
      await _repository.updateLostFoundItem(updatedItem);
    } catch (e) {
      _setError('Failed to update item: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete an item
  Future<void> deleteItem(String itemId) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.deleteLostFoundItem(itemId);
    } catch (e) {
      _setError('Failed to delete item: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  @override
  void dispose() {
    // Clean up if needed
    super.dispose();
  }
}
