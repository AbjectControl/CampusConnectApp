import 'package:cconnect/data/models/message.dart';
import 'package:cconnect/data/models/userModel.dart';
import 'package:cconnect/data/repositories/functions/FireBaseFunctions/chat_repository.dart';
import 'package:cconnect/data/repositories/functions/FireBaseFunctions/user.dart';
import 'package:cconnect/data/repositories/interfaces/ichat.dart';
import 'package:cconnect/data/repositories/interfaces/igroup.dart';
import 'package:cconnect/data/models/friendshipModel.dart';
import 'package:cconnect/data/repositories/functions/FireBaseFunctions/friendship_repository.dart';
import 'package:cconnect/utils/constraints/enums.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:cconnect/data/repositories/interfaces/ifriendship.dart';
import 'package:cconnect/data/repositories/interfaces/iuser.dart';

class ChatProvider extends ChangeNotifier {
  // Dependency Injection (DIP) - using interfaces
  final IChatRepository _chatRepository;
  final IGroupRepository _groupRepository;
  final IFriendshipRepository _friendshipRepository;
  final IUserRepository _userRepository;

  ChatProvider({
    required IChatRepository chatRepository,
    required IGroupRepository groupRepository,
    required IFriendshipRepository friendshipRepository,
    required IUserRepository userRepository,
  }) : _chatRepository = chatRepository,
       _groupRepository = groupRepository,
       _friendshipRepository = friendshipRepository,
       _userRepository = userRepository;

  // Fix: matching field names
  // Note: your original used _friendshipRepository and _userRepository — keep them consistent
  // (rename back if you prefer). For clarity here I'm using the original provided names below.

  String? currentUserId;

  void setCurrentUser(String userId) {
    currentUserId = userId;
    notifyListeners();
  }

  Stream<List<Message>> getMessages(String conversationId) {
    return _chatRepository.subscribeToMessages(conversationId);
  }

  Future<void> sendMessage(
    String conversationId,
    String text, {
    MessageType type = MessageType.text,
  }) async {
    if (text.trim().isEmpty || currentUserId == null) return;

    final message = Message(
      id: const Uuid().v4(),
      conversationId: conversationId,
      senderId: currentUserId!,
      text: text.trim(),
      type: type,
      sentAt: DateTime.now(),
      readBy: [], // ensure default
    );

    await _chatRepository.sendMessage(message);
  }

  Future<void> deleteMessage(String messageId) async {
    await _chatRepository.deleteMessage(messageId);
  }

  // New wrappers so UI doesn't need to pass currentUserId each time
  Future<void> markRead(String conversationId, String messageId) async {
    if (currentUserId == null) return;
    await _chatRepository.markRead(conversationId, messageId, currentUserId!);
  }

  Future<void> markMessagesAsRead(String conversationId) async {
    if (currentUserId == null) return;
    await _chatRepository.markMessagesAsRead(conversationId, currentUserId!);
  }

  // SRP - Use UserRepository for search
  Stream<List<User>> searchUsers(String query) async* {
    if (query.isEmpty) {
      yield [];
      return;
    }
    // Convert Future to Stream for compatibility with UI
    final users = await _userRepository.searchByNameOrEmail(query);
    yield users;
  }

  Future<List<dynamic>> searchGroups(String query) async {
    if (query.isEmpty) return [];
    return await _groupRepository.searchGroups(query);
  }

  // Friendship Methods
  Future<void> sendFriendRequest(String recipientId) async {
    if (currentUserId == null) return;
    await _friendshipRepository.sendRequest(currentUserId!, recipientId);
  }

  Future<void> acceptFriendRequest(String friendshipId) async {
    await _friendshipRepository.respondToRequest(friendshipId, true);
  }

  Future<void> rejectFriendRequest(String friendshipId) async {
    await _friendshipRepository.respondToRequest(friendshipId, false);
  }

  Future<void> unfriend(String friendshipId) async {
    await _friendshipRepository.respondToRequest(friendshipId, false);
  }

  Future<Friendship?> getFriendship(String otherUserId) async {
    if (currentUserId == null) return null;
    return await _friendshipRepository.getFriendship(
      currentUserId!,
      otherUserId,
    );
  }

  Future<User?> getUser(String userId) async {
    return _userRepository.fetchUser(userId);
  }

  Stream<User?> getUserStream(String userId) {
    return _userRepository.getUserStream(userId);
  }

  Stream<List<Map<String, dynamic>>> getConversations() {
    if (currentUserId == null) return Stream.value([]);
    return _chatRepository.getConversations(currentUserId!);
  }

  Future<String?> createGroup(String name, List<String> userIds) async {
    if (currentUserId == null) return null;
    return await _groupRepository.createGroupChat(
      name,
      userIds,
      currentUserId!,
    );
  }

  String getConversationId(String otherUserId) {
    if (currentUserId == null) return '';
    final List<String> ids = [currentUserId!, otherUserId];
    ids.sort(); // Ensure consistent order (e.g., "id1_id2")
    return ids.join('_');
  }

  /// Clear all chat state (call on logout)
  void clear() {
    currentUserId = null;
    notifyListeners();
  }
}
