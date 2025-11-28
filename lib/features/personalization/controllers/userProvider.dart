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

    final lastSeen = isOnline ? null : DateTime.now();

    // Update local state
    _user = _user!.copyWith(isOnline: isOnline, lastSeen: lastSeen);
    notifyListeners();

    // Update remote
    try {
      await _userRepository.updateUserFields(_user!.id, {
        'isOnline': isOnline,
        'lastSeen': lastSeen?.toIso8601String(),
      });
    } catch (e) {
      print("Failed to update online status: $e");
    }
  }
}
