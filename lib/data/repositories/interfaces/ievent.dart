import 'package:cconnect/data/models/eventItem.dart';

abstract class IEventRepository {
  Future<EventItem> createEvent(EventItem event);
  Future<List<EventItem>> listUpcomingForUser(String userId);
  Future<void> joinEvent(String eventId, String userId);
  Future<void> cancelEvent(String eventId);
}
