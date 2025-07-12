// screens/requests_screen.dart
import 'package:demande_admission/models/admission_request.dart';
import 'package:demande_admission/screens/admin/admin_request_detail_screen.dart';
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
  String _searchQuery = '';
  List<AdmissionRequest> _allRequests = [];

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Gestion des demandes',
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _showSearchDialog(context),
          tooltip: 'Recherche avancée',
        ),
        _buildFilterMenu(),
      ],
      body: StreamBuilder<List<AdmissionRequest>>(
        stream: Provider.of<AdminService>(context).getAllAdmissionRequests(
          statusFilter: _filter == 'all' ? null : _filter,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _allRequests = snapshot.data!;
          }

          final filteredRequests =
              _searchQuery.isEmpty
                  ? _allRequests
                  : _allRequests.where((request) {
                    final query = _searchQuery.toLowerCase();
                    return request.fullName.toLowerCase().contains(query) ||
                        request.email.toLowerCase().contains(query) ||
                        request.domain.toLowerCase().contains(query) ||
                        request.program.toLowerCase().contains(query) ||
                        request.status.toLowerCase().contains(query) ||
                        (request.comments?.toLowerCase().contains(query) ??
                            false);
                  }).toList();

          return _buildContent(filteredRequests, snapshot);
        },
      ),
    );
  }

  Widget _buildFilterMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) => setState(() => _filter = value),
      itemBuilder:
          (context) => const [
            PopupMenuItem(value: 'all', child: Text('Toutes')),
            PopupMenuItem(value: 'pending', child: Text('En attente')),
            PopupMenuItem(value: 'approved', child: Text('Approuvées')),
            PopupMenuItem(value: 'rejected', child: Text('Rejetées')),
          ],
      icon: const Icon(Icons.filter_list),
      tooltip: 'Filtrer',
    );
  }

  Widget _buildContent(
    List<AdmissionRequest> requests,
    AsyncSnapshot snapshot,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF006D77)),
      );
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

    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isEmpty ? Icons.inbox : Icons.search_off,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'Aucune demande trouvée'
                  : 'Aucun résultat pour "$_searchQuery"',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (_searchQuery.isNotEmpty)
              TextButton(
                onPressed: () => setState(() => _searchQuery = ''),
                child: const Text('Réinitialiser la recherche'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          return _RequestCard(request: requests[index]);
        },
      ),
    );
  }

  Future<void> _showSearchDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Recherche avancée'),
            content: TextField(
              decoration: const InputDecoration(
                hintText: 'Rechercher par nom, email, programme...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() => _searchQuery = '');
                  Navigator.pop(context);
                },
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Rechercher'),
              ),
            ],
          ),
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openRequestDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      request.fullName,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Chip(
                    label: Text(
                      request.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusTextColor(request.status),
                      ),
                    ),
                    backgroundColor: _getStatusColor(request.status),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                request.domain,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF006D77),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
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
                    request.submissionDate.substring(0, 10),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  if (request.hasScholarship)
                    const Icon(Icons.school, size: 16, color: Colors.amber),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green.withOpacity(0.2);
      case 'rejected':
        return Colors.red.withOpacity(0.2);
      case 'pending':
      default:
        return Colors.orange.withOpacity(0.2);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  void _openRequestDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminRequestDetailScreen(request: request),
      ),
    ).then((refresh) {
      if (refresh == true) {
        // Rafraîchir si nécessaire
      }
    });
  }
}

class RequestDetailsDialog extends StatelessWidget {
  final AdmissionRequest request;
  final AdminService adminService;

  const RequestDetailsDialog({
    required this.request,
    required this.adminService,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String status = request.status;
    final commentsController = TextEditingController(
      text: request.comments ?? '',
    );

    return AlertDialog(
      title: Text('Détails de la demande'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: status,
            items: [
              DropdownMenuItem(value: 'pending', child: Text('En attente')),
              DropdownMenuItem(value: 'approved', child: Text('Approuvée')),
              DropdownMenuItem(value: 'rejected', child: Text('Rejetée')),
            ],
            onChanged: (value) => status = value!,
          ),
          SizedBox(height: 16),
          TextField(
            controller: commentsController,
            decoration: InputDecoration(labelText: 'Commentaires'),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Annuler', style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: () async {
            await _showDeleteConfirmation(context);
          },
          child: Text('Supprimer', style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          onPressed: () async {
            await adminService.updateRequestStatus(
              requestId: request.id!,
              status: status,
              comments: commentsController.text,
            );
            Navigator.pop(context);
          },
          child: Text('Enregistrer'),
        ),
      ],
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirmer la suppression'),
            content: Text('Voulez-vous vraiment supprimer cette demande ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Annuler'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await adminService.deleteRequest(request.id!);
                    Navigator.pop(context); // Fermer la boîte de confirmation
                    Navigator.pop(context); // Fermer le dialogue de détails
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Demande supprimée')),
                    );
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: ${e.toString()}')),
                    );
                  }
                },
                child: Text('Supprimer', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
