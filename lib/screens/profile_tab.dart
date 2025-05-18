import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:demande_admission/services/auth_service.dart';

class ProfileTab extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Header avec photo de profil
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.teal.shade100,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.teal.shade700,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    user?.displayName ?? 'Utilisateur',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Section informations
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildProfileItem(
                      icon: Icons.email,
                      title: 'Email',
                      value: user?.email ?? 'Non renseigné',
                    ),
                    Divider(height: 24),
                    _buildProfileItem(
                      icon: Icons.phone,
                      title: 'Téléphone',
                      value: user?.phoneNumber ?? 'Non renseigné',
                    ),
                    Divider(height: 24),
                    _buildProfileItem(
                      icon: Icons.calendar_today,
                      title: 'Compte créé le',
                      value:
                          user?.metadata.creationTime?.toString().substring(
                            0,
                            10,
                          ) ??
                          'Date inconnue',
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Bouton de déconnexion
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.logout),
                label: Text('Déconnexion'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.teal.shade700,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _showLogoutDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

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
                  // Retour à l'écran de connexion
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
}
