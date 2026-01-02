import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _user;
  bool _isReady = false;

  AuthProvider() {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _isReady = true;
      notifyListeners();
    });
  }

  bool get isReady => _isReady;
  bool get isLoggedIn => _user != null;
  User? get user => _user;

  String? get email => _user?.email;
  String? get username => _user?.displayName;

  String get displayName {
    if (_user?.displayName != null && _user!.displayName!.isNotEmpty) {
      return _user!.displayName!;
    }
    final email = _user?.email;
    if (email != null) {
      return email.split('@')[0];
    }
    return 'User';
  }

  // --- GİRİŞ METOTLARI ---

  Future<void> registerWithEmail(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> loginWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } catch (e) {
      print("Google Sign-In Error: $e");
      rethrow;
    }
  }

  // --- İŞTE EKSİK OLAN FONKSİYON BU ---
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    notifyListeners();
  }
}
