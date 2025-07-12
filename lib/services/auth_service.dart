import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Messages d'erreur centralisés
  static const _invalidCredentials = 'Email ou mot de passe incorrect';
  static const _emailAlreadyUsed = 'Email déjà utilisé';
  static const _rateLimitExceeded =
      'Trop de tentatives. Veuillez réessayer plus tard.';
  static const _emailNotConfirmed =
      'Votre compte n\'a pas encore été confirmé. Veuillez vérifier vos emails.';
  static const _googleSignInError = 'Erreur lors de la connexion avec Google';
  static const _profileCreationError = 'Erreur lors de la création du profil';

  String _getErrorMessage(String message) {
    if (message.contains('Invalid login credentials')) {
      return _invalidCredentials;
    } else if (message.contains('User already registered')) {
      return _emailAlreadyUsed;
    } else if (message.contains('Email rate limit exceeded')) {
      return _rateLimitExceeded;
    }
    return 'Erreur d\'authentification: $message';
  }

  Future<void> _createProfile(User user, {String role = 'student'}) async {
    try {
      final response =
          await _client.from('profiles').upsert({
            'user_id': user.id,
            'email': user.email,
            'role': role,
            'created_at': DateTime.now().toIso8601String(),
          }).select();

      if (response.isEmpty) {
        throw 'Failed to create profile';
      }
    } catch (e) {
      debugPrint('Profile creation error: $e');
      throw 'Failed to setup user profile';
    }
  }

  Future<User?> registerWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'email': email},
      );

      if (response.user != null) {
        await _client.from('profiles').insert({
          'user_id': response.user!.id,
          'email': email,
          'role': 'student',
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      return response.user;
    } on AuthException catch (e) {
      throw _handleAuthError(e.message);
    } catch (e) {
      throw 'Registration failed: ${e.toString()}';
    }
  }

  String _handleAuthError(String message) {
    if (message.contains('User already registered')) {
      return 'Email already in use';
    }
    return 'Authentication error: $message';
  }

  // Connexion avec Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw 'Impossible d\'obtenir le token Google';
      }

      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      if (response.user != null) {
        final existingProfile =
            await _client
                .from('profiles')
                .select()
                .eq(
                  'user_id',
                  response.user!.id,
                ) // Correction: cohérence avec le champ utilisé
                .maybeSingle();

        if (existingProfile == null) {
          await _createProfile(response.user!);
        }
      }

      return response.user;
    } on AuthException catch (e) {
      throw _getErrorMessage(e.message);
    } catch (e) {
      throw _googleSignInError;
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final existingProfile =
          await _client
              .from('profiles')
              .select()
              .eq('user_id', response.user!.id)
              .maybeSingle();

      if (existingProfile == null) {
        await _createProfile(response.user!);
      }

      return response.user;
    } on AuthException catch (e) {
      throw _getErrorMessage(e.message);
    } catch (e) {
      throw 'Erreur inattendue lors de la connexion';
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      await Future.wait([_client.auth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion: $e');
      rethrow;
    }
  }

  // Écoute des changements d'état
  Stream<User?> get userStream =>
      _client.auth.onAuthStateChange
          .map((event) => event.session?.user)
          .distinct();
}
