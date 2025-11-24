import 'package:flutter/material.dart';
import 'package:cconnect/data/models/userModel.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  User? get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  // Helper to fetch other users (not the current user)
  Future<User?> fetchUserById(String id) async {
    // This should ideally be in a Repository, but for quick access in UI:
    // We can use the existing FirebaseUserRepository.
    // Since we can't easily inject repo here without more boilerplate, 
    // we'll instantiate it or pass it. 
    // Actually, let's just use the repo directly here for now.
    // But wait, UserProvider shouldn't depend on Repo directly if we want clean architecture.
    // However, for this MVP fix, I'll allow it or better, use the ChatController?
    // The ChatScreen has access to ChatController. 
    // Let's move this logic to ChatController or just use a Repository in the FutureBuilder.
    return null; 
  }
}
