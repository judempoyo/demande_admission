import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:demande_admission/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:demande_admission/screens/admin/base_screen.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({Key? key}) : super(key: key);

  @override
  _AdminProfileScreenState createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
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
                .select('*, role:roles(name)')
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

    return BaseScreen(
      title: 'Mon Profil Admin',
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(color: Color(0xFF006D77)),
              )
              : SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Header profil
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF006D77), Color(0xFF83C5BE)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.teal.shade100,
                                  child: Icon(
                                    Icons.admin_panel_settings,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text(
                            _profileData?['full_name'] ?? 'Administrateur',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          SizedBox(height: 8),
                          Chip(
                            label: Text(
                              _profileData?['role']?['name']?.toUpperCase() ??
                                  'ADMIN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor: Colors.black.withOpacity(0.2),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Section informations
                    Card(
                      elevation: 4,
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
                            Divider(height: 24),
                            _buildProfileItem(
                              icon: Icons.badge,
                              title: 'Rôle',
                              value:
                                  _profileData?['role']?['name'] ??
                                  'Administrateur',
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Boutons d'action
                    Column(
                      children: [
                        _buildActionButton(
                          icon: Icons.edit,
                          label: 'Modifier le profil',
                          color: Color(0xFF006D77),
                          onPressed: () => _showEditDialog(context),
                        ),
                        SizedBox(height: 12),
                        _buildActionButton(
                          icon: Icons.lock,
                          label: 'Changer le mot de passe',
                          color: Color(0xFF83C5BE),
                          onPressed: () => _showPasswordDialog(context),
                        ),
                        SizedBox(height: 12),
                        _buildActionButton(
                          icon: Icons.logout,
                          label: 'Déconnexion',
                          color: Color(0xFFE29578),
                          onPressed: () => _showLogoutDialog(context),
                        ),
                      ],
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
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF006D77).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Color(0xFF006D77)),
        ),
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        onPressed: onPressed,
      ),
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
                onPressed: () => Navigator.pop(context),
                child: Text('Annuler'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await AuthService().signOut();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
                child: Text('Déconnexion', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final nameController = TextEditingController(
      text: _profileData?['full_name'] ?? '',
    );
    final phoneController = TextEditingController(
      text: _profileData?['phone'] ?? '',
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Modifier le profil'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Nom complet'),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'Téléphone'),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await _supabase
                        .from('profiles')
                        .update({
                          'full_name': nameController.text,
                          'phone': phoneController.text,
                          'updated_at': DateTime.now().toIso8601String(),
                        })
                        .eq('user_id', _supabase.auth.currentUser!.id);

                    await _loadProfileData();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Profil mis à jour')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: ${e.toString()}')),
                    );
                  }
                },
                child: Text('Enregistrer'),
              ),
            ],
          ),
    );
  }

  void _showPasswordDialog(BuildContext context) {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Changer le mot de passe'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Nouveau mot de passe',
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: confirmController,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                  ),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (passwordController.text != confirmController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Les mots de passe ne correspondent pas'),
                      ),
                    );
                    return;
                  }

                  try {
                    await _supabase.auth.updateUser(
                      UserAttributes(password: passwordController.text),
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Mot de passe mis à jour')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: ${e.toString()}')),
                    );
                  }
                },
                child: Text('Enregistrer'),
              ),
            ],
          ),
    );
  }
}
