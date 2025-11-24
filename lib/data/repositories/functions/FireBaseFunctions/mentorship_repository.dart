import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cconnect/data/models/mentorProfile.dart';
import 'package:cconnect/data/repositories/interfaces/imentor.dart';

class MentorshipRepository implements IMentorRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _userCollection = 'users';
  
  // Singleton instance
  static final MentorshipRepository instance = MentorshipRepository._();
  MentorshipRepository._();

  @override
  Future<void> registerMentor(MentorProfile profile) async {
    // Implementation from interface
  }

  @override
  Future<MentorProfile?> getProfile(String userId) async {
    // Implementation from interface
    return null;
  }

  @override
  Future<List<MentorProfile>> searchBySubject(String subject) async {
    // Implementation from interface
    return [];
  }

  @override
  Future<void> approveMentor(String userId, bool approved) async {
    // Implementation from interface
  }

  // ========== MENTORSHIP REQUESTS ==========

  @override
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

  @override
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

  @override
  Future<void> approveMentorshipRequest(String requestId, String userId) async {
    final batch = _firestore.batch();

    // Update request status
    batch.update(
      _firestore.collection('mentorshipRequests').doc(requestId),
      {'approved': true},
    );

    // Update user role to mentor
    batch.update(
      _firestore.collection(_userCollection).doc(userId),
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

  @override
  Future<void> rejectMentorshipRequest(String requestId) async {
    await _firestore.collection('mentorshipRequests').doc(requestId).delete();
  }
}
