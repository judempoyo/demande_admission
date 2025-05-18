import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Connexion Email/Mot de passe
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _getErrorMessage(e.code);
    }
  }

  // Inscription Email/Mot de passe
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _getErrorMessage(e.code);
    }
  }

  // Connexion Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential authResult = await _auth.signInWithCredential(credential);
      return authResult.user;
    } catch (e) {
      throw "Erreur lors de la connexion Google";
    }
  }

  // Gestion des erreurs
  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Email non trouvé';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'email-already-in-use':
        return 'Email déjà utilisé';
      default:
        return 'Erreur inconnue';
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Écoute des changements d'état
  Stream<User?> get userStream => _auth.authStateChanges();
}
