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

class ChatProvider extends ChangeNotifier {
  // Dependency Injection (DIP) - using interfaces
  final IChatRepository _chatRepository = ChatRepository();
  final IGroupRepository _groupRepository = ChatRepository();
  
  String? currentUserId;

  void setCurrentUser(String userId) {
    currentUserId = userId;
    notifyListeners();
  }

  Stream<List<Message>> getMessages(String conversationId) {
    return _chatRepository.subscribeToMessages(conversationId);
  }

  Future<void> sendMessage(String conversationId, String text, {MessageType type = MessageType.text}) async {
    if (text.trim().isEmpty || currentUserId == null) return;

    final message = Message(
      id: const Uuid().v4(),
      conversationId: conversationId,
      senderId: currentUserId!,
      text: text.trim(),
      type: type,
      sentAt: DateTime.now(),
    );

    await _chatRepository.sendMessage(message);
  }

  Future<void> markRead(String conversationId, String messageId) async {
    if (currentUserId == null) return;
    await _chatRepository.markRead(conversationId, messageId, currentUserId!);
  }

  Future<void> deleteMessage(String messageId) async {
    // Cast to concrete implementation if needed, or add to interface if common
    // For now, assuming ChatRepository has it or we add it to IChatRepository
    // But since it's not in IChatRepository, we might need to add it or cast.
    // Ideally, add to IChatRepository. For now, let's use the concrete instance method if possible
    // or just skip if not in interface. 
    // Wait, I should have added it to IChatRepository. Let's fix that later.
    // For now, I'll temporarily cast or just instantiate concrete for this specific method
    // OR better, I'll update the interface in the next step if I missed it.
    // Actually, I missed adding deleteMessage to IChatRepository. 
    // I will add it to the interface in a separate step to be clean.
    // For now, I will comment it out or use a workaround.
    // Workaround: ( _chatRepository as ChatRepository).deleteMessage(messageId);
    if (_chatRepository is ChatRepository) {
      await (_chatRepository as ChatRepository).deleteMessage(messageId);
    }
  }

  // SRP - Use UserRepository for search
  Stream<List<User>> searchUsers(String query) async* {
    if (query.isEmpty) {
      yield []; 
      return;
    }
    // Convert Future to Stream for compatibility with UI
    final users = await UserRepository.instance.searchByNameOrEmail(query);
    yield users;
  }


  
  Future<List<dynamic>> searchGroups(String query) async {
    if (query.isEmpty) return [];
    return await _groupRepository.searchGroups(query);
  }

  // Friendship Methods
  final FriendshipRepository _friendshipRepository = FriendshipRepository();

  Future<void> sendFriendRequest(String recipientId) async {
    if (currentUserId == null) return;
    await _friendshipRepository.sendFriendRequest(currentUserId!, recipientId);
  }

  Future<void> acceptFriendRequest(String friendshipId) async {
    await _friendshipRepository.acceptFriendRequest(friendshipId);
  }

  Future<void> rejectFriendRequest(String friendshipId) async {
    await _friendshipRepository.rejectFriendRequest(friendshipId);
  }

  Future<void> unfriend(String otherUserId) async {
    if (currentUserId != null) {
      await _friendshipRepository.unfriend(currentUserId!, otherUserId);
    }
  }

  Future<Friendship?> getFriendship(String otherUserId) async {
    if (currentUserId == null) return null;
    return await _friendshipRepository.getFriendship(currentUserId!, otherUserId);
  }
  
  // This method is now less critical for the list view due to denormalization,
  // but still useful for other things.
  Future<User?> getUser(String userId) async {
    return UserRepository.instance.fetchUser(userId);
  }

  Stream<User?> getUserStream(String userId) {
    return UserRepository.instance.getUserStream(userId);
  }

  Stream<List<Map<String, dynamic>>> getConversations() {
    if (currentUserId == null) return Stream.value([]);
    return _chatRepository.getConversations(currentUserId!);
  }

  Future<String?> createGroup(String name, List<String> userIds) async {
    if (currentUserId == null) return null;
    return await _groupRepository.createGroupChat(name, userIds, currentUserId!);
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
