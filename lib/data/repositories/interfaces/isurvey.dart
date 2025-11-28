import 'package:cconnect/data/models/survey.dart';

abstract class ISurveyRepository {
  Future<void> createSurvey(Survey survey);
  Stream<List<Survey>> getActiveSurveys();
  Future<Survey?> getSurveyById(String id);
  Future<void> updateSurvey(Survey survey);
  Future<void> deleteSurvey(String id);
  Future<void> reportSurvey(String id);
  Future<void> deleteExpiredSurveys();
}
