import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:demande_admission/services/auth_service.dart';
import 'package:intl/intl.dart';

class ProfileTab extends StatefulWidget {
  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _supabase = Supabase.instance.client;
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        final response =
            await _supabase
                .from('profiles')
                .select()
                .eq('user_id', userId)
                .single();

        setState(() {
          _profileData = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    if (date is DateTime) return date;
    if (date is String) return DateTime.tryParse(date);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = _supabase.auth.currentUser;
    final createdAt = _parseDate(user?.createdAt);
    final formattedDate =
        createdAt != null
            ? DateFormat('dd/MM/yyyy').format(createdAt)
            : 'Date inconnue';

    return Scaffold(
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
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
                            _profileData?['full_name'] ?? 'Utilisateur',
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
                              value: _profileData?['phone'] ?? 'Non renseigné',
                            ),
                            Divider(height: 24),
                            _buildProfileItem(
                              icon: Icons.calendar_today,
                              title: 'Compte créé le',
                              value: formattedDate,
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
                onPressed: () async {
                  Navigator.pop(context);
                  await AuthService().signOut();
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
