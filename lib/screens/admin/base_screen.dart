import 'package:demande_admission/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BaseScreen extends StatefulWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final bool showDrawer;

  const BaseScreen({
    Key? key,
    required this.body,
    required this.title,
    this.actions,
    this.showDrawer = true,
  }) : super(key: key);

  @override
  _BaseScreenState createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, size: 26),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: Icon(Icons.account_circle_outlined, size: 26),
            onPressed: () => Navigator.pushNamed(context, '/admin/profile'),
            tooltip: 'Profil',
          ),
          if (widget.actions != null) ...widget.actions!,
        ],
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
      ),
      drawer: widget.showDrawer ? _buildDrawer(context) : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.surface.withOpacity(0.9),
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: widget.body,
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      width: 280,
      shape: const ContinuousRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(40),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: theme.colorScheme.onPrimary.withOpacity(0.2),
                  child: Icon(
                    Icons.school,
                    size: 30,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Admin Dashboard',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Administration',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          _DrawerTile(
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard,
            label: 'Tableau de bord',
            selected: _selectedIndex == 0,
            onTap: () {
              Navigator.pushReplacementNamed(context, '/dashboard');
              setState(() => _selectedIndex = 0);
            },
          ),
          _DrawerTile(
            icon: Icons.list_alt_outlined,
            selectedIcon: Icons.list_alt,
            label: 'Demandes',
            selected: _selectedIndex == 1,
            onTap: () {
              Navigator.pushReplacementNamed(context, '/requests');
              setState(() => _selectedIndex = 1);
            },
          ),
          _DrawerTile(
            icon: Icons.people_outline,
            selectedIcon: Icons.people,
            label: 'Utilisateurs',
            selected: _selectedIndex == 2,
            onTap: () {
              Navigator.pushReplacementNamed(context, '/users');
              setState(() => _selectedIndex = 2);
            },
          ),
          const Divider(indent: 20, endIndent: 20),
          _DrawerTile(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            label: 'Paramètres',
            selected: _selectedIndex == 3,
            onTap: () {
              Navigator.pushNamed(context, '/settings');
              setState(() => _selectedIndex = 3);
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout, size: 20),
              label: const Text('Déconnexion'),
              onPressed: () {
                Provider.of<AuthService>(context, listen: false).signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFFE29578),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        selected ? selectedIcon : icon,
        color:
            selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withOpacity(0.7),
      ),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          color:
              selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: selected,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      selectedTileColor: theme.colorScheme.primary.withOpacity(0.1),
    );
  }
}
