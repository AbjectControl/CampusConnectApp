import 'package:cconnect/data/models/message.dart';
import 'package:cconnect/data/models/userModel.dart';
import 'package:cconnect/data/repositories/functions/FireBaseFunctions/chat_repository.dart';
import 'package:cconnect/utils/constraints/enums.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _repository = ChatRepository();
  String? currentUserId;

  void setCurrentUser(String userId) {
    currentUserId = userId;
    notifyListeners();
  }

  Stream<List<Message>> getMessages(String conversationId) {
    return _repository.getMessages(conversationId);
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

    await _repository.sendMessage(message);
  }

  Future<void> deleteMessage(String messageId) async {
    await _repository.deleteMessage(messageId);
  }

  Stream<List<User>> searchUsers(String query) {
    return _repository.searchUsers(query);
  }
  
  Future<User?> getUser(String userId) async {
    return _repository.getUserById(userId);
  }

  Stream<List<Map<String, dynamic>>> getConversations() {
    if (currentUserId == null) return Stream.value([]);
    return _repository.getConversations(currentUserId!);
  }

  Future<String?> createGroup(String name, List<String> userIds) async {
    if (currentUserId == null) return null;
    return await _repository.createGroupChat(name, userIds, currentUserId!);
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
