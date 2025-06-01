import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Connexion Email/Mot de passe
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    } on AuthException catch (e) {
      throw _getErrorMessage(e.message);
    }
  }

  // Inscription Email/Mot de passe
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      return response.user;
    } on AuthException catch (e) {
      throw _getErrorMessage(e.message);
    }
  }

  // Gestion des erreurs
  String _getErrorMessage(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Email ou mot de passe incorrect';
    } else if (message.contains('User already registered')) {
      return 'Email déjà utilisé';
    }
    return 'Erreur d\'authentification';
  }

  // Déconnexion
  Future<void> signOut() async {
    await _client.auth.signOut();
    await _googleSignIn.signOut();
  }

  // Écoute des changements d'état
  Stream<User?> get userStream =>
      _client.auth.onAuthStateChange.map((event) => event.session?.user);
}
