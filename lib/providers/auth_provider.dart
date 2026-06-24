import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

// Chanje non klas la an AppAuthProvider
class AppAuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  bool _isLoading = false;

  // Getters
  User? get currentUser => _auth.currentUser;
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  // Enskripsyon
  Future<String?> register(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signUp(email, password);
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return "Erè enskripsyon: ${e.toString()}";
    }
  }

  // Koneksyon
  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      User? user = await _authService.signIn(email, password);
      if (user != null) {
        _user = user;
        _isLoading = false;
        notifyListeners();
        return null;
      }
      return "Erè koneksyon.";
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return "Identifiants invalides.";
    }
  }

  // Dekoneksyon
  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  // Tcheke verifikasyon imèl
  Future<bool> checkEmailVerification() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      if (user.emailVerified) {
        _user = user;
        notifyListeners();
        return true;
      }
    }
    return false;
  }
}