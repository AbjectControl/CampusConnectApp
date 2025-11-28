import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cconnect/data/models/friendshipModel.dart';
import 'package:uuid/uuid.dart';

import 'package:cconnect/data/repositories/interfaces/ifriendship.dart';

class FriendshipRepository implements IFriendshipRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'friendships';

  @override
  Future<Friendship> sendRequest(String requesterId, String recipientId) async {
    final id = const Uuid().v4();
    final friendship = Friendship(
      id: id,
      requesterId: requesterId,
      recipientId: recipientId,
      accepted: false,
    );
    await _db.collection(_collection).doc(id).set(friendship.toJson());
    return friendship;
  }

  @override
  Future<void> respondToRequest(String friendshipId, bool accept) async {
    if (accept) {
      await _db.collection(_collection).doc(friendshipId).update({'accepted': true});
    } else {
      await _db.collection(_collection).doc(friendshipId).delete();
    }
  }

  @override
  Future<List<Friendship>> listFriends(String userId) async {
    // This method was missing in the implementation but present in interface
    // Implementing basic version
    final query1 = await _db.collection(_collection)
        .where('requesterId', isEqualTo: userId)
        .where('accepted', isEqualTo: true)
        .get();
        
    final query2 = await _db.collection(_collection)
        .where('recipientId', isEqualTo: userId)
        .where('accepted', isEqualTo: true)
        .get();

    final friends = <Friendship>[];
    for (var doc in query1.docs) friends.add(Friendship.fromJson(doc.data()));
    for (var doc in query2.docs) friends.add(Friendship.fromJson(doc.data()));
    
    return friends;
  }

  // Additional methods not in interface but used in app
  Future<void> sendFriendRequest(String requesterId, String recipientId) async {
    await sendRequest(requesterId, recipientId);
  }

  Future<void> acceptFriendRequest(String friendshipId) async {
    await respondToRequest(friendshipId, true);
  }

  Future<void> rejectFriendRequest(String friendshipId) async {
    await respondToRequest(friendshipId, false);
  }

  Future<void> unfriend(String friendshipId) async {
    await _db.collection(_collection).doc(friendshipId).delete();
  }

  @override
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
