import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cconnect/data/models/event.dart';
import 'package:cconnect/data/repositories/interfaces/ievent.dart';
import 'package:cconnect/utils/http/cloudinary_service.dart';

class EventRepository implements IEventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinary = CloudinaryService();
  final String _collectionName = 'events';

  @override
  Future<void> createEvent(Event event) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(event.id)
          .set(event.toJson());
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  @override
  Stream<List<Event>> getActiveEvents() {
    try {
      return _firestore
          .collection(_collectionName)
          .where('endTime', isGreaterThan: DateTime.now().toIso8601String())
          .orderBy('endTime', descending: false)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => Event.fromJson({...doc.data(), 'id': doc.id}))
                .where((event) => !event.isExpired)
                .toList();
          });
    } catch (e) {
      throw Exception('Failed to get events: $e');
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  @override
  Future<String?> uploadImage(String imagePath) async {
    try {
      return await _cloudinary.uploadImageFromPath(
        imagePath,
        (uploading) {},
        (error) => throw Exception(error),
      );
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  @override
  Future<void> deleteExpiredEvents() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('endTime', isLessThan: DateTime.now().toIso8601String())
          .get();

      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete expired events: $e');
    }
  }
}
