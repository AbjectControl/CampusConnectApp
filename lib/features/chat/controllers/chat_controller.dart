import 'package:cconnect/data/models/message.dart';
import 'package:cconnect/data/models/userModel.dart';
import 'package:cconnect/data/repositories/functions/FireBaseFunctions/chat_repository.dart';
import 'package:cconnect/data/repositories/functions/FireBaseFunctions/user.dart';
import 'package:cconnect/utils/constraints/enums.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ChatController extends ChangeNotifier {
  final ChatRepository _repository = ChatRepository();
  final String currentUserId;

  ChatController({required this.currentUserId});

  Stream<List<Message>> getMessages(String conversationId) {
    return _repository.subscribeToMessages(conversationId);
  }

  Future<void> sendMessage(String conversationId, String text, {MessageType type = MessageType.text}) async {
    if (text.trim().isEmpty) return;

    final message = Message(
      id: const Uuid().v4(),
      conversationId: conversationId,
      senderId: currentUserId,
      text: text.trim(),
      type: type,
      sentAt: DateTime.now(),
    );

    await _repository.sendMessage(message);
  }

  Future<void> deleteMessage(String messageId) async {
    await _repository.deleteMessage(messageId);
  }

  Stream<List<User>> searchUsers(String query) async* {
    if (query.isEmpty) {
      yield [];
      return;
    }
    final users = await UserRepository.instance.searchByNameOrEmail(query);
    yield users;
  }
  
  Future<User?> getUser(String userId) async {
    return _repository.getUserById(userId);
  }

  Stream<List<Map<String, dynamic>>> getConversations() {
    return _repository.getConversations(currentUserId);
  }

  // Helper to generate a consistent conversation ID for 1-on-1 chats
  String getConversationId(String otherUserId) {
    final List<String> ids = [currentUserId, otherUserId];
    ids.sort(); // Ensure consistent order (e.g., "id1_id2")
    return ids.join('_');
  }
}
