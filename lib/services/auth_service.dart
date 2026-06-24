import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Enskripsyon ak voye imèl konfimasyon
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      // Voye imèl konfimasyon an fransè
      await result.user!.sendEmailVerification();
      return result.user;
    } catch (e) {
      throw Exception("Erreur lors de l'inscription : ${e.toString()}");
    }
  }

  // Koneksyon
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return result.user;
    } catch (e) {
      throw Exception("Erreur de connexion : ${e.toString()}");
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}