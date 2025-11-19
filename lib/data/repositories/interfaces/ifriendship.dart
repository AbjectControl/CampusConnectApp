import 'package:cconnect/data/models/friendshipModel.dart';

abstract class IFriendshipRepository {
  Future<Friendship> sendRequest(String requesterId, String recipientId);
  Future<void> respondToRequest(String friendshipId, bool accept);
  Future<List<Friendship>> listFriends(String userId);
}
