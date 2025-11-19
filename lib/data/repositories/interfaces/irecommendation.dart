abstract class IRecommendationEngine {
  Future<List<String>> recommendResourcesForUser(
    String userId, {
    int limit = 10,
  });
  Future<List<String>> recommendMentorsForUser(String userId, {int limit = 10});
}
