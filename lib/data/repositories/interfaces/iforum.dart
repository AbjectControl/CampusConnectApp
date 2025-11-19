import 'package:cconnect/data/models/discussionPost.dart';

abstract class IForumRepository {
  Future<DiscussionPost> createPost(DiscussionPost post);
  Future<List<DiscussionPost>> listRecent({int limit = 20});
  Future<void> replyToPost(String postId, DiscussionPost reply);
}
