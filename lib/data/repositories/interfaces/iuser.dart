import 'package:cconnect/data/models/userModel.dart';

abstract class IUserRepository {
  Future<User> getById(String id);
  Future<User?> fetchUser(String id);
  Future<User> create(User user);
  Future<void> update(User user);
  Future<List<User>> searchByNameOrEmail(String query);
}
