import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cconnect/data/models/lost_found_item.dart';
import 'package:cconnect/data/repositories/interfaces/ilost_found.dart';
import 'package:cconnect/utils/http/cloudinary_service.dart';

class LostFoundRepository implements ILostFoundRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinary = CloudinaryService();
  final String _collectionName = 'lostFoundItems';

  @override
  Future<void> createLostFoundItem(LostFoundItem item) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(item.id)
          .set(item.toJson());
    } catch (e) {
      throw Exception('Failed to create lost/found item: $e');
    }
  }

  @override
  Stream<List<LostFoundItem>> getRecentLostFoundItems() {
    try {
      return _firestore
          .collection(_collectionName)
          .orderBy('reportedAt', descending: true)
          .limit(50)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map(
                  (doc) =>
                      LostFoundItem.fromJson({...doc.data(), 'id': doc.id}),
                )
                .toList();
          });
    } catch (e) {
      throw Exception('Failed to get lost/found items: $e');
    }
  }

  @override
  Future<LostFoundItem?> getLostFoundItemById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (!doc.exists) return null;
      return LostFoundItem.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      throw Exception('Failed to get lost/found item: $e');
    }
  }

  @override
  Future<void> updateLostFoundItem(LostFoundItem item) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(item.id)
          .update(item.toJson());
    } catch (e) {
      throw Exception('Failed to update lost/found item: $e');
    }
  }

  @override
  Future<void> deleteLostFoundItem(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete lost/found item: $e');
    }
  }

  @override
  Future<String?> uploadImage(String itemId, String imagePath) async {
    try {
      // Use Cloudinary to upload the image
      final url = await _cloudinary.uploadImageFromPath(
        imagePath,
        (uploading) {
          // Upload in progress
        },
        (error) {
          throw Exception(error);
        },
      );

      return url;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
