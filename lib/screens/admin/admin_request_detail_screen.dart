import 'package:flutter/material.dart';
import 'package:demande_admission/models/admission_request.dart';
import 'package:demande_admission/services/admin_service.dart';
import 'package:demande_admission/services/storage_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminRequestDetailScreen extends StatefulWidget {
  final AdmissionRequest request;

  const AdminRequestDetailScreen({Key? key, required this.request})
    : super(key: key);

  @override
  _AdminRequestDetailScreenState createState() =>
      _AdminRequestDetailScreenState();
}

class _AdminRequestDetailScreenState extends State<AdminRequestDetailScreen> {
  final StorageService _storageService = StorageService();
  bool _isLoading = false;
  String? _selectedStatus;
  final TextEditingController _commentsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.request.status;
    _commentsController.text = widget.request.comments ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final adminService = Provider.of<AdminService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Détails de la demande',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF006D77),
        elevation: 0,
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitForm,
            tooltip: 'Enregistrer',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Informations Personnelles'),
                      _buildInfoCard(
                        children: [
                          _buildInfoRow('Nom Complet', widget.request.fullName),
                          _buildInfoRow('Email', widget.request.email),
                          _buildInfoRow('Téléphone', widget.request.phone),
                          _buildInfoRow('Adresse', widget.request.address),
                          if (widget.request.birthDate != null)
                            _buildInfoRow(
                              'Date de naissance',
                              widget.request.birthDate!.substring(0, 10),
                            ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      _buildSectionHeader('Programme Académique'),
                      _buildInfoCard(
                        children: [
                          _buildInfoRow('Domaine', widget.request.domain),
                          _buildInfoRow('Programme', widget.request.program),
                          _buildInfoRow(
                            'Bourse',
                            widget.request.hasScholarship ? 'Oui' : 'Non',
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      _buildSectionHeader('Statut'),
                      _buildStatusDropdown(),

                      const SizedBox(height: 20),
                      _buildSectionHeader('Commentaires'),
                      _buildCommentsField(),

                      const SizedBox(height: 20),
                      _buildSectionHeader('Documents'),
                      _buildDocumentList(),

                      const SizedBox(height: 20),
                      _buildSectionHeader('Dates'),
                      _buildInfoCard(
                        children: [
                          _buildInfoRow(
                            'Date de soumission',
                            widget.request.submissionDate.substring(0, 10),
                          ),
                          if (widget.request.decisionDate != null)
                            _buildInfoRow(
                              'Date de décision',
                              widget.request.decisionDate!.substring(0, 10),
                            ),
                        ],
                      ),

                      const SizedBox(height: 30),
                      _buildActionButtons(adminService),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF006D77),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: DropdownButtonFormField<String>(
          value: _selectedStatus,
          items: const [
            DropdownMenuItem(value: 'pending', child: Text('En attente')),
            DropdownMenuItem(value: 'approved', child: Text('Approuvée')),
            DropdownMenuItem(value: 'rejected', child: Text('Rejetée')),
          ],
          onChanged: (value) => setState(() => _selectedStatus = value),
          decoration: const InputDecoration(
            border: InputBorder.none,
            labelText: 'Statut',
          ),
          style: TextStyle(
            color: _getStatusColor(_selectedStatus ?? 'pending'),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCommentsField() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _commentsController,
          maxLines: 3,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Ajouter un commentaire...',
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children:
            widget.request.documents.entries.map((entry) {
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF83C5BE).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.description,
                    color: Color(0xFF006D77),
                  ),
                ),
                title: Text(entry.key),
                trailing: IconButton(
                  icon: const Icon(Icons.open_in_new),
                  onPressed: () => _openDocument(entry.value),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            }).toList(),
      ),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => _confirmDelete(adminService),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.save),
          label: const Text('Enregistrer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF006D77),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _submitForm,
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
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

  Future<void> _openDocument(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir le document')),
      );
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await Provider.of<AdminService>(
          context,
          listen: false,
        ).updateRequestStatus(
          requestId: widget.request.id!,
          status: _selectedStatus!,
          comments: _commentsController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demande mise à jour'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _confirmDelete(AdminService adminService) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: const Text(
              'Voulez-vous vraiment supprimer cette demande ?',
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
    );

    if (confirmed == true) {
      await _deleteRequest(adminService);
    }
  }

  Future<void> _deleteRequest(AdminService adminService) async {
    setState(() => _isLoading = true);
    try {
      await _storageService.deleteFiles(
        'documents',
        widget.request.documents.values.toList(),
      );
      await adminService.deleteRequest(widget.request.id!);
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
