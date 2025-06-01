import 'package:demande_admission/screens/profile_tab.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;
  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

  final List<Widget> _screens = [
    Text('dashboard'),
    Text('users'),
    Text('requests'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Administration',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF006D77),
        elevation: 0,
        centerTitle: true,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileTab()),
              );
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            selectedItemColor: Color(0xFF006D77),
            unselectedItemColor: Colors.grey.shade600,
            showUnselectedLabels: true,
            elevation: 10,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color:
                        _currentIndex == 0
                            ? Color(0xFF006D77).withOpacity(0.2)
                            : Colors.transparent,
                  ),
                  child: Icon(Icons.dashboard_outlined),
                ),
                activeIcon: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xFF006D77).withOpacity(0.2),
                  ),
                  child: Icon(Icons.dashboard),
                ),
                label: 'Tableau de bord',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color:
                        _currentIndex == 1
                            ? Color(0xFF006D77).withOpacity(0.2)
                            : Colors.transparent,
                  ),
                  child: Icon(Icons.school_outlined),
                ),
                activeIcon: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xFF006D77).withOpacity(0.2),
                  ),
                  child: Icon(Icons.school),
                ),
                label: 'Demandes',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color:
                        _currentIndex == 1
                            ? Color(0xFF006D77).withOpacity(0.2)
                            : Colors.transparent,
                  ),
                  child: Icon(Icons.supervised_user_circle_outlined),
                ),
                activeIcon: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xFF006D77).withOpacity(0.2),
                  ),
                  child: Icon(Icons.supervised_user_circle),
                ),
                label: 'Utilisateurs',
              ),
            ],
            onTap: (index) => setState(() => _currentIndex = index),
          ),
        ),
      ),
    );
  }
}
