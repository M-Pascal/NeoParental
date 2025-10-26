import '../models/user_model.dart';

/// Service class for handling Authentication (non-Firebase version)
/// This is a mock/local authentication service
///
/// BYPASS MODE ENABLED:
/// - No registration required
/// - Any email/password combination will work
/// - Users are auto-created on first login
/// - Perfect for testing and demos
class AuthService {
  // Mock user storage (in production, use local storage or a backend)
  final Map<String, Map<String, dynamic>> _users = {};
  UserModel? _currentUser;

  /// Get current user
  UserModel? get currentUser => _currentUser;

  /// Stream of authentication state changes (simplified)
  Stream<UserModel?> get authStateChanges async* {
    yield _currentUser;
  }

  /// Sign up with email and password
  ///
  /// Throws [AuthException] if registration fails
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    // Validate inputs
    if (!isValidEmail(email)) {
      throw AuthException('Invalid email address');
    }

    final passwordError = validatePassword(password);
    if (passwordError != null) {
      throw AuthException(passwordError);
    }

    // Check if user already exists
    if (_users.containsKey(email)) {
      throw AuthException('An account already exists with this email');
    }

    // Create new user
    final uid = DateTime.now().millisecondsSinceEpoch.toString();
    final user = UserModel(
      uid: uid,
      email: email,
      displayName: fullName,
      photoUrl: null,
    );

    // Store user credentials (in production, hash the password!)
    _users[email] = {
      'uid': uid,
      'email': email,
      'displayName': fullName,
      'password':
          password, // WARNING: Don't store plain text passwords in production!
    };

    _currentUser = user;
    return user;
  }

  /// Sign in with email and password
  ///
  /// BYPASS MODE: Accepts any email/password combination
  /// No registration required - automatically creates user on first login
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // BYPASS: Auto-create user if they don't exist
    if (!_users.containsKey(email)) {
      // Automatically register the user
      final uid = DateTime.now().millisecondsSinceEpoch.toString();
      _users[email] = {
        'uid': uid,
        'email': email,
        'displayName': email.split('@')[0], // Use email prefix as name
        'password': password,
      };
    }

    // Create user model (bypass password check - accept any password)
    final userData = _users[email]!;
    _currentUser = UserModel(
      uid: userData['uid'],
      email: userData['email'],
      displayName: userData['displayName'],
      photoUrl: null,
    );

    return _currentUser!;
  }

  /// Sign out current user
  ///
  /// Throws [AuthException] if sign out fails
  Future<void> signOut() async {
    _currentUser = null;
  }

  /// Send password reset email (mock)
  ///
  /// Throws [AuthException] if sending reset email fails
  Future<void> sendPasswordResetEmail(String email) async {
    if (!_users.containsKey(email)) {
      throw AuthException('No account found with this email');
    }
    // In production, send actual email
    // For now, just simulate success
  }

  /// Check if user exists with given email
  Future<bool> checkUserExists(String email) async {
    return _users.containsKey(email);
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate password strength
  ///
  /// BYPASS MODE: Minimal validation - accepts any non-empty password
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }
    // BYPASS: Accept any password as long as it's not empty
    // Original requirement was 6+ chars, but now accepts any length
    return null;
  }
}

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}
