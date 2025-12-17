import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(_kLoggedInKey) ?? false;
    _email = prefs.getString(_kEmailKey);
    _username = prefs.getString(_kUsernameKey);
    _isReady = true;
    notifyListeners();
  }

  Future<void> signIn({required String email, String? username}) async {
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
