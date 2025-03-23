// import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user.dart';

class AuthService extends ChangeNotifier {
  // final firebase_auth.FirebaseAuth _firebaseAuth =
  //     firebase_auth.FirebaseAuth.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  User? _currentUser;
  bool _isPinVerified = false;
  String? _pin;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isPinVerified => _isPinVerified;
  bool get hasPinSet => _pin != null && _pin!.isNotEmpty;

  Future<void> init() async {
    // Check if the user is already logged in
    // final user = _firebaseAuth.currentUser;
    // if (user != null) {
    //   _currentUser = User.fromFirebase(user);
    // }

    // Check for locally stored user info
    final userEmail = await _secureStorage.read(key: 'user_email');
    final userName = await _secureStorage.read(key: 'user_name');

    if (userEmail != null) {
      _currentUser = User(
        id: userEmail,
        email: userEmail,
        displayName: userName ?? 'User',
      );
    }

    // Check if PIN is set
    _pin = await _secureStorage.read(key: 'pin');

    // Auto-verify PIN if it's not set (first-time users)
    if (_pin == null || _pin!.isEmpty) {
      _isPinVerified = true;
    }

    notifyListeners();
  }

  // Local auth methods
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Check stored credentials
      final storedEmail = await _secureStorage.read(key: 'user_email');
      final storedPassword = await _secureStorage.read(key: 'user_password');

      if (email == storedEmail && password == storedPassword) {
        final userName = await _secureStorage.read(key: 'user_name');
        _currentUser = User(
          id: email,
          email: email,
          displayName: userName ?? 'User',
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      // Store credentials locally
      await _secureStorage.write(key: 'user_email', value: email);
      await _secureStorage.write(key: 'user_password', value: password);
      await _secureStorage.write(key: 'user_name', value: 'User');

      _currentUser = User(
        id: email,
        email: email,
        displayName: 'User',
      );
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Sign up error: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      // No need to sign out from Firebase
      _currentUser = null;
      _isPinVerified = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  // PIN management
  Future<bool> verifyPin(String pin) async {
    if (_pin == pin) {
      _isPinVerified = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> setPin(String pin) async {
    try {
      await _secureStorage.write(key: 'pin', value: pin);
      _pin = pin;
      _isPinVerified = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Set PIN error: $e');
      return false;
    }
  }

  Future<bool> resetPin(String newPin) async {
    try {
      await _secureStorage.write(key: 'pin', value: newPin);
      _pin = newPin;
      _isPinVerified = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Reset PIN error: $e');
      return false;
    }
  }

  // Reset PIN using email method (without Firebase)
  Future<bool> sendPinResetEmail() async {
    try {
      // Instead of sending an email, just reset the PIN to a default value
      // In a real app, you might want to implement a different recovery method
      await _secureStorage.write(key: 'pin', value: '0000');
      _pin = '0000';
      debugPrint('PIN has been reset to default: 0000');
      return true;
    } catch (e) {
      debugPrint('Reset PIN error: $e');
      return false;
    }
  }

  // Update user profile locally
  Future<bool> updateUserProfile(String name) async {
    try {
      await _secureStorage.write(key: 'user_name', value: name);
      if (_currentUser != null) {
        _currentUser = User(
          id: _currentUser!.id,
          email: _currentUser!.email,
          displayName: name,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Update profile error: $e');
      return false;
    }
  }
}
