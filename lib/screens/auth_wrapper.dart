import 'package:demande_admission/screens/admin/dashboard_screen.dart';
import 'package:demande_admission/screens/home_screen.dart';
import 'package:demande_admission/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Vérification de l'état de connexion
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = supabase.auth.currentSession;
        final user = supabase.auth.currentUser;

        // Si non connecté, afficher l'écran de connexion
        if (session == null || user == null) {
          return LoginScreen();
        }

        // Si connecté, vérifier le rôle
        return FutureBuilder<Map<String, dynamic>?>(
          future: _getUserProfile(user.id),
          builder: (context, profileSnapshot) {
            // Gestion des états de chargement
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // Gestion des erreurs ou données manquantes
            if (profileSnapshot.hasError || !profileSnapshot.hasData) {
              return HomeScreen();
            }

            final profileData = profileSnapshot.data!;
            final isAdmin = profileData['role'] == 'admin';

            return isAdmin ? const DashboardScreen() : HomeScreen();
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _getUserProfile(String userId) async {
    try {
      final response =
          await Supabase.instance.client
              .from('profiles')
              .select()
              .eq('user_id', userId)
              .single();

      return response;
    } catch (e) {
      debugPrint('Erreur lors de la récupération du profil: $e');
      return null;
    }
  }
}
