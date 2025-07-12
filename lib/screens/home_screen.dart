import 'package:demande_admission/screens/profile_tab.dart';
import 'package:demande_admission/screens/request_detail_screen.dart';
import 'package:demande_admission/screens/request_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:demande_admission/models/admission_request.dart';
import 'package:demande_admission/services/database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

  final List<Widget> _screens = [DashboardTab(), ProfileTab()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Mon Espace Admission',
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
      ),
      body: _screens[_currentIndex],
      floatingActionButton:
          _currentIndex == 0
              ? FloatingActionButton(
                backgroundColor: Color(0xFF006D77),
                child: Icon(Icons.add, color: Colors.white),
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RequestFormScreen()),
                    ),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              )
              : null,
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
                  child: Icon(Icons.home_outlined),
                ),
                activeIcon: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xFF006D77).withOpacity(0.2),
                  ),
                  child: Icon(Icons.home),
                ),
                label: 'Accueil',
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
                  child: Icon(Icons.person_outline),
                ),
                activeIcon: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xFF006D77).withOpacity(0.2),
                  ),
                  child: Icon(Icons.person),
                ),
                label: 'Profil',
              ),
            ],
            onTap: (index) => setState(() => _currentIndex = index),
          ),
        ),
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 24),

          _buildActionCard(
            icon: Icons.school,
            title: 'Nouvelle demande',
            subtitle: 'Commencer une admission',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RequestFormScreen()),
                ),
          ),
          SizedBox(height: 24),

          Text(
            'Mes demandes récentes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
          SizedBox(height: 12),
          _buildRecentRequests(userId),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return FutureBuilder<UserMetadata>(
      future: _getUserProfile(),
      builder: (context, snapshot) {
        final fullName = snapshot.data?.fullName ?? 'Étudiant';
        final email = snapshot.data?.email ?? '';

        return Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.teal.shade100,
              child: Icon(Icons.person, size: 40, color: Colors.teal.shade700),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenue',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                SizedBox(height: 4),
                Text(
                  fullName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800,
                  ),
                ),
                Text(
                  email,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<UserMetadata> _getUserProfile() async {
    try {
      // Version corrigée avec la syntaxe correcte de Supabase
      final response =
          await Supabase.instance.client
              .from('profiles')
              .select()
              .eq(
                'user_id',
                Supabase.instance.client.auth.currentUser?.id as Object,
              )
              .single();

      return UserMetadata.fromMap(response);
    } catch (e) {
      // Retourne des valeurs par défaut en cas d'erreur
      return UserMetadata(
        fullName: 'Étudiant',
        email: Supabase.instance.client.auth.currentUser?.email ?? '',
      );
    }
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: Colors.teal.shade700),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.teal),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentRequests(String userId) {
    return StreamBuilder<List<AdmissionRequest>>(
      stream: DatabaseService().getRequests(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        final requests = snapshot.data!.take(3).toList();

        return Column(
          children:
              requests
                  .map((request) => _buildRequestItem(context, request))
                  .toList(),
        );
      },
    );
  }

  Widget _buildRequestItem(BuildContext context, AdmissionRequest request) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RequestDetailScreen(request: request),
            ),
          );
        },
        splashColor: Colors.teal.withOpacity(0.1),
        highlightColor: Colors.teal.withOpacity(0.05),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.program,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Soumis le ${DateFormat('dd/MM/yyyy').format(DateTime.parse(request.submissionDate))}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Chip(
                backgroundColor: _getStatusColor(
                  request.status,
                ).withOpacity(0.1),
                label: Text(
                  request.status.toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(request.status),
                    fontSize: 12,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
          SizedBox(height: 16),
          Text(
            'Aucune demande récente',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}

class UserMetadata {
  final String fullName;
  final String email;

  UserMetadata({required this.fullName, required this.email});

  factory UserMetadata.fromMap(Map<String, dynamic> map) {
    return UserMetadata(
      fullName: map['full_name'] ?? '',
      email: map['email'] ?? '',
    );
  }
}
