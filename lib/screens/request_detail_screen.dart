import 'package:flutter/material.dart';
import 'package:demande_admission/models/admission_request.dart';
import 'package:demande_admission/services/database_service.dart';
import 'package:demande_admission/services/storage_service.dart';
import 'package:demande_admission/screens/request_form_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestDetailScreen extends StatefulWidget {
  final AdmissionRequest request;

  const RequestDetailScreen({Key? key, required this.request})
    : super(key: key);

  @override
  _RequestDetailScreenState createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Détails de la demande',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF006D77),
        elevation: 0,
        centerTitle: true,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () => _navigateToEditScreen(),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: _confirmDelete,
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
                    _buildSectionHeader('Statut de la demande'),
                    _buildStatusChip(widget.request.status),

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

                    if (widget.request.comments != null &&
                        widget.request.comments!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),
                          _buildSectionHeader('Commentaires'),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(widget.request.comments!),
                          ),
                        ],
                      ),
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

  Widget _buildStatusChip(String status) {
    Color statusColor;
    switch (status) {
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      case 'pending':
      default:
        statusColor = Colors.orange;
    }

    return Chip(
      label: Text(status.toUpperCase(), style: TextStyle(color: Colors.white)),
      backgroundColor: statusColor,
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

  Future<void> _openDocument(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible d\'ouvrir le document')),
      );
    }
  }

  Future<void> _navigateToEditScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestFormScreen.edit(request: widget.request),
      ),
    );

    if (result == true) {
      Navigator.pop(context, true); // Rafraîchir la liste des demandes
    }
  }

  Future<void> _confirmDelete() async {
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
      await _deleteRequest();
    }
  }

  Future<void> _deleteRequest() async {
    setState(() => _isLoading = true);

    try {
      // Supprimer les documents du stockage
      await _storageService.deleteFiles(
        'documents',
        widget.request.documents.values.toList(),
      );

      // Supprimer la demande de la base de données
      await _databaseService.deleteRequest(widget.request.id!);

      Navigator.pop(
        context,
        true,
      ); // Retour à l'écran précédent avec rafraîchissement
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
