import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AppAuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  bool _isLoading = false;

  // 🟢 1. CONSTRUCTOR: Koute Firebase auth state le app la demare!
  AppAuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners(); // Sa di GoRouter ke statu a chanje pou l fè redirection san l pa rete kwense
    });
  }

  // Getters
  User? get currentUser => _auth.currentUser;
  User? get user => _user ?? _auth.currentUser; // Fè sekirite si _user fenk ap chaje
  bool get isLoading => _isLoading;
  bool get isAuthenticated => (_user ?? _auth.currentUser) != null;

  // Enskripsyon
  Future<String?> register(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      User? newUser = await _authService.signUp(email, password);
      
      // 🟢 Update _user le register fin fèt
      _user = newUser ?? _auth.currentUser;
      _isLoading = false;
      notifyListeners();

      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();

      switch (e.code) {
        case 'email-already-in-use':
          return "Cette adresse e-mail est déjà utilisée.";

        case 'invalid-email':
          return "Adresse e-mail invalide.";

        case 'weak-password':
          return "Le mot de passe doit contenir au moins 6 caractères.";

        case 'network-request-failed':
          return "Vérifiez votre connexion Internet.";

        default:
          return e.message ?? "Une erreur est survenue.";
      }
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return "Une erreur est survenue.";
    }
  }

  // 🔑 Fonksyon pou voye e-mail reset password
  Future<String?> sendPasswordResetEmail(String email) async {
    if (email.trim().isEmpty) {
      return "Veuillez entrer votre adresse e-mail.";
    }

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return "Aucun utilisateur trouvé avec cette adresse e-mail.";
        case 'invalid-email':
          return "L'adresse e-mail n'est pas valide.";
        default:
          return e.message ?? "Une erreur est survenue.";
      }
    } catch (e) {
      return "Une erreur inattendue est survenue.";
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
      _isLoading = false;
      notifyListeners();
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