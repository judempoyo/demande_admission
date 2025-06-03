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
  late Stream<List<userModel.User>> _usersStream;
  List<userModel.User> _allUsers = [];

  @override
  void initState() {
    super.initState();
    _usersStream = _getFilteredUsers();
  }

  Stream<List<userModel.User>> _getFilteredUsers() {
    return Provider.of<AdminService>(
      context,
      listen: false,
    ).getAllUsers().map((users) => _filterUsers(users));
  }

  List<userModel.User> _filterUsers(List<userModel.User> users) {
    if (_searchQuery.isEmpty) return users;

    final query = _searchQuery.toLowerCase();
    return users.where((user) {
      return (user.fullName?.toLowerCase().contains(query) ?? false) ||
          user.email.toLowerCase().contains(query) ||
          user.role.toLowerCase().contains(query);
    }).toList();
  }

  void _updateStream() {
    setState(() {
      _usersStream = _getFilteredUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Gestion des utilisateurs',
      actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _updateStream),
      ],
      body: StreamBuilder<List<userModel.User>>(
        stream: _usersStream,
        builder: (context, snapshot) {
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
                    onPressed: _updateStream,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final users = snapshot.data!;

          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _searchQuery.isEmpty
                        ? Icons.people_outline
                        : Icons.search_off,
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
                          _updateStream();
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
                      _updateStream();
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
        },
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
                      _updateStream();
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
          _updateStream();
        });
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
