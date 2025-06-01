// screens/requests_screen.dart
import 'package:demande_admission/models/admission_request.dart';
import 'package:demande_admission/services/admin_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'base_screen.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({Key? key}) : super(key: key);

  @override
  _RequestsScreenState createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final adminService = Provider.of<AdminService>(context);

    return BaseScreen(
      title: 'Gestion des demandes',
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            setState(() => _filter = value);
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(value: 'all', child: Text('Toutes')),
                const PopupMenuItem(
                  value: 'pending',
                  child: Text('En attente'),
                ),
                const PopupMenuItem(
                  value: 'approved',
                  child: Text('Approuvées'),
                ),
                const PopupMenuItem(value: 'rejected', child: Text('Rejetées')),
              ],
          icon: const Icon(Icons.filter_list),
        ),
      ],
      body: StreamBuilder<List<AdmissionRequest>>(
        stream:
            _filter == 'all'
                ? adminService.getAllAdmissionRequests()
                : adminService.getAllAdmissionRequests(statusFilter: _filter),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final requests = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      return _RequestCard(request: requests[index]);
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
        hintText: 'Rechercher une demande...',
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

class _RequestCard extends StatelessWidget {
  final AdmissionRequest request;

  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Naviguer vers les détails de la demande
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    request.fullName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Chip(
                    label: Text(
                      request.status.toUpperCase(),
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: _getStatusColor(context, request.status),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                request.program,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    request.submissionDate,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(BuildContext context, String status) {
    switch (status) {
      case 'approved':
        return Colors.green.shade100;
      case 'rejected':
        return Colors.red.shade100;
      case 'pending':
      default:
        return Colors.orange.shade100;
    }
  }
}
