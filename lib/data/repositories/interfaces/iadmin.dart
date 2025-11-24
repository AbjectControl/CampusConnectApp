import 'package:cconnect/data/models/AdminAction.dart';
import 'package:cconnect/data/models/userModel.dart';

abstract class IAdminRepository {
  Future<void> takeAction(AdminAction action);
  Future<List<AdminAction>> listActions({int limit = 50});
  
  // User Management
  Stream<List<User>> getAllUsers();
  Future<void> banUser(String userId);
  Future<void> unbanUser(String userId);
  Future<void> promoteToAdmin(String userId);
  
  // Analytics
  Future<Map<String, int>> getUserStats();
}
