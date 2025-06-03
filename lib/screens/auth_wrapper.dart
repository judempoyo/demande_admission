import 'package:demande_admission/screens/admin/dashboard_screen.dart';
import 'package:demande_admission/screens/home_screen.dart';
import 'package:demande_admission/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Vérifie si l'utilisateur est connecté
        final session = supabase.auth.currentSession;
        final user = supabase.auth.currentUser;

        if (session == null || user == null) {
          return LoginScreen();
        }

        // Vérifie le rôle de l'utilisateur
        return FutureBuilder<Map<String, dynamic>?>(
          future: _getUserProfile(user.id),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (profileSnapshot.hasError || !profileSnapshot.hasData) {
              return HomeScreen();
            }

            final isAdmin = profileSnapshot.data?['role'] == 'admin';
            return isAdmin ? DashboardScreen() : HomeScreen();
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
      debugPrint('Erreur récupération profil: $e');
      return null;
    }
  }
}
