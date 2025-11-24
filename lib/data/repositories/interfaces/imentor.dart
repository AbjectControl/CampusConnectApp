import 'package:cconnect/data/models/mentorProfile.dart';

abstract class IMentorRepository {
  Future<void> registerMentor(MentorProfile profile);
  Future<MentorProfile?> getProfile(String userId);
  Future<List<MentorProfile>> searchBySubject(String subject);
  Future<void> approveMentor(String userId, bool approved);
  
  // Mentorship Requests
  Future<void> submitMentorshipRequest(MentorProfile profile);
  Stream<List<Map<String, dynamic>>> getMentorshipRequests();
  Future<void> approveMentorshipRequest(String requestId, String userId);
  Future<void> rejectMentorshipRequest(String requestId);
}
