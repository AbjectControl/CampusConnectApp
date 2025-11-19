import 'package:cconnect/data/models/AdminAction.dart';

abstract class IAdminRepository {
  Future<void> takeAction(AdminAction action);
  Future<List<AdminAction>> listActions({int limit = 50});
}
