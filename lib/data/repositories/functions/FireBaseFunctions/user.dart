import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cconnect/data/models/mentorProfile.dart';
import 'package:cconnect/data/models/userModel.dart';
import 'package:cconnect/data/repositories/interfaces/iuser.dart';

class UserRepository implements IUserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  // Singleton instance removed for SOLID compliance (Dependency Injection)
  // static final UserRepository instance = UserRepository._();
  // UserRepository._();

  UserRepository();

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
      if (query.trim().isEmpty) return [];
      final q = query.trim();
      final result = <User>[];
      final futures = <Future<QuerySnapshot<Map<String, dynamic>>>>[];

      // Helper to add unique users
      void addUsers(QuerySnapshot<Map<String, dynamic>> snap) {
        for (var doc in snap.docs) {
          if (!result.any((u) => u.id == doc.id)) {
            result.add(User.fromJson(doc.data()));
          }
        }
      }

      // 1. Search by displayName (As-is) - Prefix
      futures.add(
        _firestore
            .collection(_collection)
            .where('displayName', isGreaterThanOrEqualTo: q)
            .where('displayName', isLessThanOrEqualTo: '$q\uf8ff')
            .get(),
      );

      // 2. Search by displayName (Capitalized) - e.g. "ali" -> "Ali"
      if (q.isNotEmpty) {
        final capQuery = q[0].toUpperCase() + q.substring(1);
        if (capQuery != q) {
          futures.add(
            _firestore
                .collection(_collection)
                .where('displayName', isGreaterThanOrEqualTo: capQuery)
                .where('displayName', isLessThanOrEqualTo: '$capQuery\uf8ff')
                .get(),
          );
        }
      }

      // 3. Search by studentId (As-is) - Prefix
      futures.add(
        _firestore
            .collection(_collection)
            .where('studentId', isGreaterThanOrEqualTo: q)
            .where('studentId', isLessThanOrEqualTo: '$q\uf8ff')
            .get(),
      );

      // 4. Search by studentId (Uppercase) - e.g. "l23" -> "L23"
      final upperQuery = q.toUpperCase();
      if (upperQuery != q) {
        futures.add(
          _firestore
              .collection(_collection)
              .where('studentId', isGreaterThanOrEqualTo: upperQuery)
              .where('studentId', isLessThanOrEqualTo: '$upperQuery\uf8ff')
              .get(),
        );
      }

      // 5. Search by email (Exact)
      futures.add(
        _firestore.collection(_collection).where('email', isEqualTo: q).get(),
      );

      // Execute all queries in parallel
      final snapshots = await Future.wait(futures);
      for (var snap in snapshots) {
        addUsers(snap);
      }

      return result;
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  // ========== MENTORSHIP & ADMIN METHODS MOVED ==========
  // These methods have been moved to MentorshipRepository and AdminRepository
  // to adhere to SOLID principles (Single Responsibility Principle).

  @override
  Stream<User?> getUserStream(String userId) {
    return _firestore.collection(_collection).doc(userId).snapshots().map((
      doc,
    ) {
      if (doc.exists) {
        return User.fromJson(doc.data()!);
      }
      return null;
    });
  }

  @override
  Future<void> updateUserFields(
    String userId,
    Map<String, dynamic> fields,
  ) async {
    try {
      await _firestore.collection(_collection).doc(userId).update(fields);
    } catch (e) {
      throw Exception('Failed to update user fields: $e');
    }
  }
}
