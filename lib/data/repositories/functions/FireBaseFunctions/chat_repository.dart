import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cconnect/data/models/groupCommunity.dart';
import 'package:cconnect/data/models/message.dart';
import 'package:cconnect/data/models/userModel.dart';
import 'package:cconnect/data/repositories/interfaces/ichat.dart';
import 'package:cconnect/data/repositories/interfaces/igroup.dart';
import 'package:uuid/uuid.dart';

class ChatRepository implements IChatRepository, IGroupRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- IChatRepository Implementation ---

  @override
  Future<void> sendMessage(Message message) async {
    // 1. Save Message
    await _db.collection('messages').doc(message.id).set(message.toJson());

    // 2. Update Conversation
    final conversationRef = _db
        .collection('conversations')
        .doc(message.conversationId);
    final conversationDoc = await conversationRef.get();

    if (!conversationDoc.exists) {
      // Create new conversation with denormalized user data
      List<String> participants = [];
      if (message.conversationId.contains('_')) {
        participants = message.conversationId.split('_');
      } else {
        participants = [message.senderId];
      }

      // Fetch user data for denormalization
      Map<String, Map<String, dynamic>> userData = {};
      for (String userId in participants) {
        final userDoc = await _db.collection('users').doc(userId).get();
        if (userDoc.exists) {
          final user = User.fromJson(userDoc.data()!);
          userData[userId] = {
            'displayName': user.displayName,
            'photoUrl': user.photoUrl,
          };
        }
      }

      await conversationRef.set({
        'id': message.conversationId,
        'participants': participants,
        'userData': userData, // Denormalized data
        'lastMessage': message.text,
        'lastMessageTime': message.sentAt.toIso8601String(),
        'unreadCounts': {
          for (var id in participants) id: (id == message.senderId) ? 0 : 1,
        },
        'isGroup': false,
      });
    } else {
      // Update existing conversation
      final data = conversationDoc.data() as Map<String, dynamic>;
      final unreadCounts = Map<String, dynamic>.from(
        data['unreadCounts'] ?? {},
      );
      final participants = List<String>.from(data['participants'] ?? []);

      for (var id in participants) {
        if (id != message.senderId) {
          unreadCounts[id] = (unreadCounts[id] ?? 0) + 1;
        }
      }

      await conversationRef.update({
        'lastMessage': message.text,
        'lastMessageTime': message.sentAt.toIso8601String(),
        'unreadCounts': unreadCounts,
      });
    }
  }

  @override
  Stream<List<Message>> subscribeToMessages(String conversationId) {
    return _db
        .collection('messages')
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList(),
        );
  }

  @override
  Future<List<Message>> fetchRecentMessages(
    String conversationId, {
    int limit = 50,
  }) async {
    final snapshot = await _db
        .collection('messages')
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('sentAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList();
  }

  @override
  Future<void> markRead(
    String conversationId,
    String messageId,
    String userId,
  ) async {
    final conversationRef = _db.collection('conversations').doc(conversationId);

    // Set unread count for this user to 0
    await conversationRef.update({'unreadCounts.$userId': 0});

    // If particular message provided, add user to readBy array
    if (messageId.isNotEmpty) {
      await _db.collection('messages').doc(messageId).update({
        'readBy': FieldValue.arrayUnion([userId]),
      });
    }
  }

  @override
  Future<void> markMessagesAsRead(String conversationId, String userId) async {
    // Update conversation unread count
    final conversationRef = _db.collection('conversations').doc(conversationId);
    await conversationRef.update({'unreadCounts.$userId': 0});

    // Optionally mark multiple messages' readBy - here we mark recent unread messages
    final query = await _db
        .collection('messages')
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('sentAt', descending: false)
        .get();

    final batch = _db.batch();
    for (final doc in query.docs) {
      final data = doc.data();
      final readBy = List<String>.from(data['readBy'] ?? []);
      if (!readBy.contains(userId)) {
        batch.update(doc.reference, {
          'readBy': FieldValue.arrayUnion([userId]),
        });
      }
    }
    await batch.commit();
  }

  @override
  Stream<List<Map<String, dynamic>>> getConversations(String userId) {
    return _db
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList(),
        );
  }

  // --- IGroupRepository Implementation ---

  @override
  Future<GroupCommunity> createGroup(GroupCommunity group) async {
    await _db.collection('groups').doc(group.id).set(group.toJson());
    return group;
  }

  @override
  Future<void> joinGroup(String groupId, String userId) async {
    await _db.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<List<GroupCommunity>> listGroupsForUser(String userId) async {
    final snapshot = await _db
        .collection('groups')
        .where('members', arrayContains: userId)
        .get();

    return snapshot.docs
        .map((doc) => GroupCommunity.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<String> createGroupChat(
    String name,
    List<String> userIds,
    String creatorId,
  ) async {
    try {
      final groupId = const Uuid().v4();
      final now = DateTime.now();

      if (!userIds.contains(creatorId)) {
        userIds.add(creatorId);
      }

      // Fetch user data for denormalization
      Map<String, Map<String, dynamic>> userData = {};
      for (String userId in userIds) {
        final userDoc = await _db.collection('users').doc(userId).get();
        if (userDoc.exists) {
          final user = User.fromJson(userDoc.data()!);
          userData[userId] = {
            'displayName': user.displayName,
            'photoUrl': user.photoUrl,
          };
        }
      }

      final groupData = {
        'id': groupId,
        'name': name,
        'participants': userIds,
        'userData': userData, // Denormalized data
        'isGroup': true,
        'adminIds': [creatorId],
        'createdAt': now.toIso8601String(),
        'lastMessage': 'Group created',
        'lastMessageTime': now.toIso8601String(),
        'unreadCounts': {for (var id in userIds) id: 0},
      };

      await _db.collection('conversations').doc(groupId).set(groupData);
      return groupId;
    } catch (e) {
      print("Error creating group: $e");
      rethrow;
    }
  }

  @override
  Future<List<GroupCommunity>> searchGroups(String query) async {
    if (query.isEmpty) return [];

    final snapshot = await _db
        .collection('groups')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + 'z')
        .get();

    return snapshot.docs
        .map((doc) => GroupCommunity.fromJson(doc.data()))
        .toList();
  }

  // Helper methods

  @override
  Future<void> deleteMessage(String messageId) async {
    await _db.collection('messages').doc(messageId).delete();
  }

  Future<User?> getUserById(String id) async {
    final doc = await _db.collection('users').doc(id).get();
    if (doc.exists) {
      return User.fromJson(doc.data()!);
    }
    return null;
  }
}
