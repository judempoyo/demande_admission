import 'package:demande_admission/screens/admin/base_screen.dart';
import 'package:demande_admission/screens/admin/users_screen.dart';
import 'package:demande_admission/services/admin_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final adminService = Provider.of<AdminService>(context);
    final theme = Theme.of(context);

    return BaseScreen(
      title: 'Tableau de bord',
      body: SingleChildScrollView(
        child: FutureBuilder<Map<String, dynamic>>(
          future: adminService.getAdminStatistics(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Erreur de chargement des données',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              );
            }

            final stats = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vue d\'ensemble',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildStatCards(context, stats),
                  const SizedBox(height: 30),
                  _buildQuickActions(context),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCards(BuildContext context, Map<String, dynamic> stats) {
    final theme = Theme.of(context);
    final isWideScreen = MediaQuery.of(context).size.width > 700;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isWideScreen ? 3 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _StatCard(
          icon: Icons.request_page,
          value: stats['totalRequests'].toString(),
          label: 'Demandes totales',
          color: theme.colorScheme.primary,
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.8),
              theme.colorScheme.primary.withOpacity(0.6),
            ],
          ),
        ),
        _StatCard(
          icon: Icons.pending_actions,
          value: stats['pendingRequests'].toString(),
          label: 'En attente',
          color: const Color(0xFFE29578),
          gradient: const LinearGradient(
            colors: [Color(0xFFE29578), Color(0xFFFFB4A2)],
          ),
        ),
        _StatCard(
          icon: Icons.people,
          value: stats['totalUsers'].toString(),
          label: 'Utilisateurs',
          color: const Color(0xFF83C5BE),
          gradient: const LinearGradient(
            colors: [Color(0xFF83C5BE), Color(0xFFEDF6F9)],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions rapides',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _ActionButton(
                  icon: Icons.person_add,
                  label: 'Ajouter utilisateur',
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UsersScreen()),
                      ),
                  color: theme.colorScheme.primary,
                ),
                _ActionButton(
                  icon: Icons.bar_chart,
                  label: 'Statistiques',
                  onPressed: () {},
                  color: const Color(0xFF83C5BE),
                ),
                _ActionButton(
                  icon: Icons.settings,
                  label: 'Paramètres',
                  onPressed: () {},
                  color: const Color(0xFFE29578),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Gradient gradient;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: gradient,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 20),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    );
  }
}
