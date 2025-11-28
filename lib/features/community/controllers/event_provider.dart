import 'dart:async';
import 'package:cconnect/data/models/event.dart';
import 'package:cconnect/data/models/userModel.dart';
import 'package:cconnect/data/repositories/interfaces/ievent.dart';
import 'package:cconnect/utils/constraints/enums.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class EventProvider extends ChangeNotifier {
  final IEventRepository _repository;
  final ImagePicker _imagePicker = ImagePicker();
  Timer? _expiryCheckTimer;

  EventProvider({required IEventRepository repository})
    : _repository = repository {
    _startExpiryCheck();
  }

  bool _isLoading = false;
  String? _error;
  String? _selectedImagePath;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedImagePath => _selectedImagePath;

  Stream<List<Event>> getEvents() {
    return _repository.getActiveEvents();
  }

  Future<void> createEvent({
    required String title,
    required String venue,
    required DateTime startTime,
    required DateTime endTime,
    required String userId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final eventId = const Uuid().v4();
      String? imageUrl;

      if (_selectedImagePath != null) {
        imageUrl = await _repository.uploadImage(_selectedImagePath!);
      }

      final event = Event(
        id: eventId,
        title: title,
        venue: venue,
        imageUrl: imageUrl,
        startTime: startTime,
        endTime: endTime,
        createdBy: userId,
      );

      await _repository.createEvent(event);
      _selectedImagePath = null;
    } catch (e) {
      _setError('Failed to create event: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteEvent(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.deleteEvent(id);
    } catch (e) {
      _setError('Failed to delete event: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        _selectedImagePath = image.path;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to pick image: $e');
    }
  }

  void clearSelectedImage() {
    _selectedImagePath = null;
    notifyListeners();
  }

  bool canCreateEvent(User? user) {
    return user != null &&
        (user.role == UserRole.admin || user.role == UserRole.manager);
  }

  void _startExpiryCheck() {
    _expiryCheckTimer = Timer.periodic(const Duration(hours: 1), (_) {
      _deleteExpiredEvents();
    });
    _deleteExpiredEvents();
  }

  Future<void> _deleteExpiredEvents() async {
    try {
      await _repository.deleteExpiredEvents();
    } catch (e) {
      debugPrint('Failed to delete expired events: $e');
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
