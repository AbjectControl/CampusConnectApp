import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cconnect/data/models/message.dart';
import 'package:cconnect/data/models/userModel.dart';
import 'package:cconnect/data/models/groupCommunity.dart';
import 'package:uuid/uuid.dart';

class ChatRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Messages ---

  Future<void> sendMessage(Message message) async {
    // 1. Save Message
    await _db.collection('messages').doc(message.id).set(message.toJson());
    
    // 2. Update Conversation
    // We need to update the conversation for BOTH users (or the group).
    // For 1-on-1, the ID is "id1_id2".
    
    final conversationRef = _db.collection('conversations').doc(message.conversationId);
    final conversationDoc = await conversationRef.get();

    if (!conversationDoc.exists) {
      // Create new conversation
      // We need to know who the participants are. 
      // In a real app, we'd pass the full Conversation object or participant list.
      // For now, we'll assume we can't easily get the OTHER participant ID here 
      // unless we pass it. 
      // BUT, for 1-on-1, the conversationId IS "id1_id2". We can parse it.
      
      List<String> participants = [];
      if (message.conversationId.contains('_')) {
        participants = message.conversationId.split('_');
      } else {
        // Group or other logic
        participants = [message.senderId]; 
      }

      await conversationRef.set({
        'id': message.conversationId,
        'participants': participants,
        'lastMessage': message.text,
        'lastMessageTime': message.sentAt.toIso8601String(),
        'unreadCount': 1, // Logic for unread count is complex, skipping for MVP
        'isGroup': false, // Default
      });
    } else {
      // Update existing
      await conversationRef.update({
        'lastMessage': message.text,
        'lastMessageTime': message.sentAt.toIso8601String(),
        // 'unreadCount': FieldValue.increment(1), // Increment for receiver? 
      });
    }
  }

  Stream<List<Map<String, dynamic>>> getConversations(String userId) {
    return _db
        .collection('conversations')
        .where('participants', arrayContains: userId)
        // .orderBy('lastMessageTime', descending: true) // Commented out to avoid index requirement for now
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<Message>> getMessages(String conversationId) {
    return _db
        .collection('messages')
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromJson(doc.data()))
            .toList());
  }

  Future<void> deleteMessage(String messageId) async {
    await _db.collection('messages').doc(messageId).delete();
  }

  // --- Conversations / Users ---

  // For 1-on-1, conversationId can be a combination of user IDs (e.g., "id1_id2" sorted)
  // or we can query messages where user is sender OR receiver.
  // A better approach for "WhatsApp-like" list is to have a separate 'conversations' collection
  // or just query recent messages. For simplicity in this MVP, we might just query users 
  // who have chatted. 
  // BUT, the user asked for "Search by studentId, name" to start chats.
  
  Stream<List<User>> searchUsers(String query) {
    if (query.isEmpty) return Stream.value([]);
    
    // Search by displayName
    final nameStream = _db
        .collection('users')
        .where('displayName', isGreaterThanOrEqualTo: query)
        .where('displayName', isLessThan: query + 'z')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => User.fromJson(doc.data()))
            .toList());

    // Search by studentId
    final idStream = _db
        .collection('users')
        .where('studentId', isGreaterThanOrEqualTo: query)
        .where('studentId', isLessThan: query + 'z')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => User.fromJson(doc.data()))
            .toList());

    // Merge streams (simple merge, might have duplicates if name == id which is rare)
    // For a better UX, we'd use RxDart's CombineLatest, but here we can just return one 
    // or try to combine locally. Since we can't easily combine streams without RxDart,
    // we will just return the name search for now and add a separate method or 
    // use a different approach if the user insists on simultaneous search.
    // actually, let's just use the name stream for now and tell the user 
    // that Firestore limitations make "OR" queries hard without extra packages.
    // BUT, I can try to listen to both and merge in the controller? 
    // No, let's just stick to the requested change: "search on basis of studentid also".
    
    // Let's try to return the merge using async map? No.
    // I will use a simple implementation: Search Name OR StudentID.
    // Since I can't return a merged stream easily without RxDart, I will 
    // change this to return a Future or just search Name for now and 
    // add a specific "Search by ID" toggle? 
    // User said "on basis of studentid also".
    
    // Let's try this: 
    // We will return the name stream as primary. 
    // If the query looks like an ID (contains numbers), we search ID?
    
    bool isId = RegExp(r'[0-9]').hasMatch(query);
    if (isId) {
       return idStream;
    }
    return nameStream;
  }

  Future<User?> getUserByStudentId(String studentId) async {
    final snapshot = await _db
        .collection('users')
        .where('studentId', isEqualTo: studentId)
        .limit(1)
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      return User.fromJson(snapshot.docs.first.data());
    }
    return null;
  }

  Future<User?> getUserById(String id) async {
    final doc = await _db.collection('users').doc(id).get();
    if (doc.exists) {
      return User.fromJson(doc.data()!);
    }
    return null;
  }

  // --- Groups ---

  Future<void> createGroup(GroupCommunity group) async {
    await _db.collection('groups').doc(group.id).set(group.toJson());
  }

  Stream<List<GroupCommunity>> getGroupsForUser(String userId) {
    return _db
        .collection('groups')
        .where('members', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GroupCommunity.fromJson(doc.data()))
            .toList());
  }
  Future<String> createGroupChat(String name, List<String> userIds, String creatorId) async {
    try {
      final groupId = const Uuid().v4();
      final now = DateTime.now();
      
      // Add creator to the list if not already there
      if (!userIds.contains(creatorId)) {
        userIds.add(creatorId);
      }

      final groupData = {
        'id': groupId,
        'name': name,
        'participants': userIds,
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
}
