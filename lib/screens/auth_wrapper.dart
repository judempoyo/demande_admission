import 'package:demande_admission/screens/admin/dashboard_screen.dart';
import 'package:demande_admission/screens/home_screen.dart';
import 'package:demande_admission/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final session = snapshot.data?.session;
        if (session != null) {
          //return HomeScreen(); // Écran après connexion
          return DashboardScreen();
        }
        return LoginScreen(); // Écran de connexion
      },
    );
  }
}
