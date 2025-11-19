import 'package:cconnect/data/models/message.dart';

abstract class IChatRepository {
  /// conversationId can be groupId or 1-1 chat id
  Future<void> sendMessage(Message message);
  Stream<List<Message>> subscribeToMessages(String conversationId);
  Future<List<Message>> fetchRecentMessages(
    String conversationId, {
    int limit = 50,
  });
  Future<void> markRead(String conversationId, String messageId, String userId);
}
