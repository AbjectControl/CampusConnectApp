import 'package:cconnect/data/models/mentorProfile.dart';

abstract class IMentorRepository {
  Future<void> registerMentor(MentorProfile profile);
  Future<MentorProfile?> getProfile(String userId);
  Future<List<MentorProfile>> searchBySubject(String subject);
  Future<void> approveMentor(String userId, bool approved);
}
