import 'package:cconnect/data/models/lost_found_item.dart';

abstract class ILostFoundRepository {
  /// Create a new lost or found item report
  Future<void> createLostFoundItem(LostFoundItem item);

  /// Get a stream of all recent lost and found items
  Stream<List<LostFoundItem>> getRecentLostFoundItems();

  /// Get a specific lost/found item by ID
  Future<LostFoundItem?> getLostFoundItemById(String id);

  /// Update an existing lost/found item (e.g., mark as resolved)
  Future<void> updateLostFoundItem(LostFoundItem item);

  /// Delete a lost/found item
  Future<void> deleteLostFoundItem(String id);

  /// Upload an image for a lost/found item and return the URL
  Future<String?> uploadImage(String itemId, String imagePath);
}
