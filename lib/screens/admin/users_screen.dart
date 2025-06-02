// screens/users_screen.dart
import 'package:demande_admission/services/admin_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:demande_admission/models/user.dart' as userModel;
import 'base_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  Widget build(BuildContext context) {
    final adminService = Provider.of<AdminService>(context);

    return BaseScreen(
      title: 'Gestion des utilisateurs',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            // Ajouter un nouvel utilisateur
          },
        ),
      ],
      body: StreamBuilder<List<userModel.User>>(
        stream: adminService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final users = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      return _UserTile(user: users[index]);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Rechercher un utilisateur...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      ),
      onChanged: (value) {
        // Implémenter la recherche
      },
    );
  }
}

class _UserTile extends StatelessWidget {
  final userModel.User user;

  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            (user.fullName?.isNotEmpty ?? false)
                ? user.fullName![0]
                : user.email[0],
          ),
        ),
        title: Text(user.fullName ?? user.email),
        subtitle: Text(user.email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(user.role.toUpperCase()),
              backgroundColor: _getRoleColor(context, user.role),
            ),
            const SizedBox(width: 8),
            PopupMenuButton(
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Supprimer',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteDialog(context, user.id);
                }
              },
            ),
          ],
        ),
        onTap: () {
          showDialog(
            context: context,
            builder:
                (context) => UserDetailsDialog(
                  user: user,
                  adminService: Provider.of<AdminService>(
                    context,
                    listen: false,
                  ),
                ),
          );
        },
      ),
    );
  }

  Color _getRoleColor(BuildContext context, String role) {
    switch (role) {
      case 'admin':
        return Theme.of(context).colorScheme.primaryContainer;
      default:
        return Theme.of(context).colorScheme.surfaceVariant;
    }
  }

  void _showDeleteDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: const Text(
              'Voulez-vous vraiment supprimer cet utilisateur?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await Provider.of<AdminService>(
                      context,
                      listen: false,
                    ).deleteUser(userId);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Utilisateur supprimé')),
                    );
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                  }
                },
                child: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}

class UserDetailsDialog extends StatelessWidget {
  final userModel.User user;
  final AdminService adminService;

  const UserDetailsDialog({
    required this.user,
    required this.adminService,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String role = user.role;

    return AlertDialog(
      title: Text('Modifier utilisateur'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: CircleAvatar(child: Text(user.email[0])),
            title: Text(user.email),
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: role,
            items: [
              DropdownMenuItem(value: 'admin', child: Text('Administrateur')),
              DropdownMenuItem(value: 'student', child: Text('Étudiant')),
              DropdownMenuItem(value: 'teacher', child: Text('Enseignant')),
            ],
            onChanged: (value) => role = value!,
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
            await adminService.updateUserRole(userId: user.id, newRole: role);
            Navigator.pop(context);
          },
          child: Text('Enregistrer'),
        ),
      ],
    );
  }
}
