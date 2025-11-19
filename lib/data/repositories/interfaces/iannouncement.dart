import 'package:cconnect/data/models/announcement.dart';

abstract class IAnnouncementRepository {
  Future<Announcement> createAnnouncement(Announcement a);
  Future<List<Announcement>> listRecent();
}
