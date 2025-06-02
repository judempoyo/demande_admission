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
  late final Stream<AuthState> _authStream;
  //late final Stream<List<Map<String, dynamic>>> _profileStream;

  @override
  void initState() {
    super.initState();
    _authStream = Supabase.instance.client.auth.onAuthStateChange;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: _authStream,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final session = authSnapshot.data?.session;
        if (session != null) {
          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: _getProfileStream(session.user.id),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (profileSnapshot.hasError || !profileSnapshot.hasData) {
                return HomeScreen();
              }

              final isAdmin =
                  profileSnapshot.data!.firstOrNull?['role'] == 'admin';
              return isAdmin ? DashboardScreen() : HomeScreen();
            },
          );
        }
        return LoginScreen();
      },
    );
  }

  Stream<List<Map<String, dynamic>>> _getProfileStream(String userId) {
    return Supabase.instance.client
        .from('profiles')
        .stream(primaryKey: ['user_id'])
        .eq('user_id', userId)
        .limit(1);
  }
}
