import 'package:demande_admission/screens/profile_tab.dart';
import 'package:demande_admission/screens/request_form_screen.dart';
import 'package:demande_admission/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:demande_admission/models/admission_request.dart';
import 'package:demande_admission/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final userId = FirebaseAuth.instance.currentUser!.uid;

  final List<Widget> _screens = [
    DashboardTab(),

    /*  RequestHistoryTab(),
    */
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mon Espace Admission',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal.shade700,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _screens[_currentIndex],
      floatingActionButton:
          _currentIndex == 0
              ? FloatingActionButton(
                backgroundColor: Colors.teal.shade600,
                child: Icon(Icons.add, color: Colors.white),
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RequestFormScreen()),
                    ),
              )
              : null,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: Colors.teal.shade700,
          unselectedItemColor: Colors.grey.shade600,
          showUnselectedLabels: true,
          elevation: 10,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Accueil',
            ),
          /*   BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'Historique',
            ), */
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
            BottomNavigationBarItem(
              // Nouvel item pour déconnexion
              icon: Icon(Icons.logout),
              label: 'Déconnexion',
            ),
          ],
          onTap: (index) {
            if (index == 3) {
              // Index du bouton de déconnexion
              _showLogoutDialog(context);
            } else {
              setState(() => _currentIndex = index);
            }
          },
        ),
      ),
    );
  }
}

// Ajoutez cette méthode dans _HomeScreenState
void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text('Déconnexion'),
          content: Text('Voulez-vous vraiment vous déconnecter ?'),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Déconnexion', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.pop(context);
                AuthService().signOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
            ),
          ],
        ),
  );
}

class DashboardTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          SizedBox(height: 24),

          // Carte d'action
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

          // Demandes récentes
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
              'Étudiant',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
            ),
          ],
        ),
      ],
    );
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

        final requests = snapshot.data!.take(3).toList(); // Limite à 3 demandes

        return Column(
          children:
              requests.map((request) => _buildRequestItem(request)).toList(),
        );
      },
    );
  }

  Widget _buildRequestItem(AdmissionRequest request) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getStatusColor(request.status).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.description,
            color: _getStatusColor(request.status),
          ),
        ),
        title: Text(
          request.program,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Soumis le ${DateFormat('dd/MM/yyyy').format(DateTime.parse(request.submissionDate))}',
        ),
        trailing: Chip(
          backgroundColor: _getStatusColor(request.status).withOpacity(0.1),
          label: Text(
            request.status.toUpperCase(),
            style: TextStyle(
              color: _getStatusColor(request.status),
              fontSize: 12,
            ),
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
