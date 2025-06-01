import 'package:demande_admission/screens/admin/dashboard_screen.dart';
import 'package:demande_admission/screens/admin/requests_screens.dart';
import 'package:demande_admission/screens/admin/users_screen.dart';
import 'package:demande_admission/screens/auth_wrapper.dart';
import 'package:demande_admission/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://xoxsjoeqdjbjgplruvgv.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhveHNqb2VxZGpiamdwbHJ1dmd2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg3MzY5NjksImV4cCI6MjA2NDMxMjk2OX0.3e3yPhY7FAHQ8FJtTNEBBT1jzV_eb6UyFG73wUBwcsc',
  );
  runApp(
    MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      //home: AuthWrapper(),
      home: AdminDashboardScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/admin/home': (context) => AdminDashboardScreen(),
        '/admin/users': (context) => UsersScreen(),
        '/admin/requests': (context) => RequestsScreens(),
      },
    ),
  );
}
