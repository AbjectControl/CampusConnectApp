import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cconnect/data/models/survey.dart';
import 'package:cconnect/data/repositories/interfaces/isurvey.dart';

class SurveyRepository implements ISurveyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'surveys';

  @override
  Future<void> createSurvey(Survey survey) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(survey.id)
          .set(survey.toJson());
    } catch (e) {
      throw Exception('Failed to create survey: $e');
    }
  }

  @override
  Stream<List<Survey>> getActiveSurveys() {
    try {
      return _firestore
          .collection(_collectionName)
          .where('endDateTime', isGreaterThan: DateTime.now().toIso8601String())
          .orderBy('endDateTime', descending: false)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => Survey.fromJson({...doc.data(), 'id': doc.id}))
                .where((survey) => !survey.isExpired) // Extra filter
                .toList();
          });
    } catch (e) {
      throw Exception('Failed to get surveys: $e');
    }
  }

  @override
  Future<Survey?> getSurveyById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (!doc.exists) return null;
      return Survey.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      throw Exception('Failed to get survey: $e');
    }
  }

  @override
  Future<void> updateSurvey(Survey survey) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(survey.id)
          .update(survey.toJson());
    } catch (e) {
      throw Exception('Failed to update survey: $e');
    }
  }

  @override
  Future<void> deleteSurvey(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete survey: $e');
    }
  }

  @override
  Future<void> reportSurvey(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).update({
        'reportCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to report survey: $e');
    }
  }

  @override
  Future<void> deleteExpiredSurveys() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('endDateTime', isLessThan: DateTime.now().toIso8601String())
          .get();

      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete expired surveys: $e');
    }
  }
}
