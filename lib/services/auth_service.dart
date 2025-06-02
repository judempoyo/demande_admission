import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  String _getErrorMessage(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Email ou mot de passe incorrect';
    } else if (message.contains('User already registered')) {
      return 'Email déjà utilisé';
    } else if (message.contains('Email rate limit exceeded')) {
      return 'Trop de tentatives. Veuillez réessayer plus tard.';
    }
    return 'Erreur d\'authentification: $message';
  }

  Future<void> _createProfile(User user, {String role = 'student'}) async {
    try {
      await _client.from('profiles').upsert({
        'id': user.id,
        'email': user.email,
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Erreur création profil: $e');
      rethrow;
    }
  }

  // Inscription Email/Mot de passe
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _createProfile(response.user!);
      }

      return response.user;
    } on AuthException catch (e) {
      throw _getErrorMessage(e.message);
    }
  }

  // Création d'un utilisateur par un admin
  Future<User?> createUser(
    String email,
    String password, {
    String role = 'student',
  }) async {
    try {
      final response = await _client.auth.admin.createUser(
        AdminUserAttributes(
          email: email,
          password: password,
          emailConfirm: true,
        ),
      );

      if (response.user != null) {
        await _client.from('profiles').upsert({
          'id': response.user!.id,
          'email': response.user!.email,
          'role': role,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      return response.user;
    } on AuthException catch (e) {
      throw _getErrorMessage(e.message);
    }
  }

  // Connexion avec Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      if (response.user != null) {
        // Vérifie d'abord si le profil existe déjà
        final existingProfile =
            await _client
                .from('profiles')
                .select()
                .eq('id', response.user!.id)
                .maybeSingle();

        if (existingProfile == null) {
          await _createProfile(response.user!);
        }
      }

      return response.user;
    } catch (e) {
      throw "Erreur lors de la connexion avec Google";
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user?.emailConfirmedAt == null) {
        await signOut();
        throw "Votre compte n'a pas encore été confirmé. Veuillez vérifier vos emails.";
      }

      return response.user;
    } on AuthException catch (e) {
      throw _getErrorMessage(e.message);
    }
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
