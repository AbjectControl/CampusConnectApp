import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cconnect/data/models/friendshipModel.dart';
import 'package:uuid/uuid.dart';

class FriendshipRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'friendships';

  Future<void> sendFriendRequest(String requesterId, String recipientId) async {
    final id = const Uuid().v4();
    final friendship = Friendship(
      id: id,
      requesterId: requesterId,
      recipientId: recipientId,
      accepted: false,
    );
    await _db.collection(_collection).doc(id).set(friendship.toJson());
  }

  Future<void> acceptFriendRequest(String friendshipId) async {
    await _db.collection(_collection).doc(friendshipId).update({'accepted': true});
  }

  Future<void> rejectFriendRequest(String friendshipId) async {
    await _db.collection(_collection).doc(friendshipId).delete();
  }

  Future<void> unfriend(String userId1, String userId2) async {
    final friendship = await getFriendship(userId1, userId2);
    if (friendship != null) {
      await _db.collection(_collection).doc(friendship.id).delete();
    }
  }

  Future<Friendship?> getFriendship(String userId1, String userId2) async {
    // Check if userId1 requested userId2
    final query1 = await _db
        .collection(_collection)
        .where('requesterId', isEqualTo: userId1)
        .where('recipientId', isEqualTo: userId2)
        .get();

    if (query1.docs.isNotEmpty) {
      return Friendship.fromJson(query1.docs.first.data());
    }

    // Check if userId2 requested userId1
    final query2 = await _db
        .collection(_collection)
        .where('requesterId', isEqualTo: userId2)
        .where('recipientId', isEqualTo: userId1)
        .get();

    if (query2.docs.isNotEmpty) {
      return Friendship.fromJson(query2.docs.first.data());
    }

    return null;
  }
}
