import 'package:flutter/material.dart';
import 'package:cconnect/data/models/userModel.dart' as model;
import 'package:cconnect/data/repositories/interfaces/iuser.dart';

class UserProvider extends ChangeNotifier {
  final IUserRepository _userRepository;

  UserProvider({required IUserRepository userRepository}) 
      : _userRepository = userRepository;

  model.User? _user;
  model.User? get user => _user;

  void setUser(model.User user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  Future<void> updateOnlineStatus(bool isOnline) async {
    if (_user == null) return;
    
    final updatedUser = model.User(
      id: _user!.id,
      displayName: _user!.displayName,
      email: _user!.email,
      photoUrl: _user!.photoUrl,
      about: _user!.about,
      lastSeen: isOnline ? null : DateTime.now(),
      isOnline: isOnline,
      role: _user!.role,
      studentId: _user!.studentId,
      phone: _user!.phone,
      department: _user!.department,
      section: _user!.section,
      metadata: _user!.metadata,
    );

    // Update local state
    _user = updatedUser;
    notifyListeners();

    // Update remote
    // We use a fire-and-forget approach or await if critical
    try {
      await _userRepository.update(updatedUser);
    } catch (e) {
      print("Failed to update online status: $e");
    }
  }
}
