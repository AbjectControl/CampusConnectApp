import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cconnect/data/models/userModel.dart';
import 'package:cconnect/data/repositories/interfaces/iuser.dart';

class FirebaseUserRepository implements IUserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  @override
  Future<User> getById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) {
        throw Exception('User not found');
      }
      return User.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  @override
  Future<User?> fetchUser(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      return doc.exists ? User.fromJson(doc.data()!) : null;
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  @override
  Future<User> create(User user) async {
    try {
      final docRef = _firestore.collection(_collection).doc(user.id);
      await docRef.set(user.toJson());
      return user;
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  @override
  Future<void> update(User user) async {
    try {
      final docRef = _firestore.collection(_collection).doc(user.id);
      await docRef.update(user.toJson());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  @override
  Future<List<User>> searchByNameOrEmail(String query) async {
    try {
      final q = query.toLowerCase();
      final result = <User>[];

      // 🔹 Search by displayName
      final nameSnap = await _firestore
          .collection(_collection)
          .where('displayName', isGreaterThanOrEqualTo: q)
          .where('displayName', isLessThanOrEqualTo: '$q\uf8ff')
          .get();

      for (var doc in nameSnap.docs) {
        result.add(User.fromJson(doc.data()));
      }

      // 🔹 Search by email (exact match)
      final emailSnap = await _firestore
          .collection(_collection)
          .where('email', isEqualTo: query)
          .get();

      for (var doc in emailSnap.docs) {
        if (!result.any((u) => u.id == doc.id)) {
          result.add(User.fromJson(doc.data()));
        }
      }

      return result;
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }
}
