import 'package:cconnect/data/models/event.dart';

abstract class IEventRepository {
  Future<void> createEvent(Event event);
  Stream<List<Event>> getActiveEvents();
  Future<void> deleteEvent(String id);
  Future<String?> uploadImage(String imagePath);
  Future<void> deleteExpiredEvents();
}
