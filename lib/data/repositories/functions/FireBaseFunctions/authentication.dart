import 'package:cconnect/data/models/userModel.dart';
import 'package:cconnect/data/repositories/interfaces/iauth.dart';
import 'package:cconnect/utils/helpers/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cconnect/utils/constraints/enums.dart';

class FirebaseAuthRepository implements IAuthRepository {
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;

  /// Allowed university email domains — adjust to your university domains
  final List<String> _allowedDomains = ['lhr.nu.edu.pk'];

  // ---------------------
  // Sign up
  // ---------------------
  @override
  Future<User> signUpWithEmail(String email, String password) async {
    try {
      await requireUniversityEmail(email);

      final fb.UserCredential credential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      final fb.User? fUser = credential.user;
      if (fUser == null) throw Exception('Failed to create user.');

      // Send verification email (do not await to block long UX; but handle errors)
      await sendEmailVerification();

      final campusUser = _mapFirebaseToCampusUser(fUser);
      SnackbarService.success('Account created. Verification email sent.');

      return campusUser;
    } on fb.FirebaseAuthException catch (e) {
      final msg = _mapFirebaseAuthExceptionToErrorMessage(e);
      SnackbarService.error(msg);
      throw Exception(msg);
    } catch (e) {
      final msg = e.toString();
      SnackbarService.error(msg);
      throw Exception(msg);
    }
  }

  // ---------------------
  // Sign in
  // ---------------------
  @override
  Future<User> signInWithEmail(String email, String password) async {
    try {
      final fb.UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      final fb.User? fUser = userCredential.user;
      if (fUser == null) throw Exception('Sign-in failed.');

      final campusUser = _mapFirebaseToCampusUser(fUser);
      SnackbarService.success('Welcome back, ${campusUser.displayName}');
      return campusUser;
    } on fb.FirebaseAuthException catch (e) {
      final msg = _mapFirebaseAuthExceptionToErrorMessage(e);
      SnackbarService.error(msg);
      throw Exception(msg);
    } catch (e) {
      final msg = e.toString();
      SnackbarService.error(msg);
      throw Exception(msg);
    }
  }

  // ---------------------
  // Sign out
  // ---------------------
  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      SnackbarService.success('Signed out successfully.');
    } on fb.FirebaseAuthException catch (e) {
      final msg = _mapFirebaseAuthExceptionToErrorMessage(e);
      SnackbarService.error(msg);
      throw Exception(msg);
    } catch (e) {
      final msg = e.toString();
      SnackbarService.error(msg);
      throw Exception(msg);
    }
  }

  // ---------------------
  // Current user
  // ---------------------
  @override
  Future<User?> currentUser() async {
    final fb.User? fUser = _firebaseAuth.currentUser;
    if (fUser == null) return null;
    return _mapFirebaseToCampusUser(fUser);
  }

  // ---------------------
  // University email validation
  // ---------------------
  @override
  Future<void> requireUniversityEmail(String email) async {
    try {
      final parts = email.split('@');
      if (parts.length != 2) throw Exception('Invalid email format.');
      final domain = parts[1].toLowerCase();
      final allowed = _allowedDomains.contains(domain);
      if (!allowed) {
        throw Exception(
          'Please use your university email (allowed domains: ${_allowedDomains.join(", ")})',
        );
      }
    } catch (e) {
      final msg = e.toString();
      SnackbarService.error(msg);
      throw Exception(msg);
    }
  }

  // ---------------------
  // Email verification
  // ---------------------
  @override
  Future<void> sendEmailVerification() async {
    try {
      final fb.User? user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('No user is signed in.');
      if (user.emailVerified) {
        SnackbarService.info('Email already verified.');
        return;
      }
      await user.sendEmailVerification();
      SnackbarService.info('Verification email sent. Check your inbox.');
    } on fb.FirebaseAuthException catch (e) {
      final msg = _mapFirebaseAuthExceptionToErrorMessage(e);
      SnackbarService.error(msg);
      throw Exception(msg);
    } catch (e) {
      final msg = e.toString();
      SnackbarService.error(msg);
      throw Exception(msg);
    }
  }

  @override
  Future<void> reloadUser() async {
    try {
      final fb.User? user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.reload();
        SnackbarService.info('User reloaded.');
      }
    } catch (e) {
      final msg = e.toString();
      SnackbarService.error(msg);
      throw Exception(msg);
    }
  }

  @override
  Future<bool> isEmailVerified() async {
    try {
      await reloadUser(); // ensure fresh state
      final fb.User? user = _firebaseAuth.currentUser;
      final verified = user?.emailVerified ?? false;
      if (verified) {
        SnackbarService.success('Email is verified.');
      } else {
        SnackbarService.info('Email not verified yet.');
      }
      return verified;
    } catch (e) {
      final msg = e.toString();
      SnackbarService.error(msg);
      return false;
    }
  }

  // ---------------------
  // Reset password / forgot password
  // ---------------------
  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      SnackbarService.success('Password reset email sent.');
    } on fb.FirebaseAuthException catch (e) {
      final msg = _mapFirebaseAuthExceptionToErrorMessage(e);
      SnackbarService.error(msg);
      throw Exception(msg);
    } catch (e) {
      final msg = e.toString();
      SnackbarService.error(msg);
      throw Exception(msg);
    }
  }

  // ---------------------
  // Delete & update password helpers
  // ---------------------
  @override
  Future<void> deleteUser() async {
    try {
      final fb.User? user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('No user signed in.');
      await user.delete();
      SnackbarService.info('Account deleted.');
    } on fb.FirebaseAuthException catch (e) {
      final msg = _mapFirebaseAuthExceptionToErrorMessage(e);
      SnackbarService.error(msg);
      throw Exception(msg);
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      final fb.User? user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('No user signed in.');
      await user.updatePassword(newPassword);
      SnackbarService.success('Password updated successfully.');
    } on fb.FirebaseAuthException catch (e) {
      final msg = _mapFirebaseAuthExceptionToErrorMessage(e);
      SnackbarService.error(msg);
      throw Exception(msg);
    }
  }

  // ---------------------
  // Helpers
  // ---------------------
  User _mapFirebaseToCampusUser(fb.User fUser) {
    return User(
      id: fUser.uid,
      displayName:
          fUser.displayName ?? (fUser.email?.split('@').first ?? 'User'),
      email: fUser.email ?? '',
      photoUrl: fUser.photoURL,
      lastSeen: DateTime.now(),
      role: UserRole.student,
      metadata: {},
    );
  }

  String _mapFirebaseAuthExceptionToErrorMessage(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email address is already registered. Try signing in instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled. Please contact support.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters with letters and numbers.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'user-not-found':
        return 'No account found with this email. Please sign up first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again or reset your password.';
      case 'requires-recent-login':
        return 'This action requires recent authentication. Please sign in again.';
      case 'credential-already-in-use':
        return 'This credential is already associated with another account.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please wait a moment and try again.';
      case 'invalid-user-token':
      case 'user-token-expired':
        return 'Your session has expired. Please sign in again.';
      case 'invalid-action-code':
        return 'Invalid or expired verification code.';
      case 'expired-action-code':
        return 'Verification code has expired. Please request a new one.';
      default:
        return e.message ??
            'An unexpected error occurred. Please try again later.';
    }
  }

  @override
  Future<User> signInWithGoogle() {
    // TODO: implement signInWithGoogle
    throw UnimplementedError();
  }
}
