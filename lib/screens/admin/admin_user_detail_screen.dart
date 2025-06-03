import 'package:flutter/material.dart';
import 'package:demande_admission/models/user.dart' as userModel;
import 'package:demande_admission/services/admin_service.dart';
import 'package:provider/provider.dart';

class AdminUserDetailScreen extends StatefulWidget {
  final userModel.User user;

  const AdminUserDetailScreen({Key? key, required this.user}) : super(key: key);

  @override
  _AdminUserDetailScreenState createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  late String _selectedRole;
  final TextEditingController _fullNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.user.role;
    _fullNameController.text = widget.user.fullName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final adminService = Provider.of<AdminService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails utilisateur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _updateUser(adminService),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserInfo(),
                    const SizedBox(height: 24),
                    _buildRoleSelector(),
                    const SizedBox(height: 24),
                    _buildNameField(),
                    const SizedBox(height: 32),
                    _buildActionButtons(adminService),
                  ],
                ),
              ),
    );
  }

  Widget _buildUserInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            (widget.user.fullName?.isNotEmpty ?? false)
                ? widget.user.fullName![0].toUpperCase()
                : widget.user.email[0].toUpperCase(),
            style: TextStyle(
              fontSize: 32,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.user.fullName ?? 'Pas de nom',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              widget.user.email,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Chip(
              label: Text(
                widget.user.role.toUpperCase(),
                style: TextStyle(
                  color: _getRoleTextColor(context, widget.user.role),
                ),
              ),
              backgroundColor: _getRoleColor(context, widget.user.role),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rôle',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedRole,
          items: const [
            DropdownMenuItem(value: 'admin', child: Text('Administrateur')),
            DropdownMenuItem(value: 'teacher', child: Text('Enseignant')),
            DropdownMenuItem(value: 'student', child: Text('Étudiant')),
          ],
          onChanged: (value) => setState(() => _selectedRole = value!),
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nom complet',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _fullNameController,
          decoration: InputDecoration(
            hintText: 'Entrez le nom complet',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(AdminService adminService) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.delete),
          label: const Text('Supprimer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: () => _confirmDelete(adminService),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.save),
          label: const Text('Enregistrer'),
          onPressed: () => _updateUser(adminService),
        ),
      ],
    );
  }

  Future<void> _updateUser(AdminService adminService) async {
    setState(() => _isLoading = true);
    try {
      await adminService.updateUser(
        userId: widget.user.user_id,
        newRole: _selectedRole,
        fullName: _fullNameController.text,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Utilisateur mis à jour')));
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmDelete(AdminService adminService) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: const Text(
              'Voulez-vous vraiment supprimer cet utilisateur ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _deleteUser(adminService);
    }
  }

  Future<void> _deleteUser(AdminService adminService) async {
    setState(() => _isLoading = true);
    try {
      await adminService.deleteUser(widget.user.user_id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Utilisateur supprimé')));
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    } finally {
      setState(() => _isLoading = false);
    }
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
