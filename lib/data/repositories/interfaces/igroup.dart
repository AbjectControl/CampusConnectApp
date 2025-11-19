import 'package:cconnect/data/models/groupCommunity.dart';

abstract class IGroupRepository {
  Future<GroupCommunity> createGroup(GroupCommunity group);
  Future<void> joinGroup(String groupId, String userId);
  Future<List<GroupCommunity>> listGroupsForUser(String userId);
}
