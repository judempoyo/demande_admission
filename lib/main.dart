import 'package:demande_admission/screens/admin/admin_profile_screen.dart';
import 'package:demande_admission/screens/admin/dashboard_screen.dart';
import 'package:demande_admission/screens/admin/requests_screens.dart';
import 'package:demande_admission/screens/admin/users_screen.dart';
import 'package:demande_admission/screens/auth_wrapper.dart';
import 'package:demande_admission/screens/home_screen.dart';
//import 'package:demande_admission/screens/profile_tab.dart';
import 'package:demande_admission/services/admin_service.dart';
import 'package:demande_admission/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://sqrfqomhptnrjgtcskvm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNxcmZxb21ocHRucmpndGNza3ZtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIyNzkxODUsImV4cCI6MjA2Nzg1NTE4NX0.GTjouqu_S_TdfleDRLivjBY29DDn0MhT5Iov6pI3klA',
  );

  runApp(
    MultiProvider(
      // Utilisez MultiProvider pour gérer plusieurs providers
      providers: [ChangeNotifierProvider(create: (_) => AdminService())],
      child: MaterialApp(
        theme: appTheme,
        home: AuthWrapper(),
        //home: DashboardScreen(),
        routes: {
          '/home': (context) => HomeScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/requests': (context) => const RequestsScreen(),
          '/users': (context) => const UsersScreen(),
          //'/profile': (context) => ProfileTab(),
          '/admin/profile': (context) => AdminProfileScreen(),
        },
      ),
    ),
  );
}
