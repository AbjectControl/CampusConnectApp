import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cconnect/data/models/userModel.dart';
import 'package:cconnect/data/repositories/interfaces/iuser.dart';

class FirebaseUserRepository implements IUserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users'; // Firestore collection name

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
      final lowerQuery = query.toLowerCase();
      final snapshot = await _firestore
          .collection(_collection)
          .where('displayName', isGreaterThanOrEqualTo: lowerQuery)
          .where('displayName', isLessThanOrEqualTo: '$lowerQuery\uf8ff')
          .get();

      final emailSnapshot = await _firestore
          .collection(_collection)
          .where('email', isEqualTo: query)
          .get();

      final users = <User>[];

      for (var doc in snapshot.docs) {
        users.add(User.fromJson(doc.data()));
      }

      for (var doc in emailSnapshot.docs) {
        // avoid duplicates
        if (!users.any((u) => u.id == doc.id)) {
          users.add(User.fromJson(doc.data()));
        }
      }

      return users;
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }
}
