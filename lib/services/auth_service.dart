import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==========================
  // Inscription
  // ==========================
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await result.user?.sendEmailVerification();

      return result.user;
    } on FirebaseAuthException {
      // Enpòtan: remonte erè Firebase a san modifye li
      rethrow;
    }
  }

  // ==========================
  // Connexion
  // ==========================
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // ==========================
  // Déconnexion
  // ==========================
  Future<void> signOut() async {
    await _auth.signOut();
  }
}