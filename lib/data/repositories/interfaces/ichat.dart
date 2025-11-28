import 'package:cconnect/data/models/message.dart';

abstract class IChatRepository {
  /// conversationId can be groupId or 1-1 chat id
  Future<void> sendMessage(Message message);
  Stream<List<Message>> subscribeToMessages(String conversationId);
  Future<List<Message>> fetchRecentMessages(
    String conversationId, {
    int limit = 50,
  });

  /// Mark a specific message as read for a given user.
  Future<void> markRead(String conversationId, String messageId, String userId);

  /// Mark all relevant messages in the conversation as read for a user.
  Future<void> markMessagesAsRead(String conversationId, String userId);

  Stream<List<Map<String, dynamic>>> getConversations(String userId);

  /// Delete a message by id.
  Future<void> deleteMessage(String messageId);
}
