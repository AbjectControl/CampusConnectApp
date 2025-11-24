import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cconnect/data/models/mentorProfile.dart';
import 'package:cconnect/data/models/userModel.dart';
import 'package:cconnect/data/repositories/interfaces/iuser.dart';

class UserRepository implements IUserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  // Singleton instance
  static final UserRepository instance = UserRepository._();
  UserRepository._();

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

  // ========== MENTORSHIP METHODS ==========

  /// Submit mentorship request
  Future<void> submitMentorshipRequest(MentorProfile profile) async {
    await _firestore.collection('mentorshipRequests').add({
      'userId': profile.userId,
      'subjects': profile.subjects,
      'bio': profile.bio,
      'availability': profile.availability,
      'approved': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get all mentorship requests (for admin)
  Stream<List<Map<String, dynamic>>> getMentorshipRequests() {
    return _firestore
        .collection('mentorshipRequests')
        .where('approved', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  /// Approve mentorship request
  Future<void> approveMentorshipRequest(String requestId, String userId) async {
    final batch = _firestore.batch();

    // Update request status
    batch.update(
      _firestore.collection('mentorshipRequests').doc(requestId),
      {'approved': true},
    );

    // Update user role to mentor
    batch.update(
      _firestore.collection(_collection).doc(userId),
      {'role': 'mentor'},
    );

    // Get request data to create mentor profile
    final requestDoc = await _firestore.collection('mentorshipRequests').doc(requestId).get();
    final requestData = requestDoc.data()!;

    // Create mentor profile
    batch.set(
      _firestore.collection('mentorProfiles').doc(userId),
      {
        'userId': userId,
        'subjects': requestData['subjects'],
        'bio': requestData['bio'],
        'availability': requestData['availability'],
        'approved': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
    );

    await batch.commit();
  }

  /// Reject mentorship request
  Future<void> rejectMentorshipRequest(String requestId) async {
    await _firestore.collection('mentorshipRequests').doc(requestId).delete();
  }

  // ========== ADMIN METHODS ==========

  /// Get all users (for admin)
  Stream<List<User>> getAllUsers() {
    return _firestore.collection(_collection).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => User.fromJson(doc.data())).toList());
  }

  /// Ban user
  Future<void> banUser(String userId) async {
    await _firestore.collection(_collection).doc(userId).update({'banned': true});
  }

  /// Unban user
  Future<void> unbanUser(String userId) async {
    await _firestore.collection(_collection).doc(userId).update({'banned': false});
  }

  /// Promote to admin
  Future<void> promoteToAdmin(String userId) async {
    await _firestore.collection(_collection).doc(userId).update({'role': 'admin'});
  }

  /// Get user stats (for analytics)
  Future<Map<String, int>> getUserStats() async {
    final usersSnapshot = await _firestore.collection(_collection).get();
    final mentorRequestsSnapshot = await _firestore
        .collection('mentorshipRequests')
        .where('approved', isEqualTo: false)
        .get();
    final groupsSnapshot = await _firestore.collection('conversations').where('isGroup', isEqualTo: true).get();

    return {
      'totalUsers': usersSnapshot.size,
      'pendingRequests': mentorRequestsSnapshot.size,
      'activeGroups': groupsSnapshot.size,
    };
  }
}

