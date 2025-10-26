import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

/// Service class for handling Firebase Authentication
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user
  UserModel? get currentUser {
    final User? firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? '',
      photoUrl: firebaseUser.photoURL,
    );
  }

  /// Stream of authentication state changes
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().map((User? firebaseUser) {
      if (firebaseUser == null) return null;

      return UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? '',
        photoUrl: firebaseUser.photoURL,
      );
    });
  }

  /// Sign up with email and password
  ///
  /// Throws [AuthException] if registration fails
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // Validate inputs
      if (!isValidEmail(email)) {
        throw AuthException('Invalid email address');
      }

      final passwordError = validatePassword(password);
      if (passwordError != null) {
        throw AuthException(passwordError);
      }

      // Create user with Firebase Auth
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update user profile with display name
      await userCredential.user?.updateDisplayName(fullName);
      await userCredential.user?.reload();

      final User? firebaseUser = _auth.currentUser;

      if (firebaseUser == null) {
        throw AuthException('Failed to create user account');
      }

      return UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? email,
        displayName: fullName,
        photoUrl: firebaseUser.photoURL,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getFirebaseErrorMessage(e.code));
    } catch (e) {
      throw AuthException('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Sign in with email and password
  ///
  /// Throws [AuthException] if sign in fails
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw AuthException('Failed to sign in');
      }

      return UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? email,
        displayName: firebaseUser.displayName ?? email.split('@')[0],
        photoUrl: firebaseUser.photoURL,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getFirebaseErrorMessage(e.code));
    } catch (e) {
      throw AuthException('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Sign out current user
  ///
  /// Throws [AuthException] if sign out fails
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getFirebaseErrorMessage(e.code));
    } catch (e) {
      throw AuthException('Failed to sign out: ${e.toString()}');
    }
  }

  /// Send password reset email
  ///
  /// Throws [AuthException] if sending reset email fails
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getFirebaseErrorMessage(e.code));
    } catch (e) {
      throw AuthException(
        'Failed to send password reset email: ${e.toString()}',
      );
    }
  }

  /// Check if user exists with given email
  Future<bool> checkUserExists(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate password strength
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Convert Firebase error codes to user-friendly messages
  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-credential':
        return 'Invalid email or password';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return 'Authentication failed. Please try again';
    }
  }
}

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}
