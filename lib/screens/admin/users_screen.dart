import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:demande_admission/models/user.dart' as userModel;
import 'package:demande_admission/services/admin_service.dart';
import 'package:demande_admission/screens/admin/base_screen.dart';
import 'package:demande_admission/screens/admin/admin_user_detail_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  String _searchQuery = '';
  List<userModel.User> _allUsers = [];

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Gestion des utilisateurs',
      actions: [
        IconButton(icon: const Icon(Icons.add), onPressed: _showAddUserDialog),
      ],

      body: StreamBuilder<List<userModel.User>>(
        stream: Provider.of<AdminService>(context).getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _allUsers = snapshot.data!;
          }

          final filteredUsers =
              _searchQuery.isEmpty
                  ? _allUsers
                  : _allUsers.where((user) {
                    final query = _searchQuery.toLowerCase();
                    return (user.fullName?.toLowerCase().contains(query) ??
                            false) ||
                        user.email.toLowerCase().contains(query) ||
                        user.role.toLowerCase().contains(query);
                  }).toList();

          return _buildContent(filteredUsers, snapshot);
        },
      ),
    );
  }

  Widget _buildContent(List<userModel.User> users, AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(snapshot.error.toString(), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => setState(() {}),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isEmpty ? Icons.people_outline : Icons.search_off,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'Aucun utilisateur trouvé'
                  : 'Aucun résultat pour "$_searchQuery"',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (_searchQuery.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
                child: const Text('Réinitialiser la recherche'),
              ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 16),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {});
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return _UserTile(user: users[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Rechercher un utilisateur...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon:
            _searchQuery.isNotEmpty
                ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
                : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  Future<void> _showAddUserDialog() async {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final nameController = TextEditingController();
    String selectedRole = 'student';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter un utilisateur'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un email';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Email invalide';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nom complet'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  items: const [
                    DropdownMenuItem(
                      value: 'admin',
                      child: Text('Administrateur'),
                    ),
                    DropdownMenuItem(
                      value: 'teacher',
                      child: Text('Enseignant'),
                    ),
                    DropdownMenuItem(value: 'student', child: Text('Étudiant')),
                  ],
                  onChanged: (value) => selectedRole = value!,
                  decoration: const InputDecoration(labelText: 'Rôle'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await Provider.of<AdminService>(
                      context,
                      listen: false,
                    ).createUser(
                      email: emailController.text,
                      fullName: nameController.text,
                      role: selectedRole,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Utilisateur créé avec succès'),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: ${e.toString()}')),
                    );
                  }
                }
              },
              child: const Text('Créer'),
            ),
          ],
        );
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
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminUserDetailScreen(user: user),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  (user.fullName?.isNotEmpty ?? false)
                      ? user.fullName![0].toUpperCase()
                      : user.email[0].toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName ?? user.email,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text(
                  user.role.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getRoleTextColor(context, user.role),
                  ),
                ),
                backgroundColor: _getRoleColor(context, user.role),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(BuildContext context, String role) {
    switch (role) {
      case 'admin':
        return Theme.of(context).colorScheme.primary.withOpacity(0.2);
      case 'teacher':
        return Colors.blue.withOpacity(0.2);
      default: // student
        return Colors.green.withOpacity(0.2);
    }
  }

  Color _getRoleTextColor(BuildContext context, String role) {
    switch (role) {
      case 'admin':
        return Theme.of(context).colorScheme.primary;
      case 'teacher':
        return Colors.blue;
      default: // student
        return Colors.green;
    }
  }
}
