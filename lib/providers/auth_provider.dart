import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple persisted authentication state for a demo login flow.
///
/// This app does not validate credentials. We store the login flag and basic
/// profile fields locally so:
/// - the login screen is shown on first launch,
/// - it is skipped on subsequent launches,
/// - tapping the user icon can "switch user" by signing out.
class AuthProvider extends ChangeNotifier {
  static const _kLoggedInKey = 'auth.logged_in';
  static const _kEmailKey = 'auth.email';
  static const _kUsernameKey = 'auth.username';

  bool _isReady = false;
  bool _isLoggedIn = false;
  String? _email;
  String? _username;

  AuthProvider() {
    _init();
  }

  bool get isReady => _isReady;
  bool get isLoggedIn => _isLoggedIn;
  String? get email => _email;
  String? get username => _username;

  String get displayName {
    // Prefer explicit username, fall back to the email local-part.
    final name = _username;
    if (name != null && name.trim().isNotEmpty) return name.trim();

    final value = _email;
    if (value == null || value.trim().isEmpty) return 'User';
    final atIndex = value.indexOf('@');
    final localPart = (atIndex > 0) ? value.substring(0, atIndex) : value;
    if (localPart.isEmpty) return 'User';
    return localPart[0].toUpperCase() + localPart.substring(1);
  }

  Future<void> _init() async {
    // Load persisted auth state.
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(_kLoggedInKey) ?? false;
    _email = prefs.getString(_kEmailKey);
    _username = prefs.getString(_kUsernameKey);
    _isReady = true;
    notifyListeners();
  }

  Future<void> signIn({required String email, String? username}) async {
    // Persist sign-in.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLoggedInKey, true);
    await prefs.setString(_kEmailKey, email);

    final trimmedUsername = username?.trim();
    if (trimmedUsername != null && trimmedUsername.isNotEmpty) {
      await prefs.setString(_kUsernameKey, trimmedUsername);
      _username = trimmedUsername;
    } else {
      await prefs.remove(_kUsernameKey);
      _username = null;
    }

    _isLoggedIn = true;
    _email = email;
    notifyListeners();
  }

  Future<void> signOut() async {
    // Clear persisted auth state.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLoggedInKey, false);
    await prefs.remove(_kEmailKey);
    await prefs.remove(_kUsernameKey);
    _isLoggedIn = false;
    _email = null;
    _username = null;
    notifyListeners();
  }
}
