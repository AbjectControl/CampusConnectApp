import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cconnect/data/models/AdminAction.dart';
import 'package:cconnect/data/models/userModel.dart';
import 'package:cconnect/data/repositories/interfaces/iadmin.dart';

class AdminRepository implements IAdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _userCollection = 'users';
  
  // Singleton instance
  static final AdminRepository instance = AdminRepository._();
  AdminRepository._();

  @override
  Future<void> takeAction(AdminAction action) async {
    // Implementation for generic admin actions if needed
    // For now just a placeholder as per interface
  }

  @override
  Future<List<AdminAction>> listActions({int limit = 50}) async {
    // Placeholder implementation
    return [];
  }

  // ========== USER MANAGEMENT ==========

  @override
  Stream<List<User>> getAllUsers() {
    return _firestore.collection(_userCollection).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => User.fromJson(doc.data())).toList());
  }

  @override
  Future<void> banUser(String userId) async {
    await _firestore.collection(_userCollection).doc(userId).update({'banned': true});
  }

  @override
  Future<void> unbanUser(String userId) async {
    await _firestore.collection(_userCollection).doc(userId).update({'banned': false});
  }

  @override
  Future<void> promoteToAdmin(String userId) async {
    await _firestore.collection(_userCollection).doc(userId).update({'role': 'admin'});
  }

  // ========== ANALYTICS ==========

  @override
  Future<Map<String, int>> getUserStats() async {
    final usersSnapshot = await _firestore.collection(_userCollection).get();
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
