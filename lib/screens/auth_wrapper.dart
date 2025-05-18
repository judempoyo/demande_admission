import 'package:demande_admission/screens/home_screen.dart';
import 'package:demande_admission/screens/login_screen.dart';
import 'package:demande_admission/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasData) {
          return HomeScreen(); // Écran après connexion
        }
        return LoginScreen(); // Écran de connexion
      },
    );
  }
}
