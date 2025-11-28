import 'dart:async';
import 'package:cconnect/data/models/survey.dart';
import 'package:cconnect/data/repositories/interfaces/isurvey.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class SurveyProvider extends ChangeNotifier {
  final ISurveyRepository _repository;
  Timer? _expiryCheckTimer;

  SurveyProvider({required ISurveyRepository repository})
    : _repository = repository {
    _startExpiryCheck();
  }

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get stream of active surveys (auto-filtered by expiry)
  Stream<List<Survey>> getSurveys() {
    return _repository.getActiveSurveys();
  }

  /// Get a specific survey by ID
  Future<Survey?> getSurveyById(String id) async {
    return await _repository.getSurveyById(id);
  }

  /// Create a new survey
  Future<void> createSurvey({
    required String title,
    required String description,
    required String surveyLink,
    required DateTime endDateTime,
    required String userId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final surveyId = const Uuid().v4();

      final survey = Survey(
        id: surveyId,
        title: title,
        description: description,
        surveyLink: surveyLink,
        createdBy: userId,
        endDateTime: endDateTime,
      );

      await _repository.createSurvey(survey);
    } catch (e) {
      _setError('Failed to create survey: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Report a survey as inappropriate
  Future<void> reportSurvey(String surveyId) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.reportSurvey(surveyId);
    } catch (e) {
      _setError('Failed to report survey: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a survey (admin/creator only - check in UI)
  Future<void> deleteSurvey(String surveyId) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.deleteSurvey(surveyId);
    } catch (e) {
      _setError('Failed to delete survey: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Close a survey manually
  Future<void> closeSurvey(String surveyId) async {
    _setLoading(true);
    _clearError();

    try {
      final survey = await _repository.getSurveyById(surveyId);
      if (survey == null) throw Exception('Survey not found');

      final updatedSurvey = survey.copyWith(status: SurveyStatus.closed);
      await _repository.updateSurvey(updatedSurvey);
    } catch (e) {
      _setError('Failed to close survey: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Start periodic check for expired surveys
  void _startExpiryCheck() {
    // Check every hour for expired surveys
    _expiryCheckTimer = Timer.periodic(const Duration(hours: 1), (_) {
      _deleteExpiredSurveys();
    });

    // Also run immediately on startup
    _deleteExpiredSurveys();
  }

  /// Delete all expired surveys
  Future<void> _deleteExpiredSurveys() async {
    try {
      await _repository.deleteExpiredSurveys();
    } catch (e) {
      // Silent fail - just log error
      debugPrint('Failed to delete expired surveys: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  @override
  void dispose() {
    _expiryCheckTimer?.cancel();
    super.dispose();
  }
}
