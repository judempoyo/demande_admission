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

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.request.status;
    _commentsController.text = widget.request.comments ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final adminService = Provider.of<AdminService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Détails de la demande',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF006D77),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () => _updateRequest(adminService),
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Informations Personnelles'),
                    _buildInfoRow('Nom Complet', widget.request.fullName),
                    _buildInfoRow('Email', widget.request.email),
                    _buildInfoRow('Téléphone', widget.request.phone),
                    _buildInfoRow('Adresse', widget.request.address),
                    if (widget.request.birthDate != null)
                      _buildInfoRow(
                        'Date de naissance',
                        widget.request.birthDate!.substring(0, 10),
                      ),

                    SizedBox(height: 20),
                    _buildSectionHeader('Programme Académique'),
                    _buildInfoRow('Programme', widget.request.program),
                    _buildInfoRow(
                      'Bourse',
                      widget.request.hasScholarship ? 'Oui' : 'Non',
                    ),

                    SizedBox(height: 20),
                    _buildSectionHeader('Statut'),
                    _buildStatusDropdown(),

                    SizedBox(height: 20),
                    _buildSectionHeader('Commentaires'),
                    _buildCommentsField(),

                    SizedBox(height: 20),
                    _buildSectionHeader('Documents'),
                    ..._buildDocumentList(),

                    SizedBox(height: 20),
                    _buildSectionHeader('Dates'),
                    _buildInfoRow(
                      'Date de soumission',
                      widget.request.submissionDate.substring(0, 10),
                    ),
                    if (widget.request.decisionDate != null)
                      _buildInfoRow(
                        'Date de décision',
                        widget.request.decisionDate!.substring(0, 10),
                      ),

                    SizedBox(height: 20),
                    _buildActionButtons(adminService),
                  ],
                ),
              ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF006D77),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      items: [
        DropdownMenuItem(value: 'pending', child: Text('En attente')),
        DropdownMenuItem(value: 'approved', child: Text('Approuvée')),
        DropdownMenuItem(value: 'rejected', child: Text('Rejetée')),
      ],
      onChanged: (value) => setState(() => _selectedStatus = value),
      decoration: InputDecoration(border: OutlineInputBorder()),
    );
  }

  Widget _buildCommentsField() {
    return TextField(
      controller: _commentsController,
      maxLines: 3,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Ajouter un commentaire...',
      ),
    );
  }

  List<Widget> _buildDocumentList() {
    return widget.request.documents.entries.map((entry) {
      return ListTile(
        leading: Icon(Icons.description, color: Colors.teal),
        title: Text(entry.key),
        trailing: IconButton(
          icon: Icon(Icons.open_in_new),
          onPressed: () => _openDocument(entry.value),
        ),
      );
    }).toList();
  }

  Widget _buildActionButtons(AdminService adminService) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton.icon(
          icon: Icon(Icons.delete),
          label: Text('Supprimer'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => _confirmDelete(adminService),
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.save),
          label: Text('Enregistrer'),
          onPressed: () => _updateRequest(adminService),
        ),
      ],
    );
  }

  Future<void> _openDocument(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible d\'ouvrir le document')),
      );
    }
  }

  Future<void> _updateRequest(AdminService adminService) async {
    setState(() => _isLoading = true);
    try {
      await adminService.updateRequestStatus(
        requestId: widget.request.id!,
        status: _selectedStatus!,
        comments: _commentsController.text,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Demande mise à jour')));
      Navigator.pop(context, true); // Rafraîchir la liste
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
            title: Text('Confirmer la suppression'),
            content: Text('Voulez-vous vraiment supprimer cette demande ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Supprimer', style: TextStyle(color: Colors.red)),
              ),
            ],
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
      Navigator.pop(context, true); // Rafraîchir la liste
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
