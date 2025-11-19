import 'package:cconnect/data/models/userModel.dart';

abstract class IAuthRepository {
  Future<User> signInWithGoogle();

  /// Sign up using email & password; returns CampusConnect User mapped from Firebase user.
  Future<User> signUpWithEmail(String email, String password);

  /// Sign in using email & password.
  Future<User> signInWithEmail(String email, String password);

  /// Sign out current user.
  Future<void> signOut();

  /// Returns current signed in CampusConnect User or null.
  Future<User?> currentUser();

  /// Throws if email is not a valid university email. Implement validation rules here.
  Future<void> requireUniversityEmail(String email);

  /// Send email verification to currently signed-in user.
  Future<void> sendEmailVerification();

  /// Reload the current firebase user (refresh token / info).
  Future<void> reloadUser();

  /// Check if current user has verified their email.
  Future<bool> isEmailVerified();

  /// Send password reset email (forgot password).
  Future<void> resetPassword(String email);

  /// Delete current user.
  Future<void> deleteUser();

  /// Update current user's password (the caller must be recently authenticated).
  Future<void> updatePassword(String newPassword);
}
