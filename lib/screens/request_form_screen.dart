import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:demande_admission/models/admission_request.dart';
import 'package:demande_admission/services/storage_service.dart';
import 'package:demande_admission/services/database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RequestFormScreen extends StatefulWidget {
  @override
  _RequestFormScreenState createState() => _RequestFormScreenState();
}

class _RequestFormScreenState extends State<RequestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<XFile> _documents = [];
  final _picker = ImagePicker();
  final _storageService = StorageService();
  final _databaseService = DatabaseService();

  // Nouveaux champs de formulaire
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  DateTime? _birthDate;
  bool _hasScholarship = false;
  String? _selectedProgram;
  bool _isLoading = false;

  // Liste des programmes disponibles
  final List<String> _programs = [
    'Licence Informatique',
    'Master Finance',
    'Doctorat Physique',
    'Licence Droit',
    'Master Marketing',
  ];

  // Types de documents requis
  final Map<String, bool> _requiredDocuments = {
    'CV': false,
    'Lettre de motivation': false,
    'Relevés de notes': false,
    'Diplômes': false,
    'Pièce d\'identité': false,
  };

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nouvelle demande d\'admission'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Informations personnelles'),
              _buildTextFormField(
                'Nom complet',
                _fullNameController,
                TextInputType.name,
              ),
              _buildTextFormField(
                'Email',
                _emailController,
                TextInputType.emailAddress,
              ),
              _buildTextFormField(
                'Téléphone',
                _phoneController,
                TextInputType.phone,
              ),
              _buildTextFormField(
                'Adresse',
                _addressController,
                TextInputType.streetAddress,
              ),

              SizedBox(height: 16),
              _buildDatePicker(),
              SizedBox(height: 16),
              _buildScholarshipCheckbox(),

              _buildSectionTitle('Programme académique'),
              _buildProgramDropdown(),

              _buildSectionTitle('Documents à fournir'),
              ..._buildDocumentChecklist(),
              SizedBox(height: 16),
              _buildDocumentUploadSection(),
              if (_documents.isNotEmpty) ...[
                SizedBox(height: 16),
                _buildUploadedDocumentsList(),
              ],

              SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.teal.shade700,
        ),
      ),
    );
  }

  Widget _buildTextFormField(
    String label,
    TextEditingController controller,
    TextInputType inputType,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        validator:
            (value) =>
                value?.isEmpty ?? true ? 'Ce champ est obligatoire' : null,
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () => _selectBirthDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date de naissance',
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _birthDate != null
                  ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                  : 'Sélectionnez une date',
            ),
            Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildScholarshipCheckbox() {
    return CheckboxListTile(
      title: Text('Bénéficiaire d\'une bourse d\'études'),
      value: _hasScholarship,
      onChanged: (value) => setState(() => _hasScholarship = value ?? false),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildProgramDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Programme souhaité',
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      value: _selectedProgram,
      items:
          _programs.map((program) {
            return DropdownMenuItem(value: program, child: Text(program));
          }).toList(),
      onChanged: (value) => setState(() => _selectedProgram = value),
      validator:
          (value) =>
              value == null ? 'Veuillez sélectionner un programme' : null,
    );
  }

  List<Widget> _buildDocumentChecklist() {
    return _requiredDocuments.entries.map((entry) {
      return CheckboxListTile(
        title: Text(entry.key),
        value: entry.value,
        onChanged:
            (value) =>
                setState(() => _requiredDocuments[entry.key] = value ?? false),
        controlAffinity: ListTileControlAffinity.leading,
      );
    }).toList();
  }

  Widget _buildDocumentUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Fichiers à uploader',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        OutlinedButton.icon(
          icon: Icon(Icons.attach_file),
          label: Text('Ajouter des documents'),
          onPressed: _pickDocuments,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadedDocumentsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Documents sélectionnés',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        ..._documents.map((file) {
          return Card(
            margin: EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(Icons.description, color: Colors.teal),
              title: Text(file.name),
              trailing: IconButton(
                icon: Icon(Icons.close, color: Colors.red),
                onPressed: () => setState(() => _documents.remove(file)),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: _isLoading ? null : _submitForm,
        child:
            _isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
                  'SOUMETTRE LA DEMANDE',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
      ),
    );
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthDate) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _pickDocuments() async {
    try {
      final result = await _picker.pickMultiImage();
      if (result.isNotEmpty) {
        setState(() => _documents.addAll(result));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection des fichiers: $e')),
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final missingDocs =
        _requiredDocuments.entries
            .where((entry) => entry.value == false)
            .map((entry) => entry.key)
            .toList();

    if (missingDocs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Veuillez confirmer les documents requis: ${missingDocs.join(', ')}',
          ),
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    if (_documents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez ajouter au moins un document')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Upload des documents
      final filePrefix =
          '${_fullNameController.text}_${DateTime.now().millisecondsSinceEpoch}'
              .replaceAll(RegExp(r'[^\w-]'), '_');
      final uploadedDocs = await _storageService.uploadMultipleFiles(
        'documents',
        _documents,
        prefix: filePrefix,
      );

      // Création de la demande
      final request = AdmissionRequest(
        userId: Supabase.instance.client.auth.currentUser!.id,
        fullName: _fullNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        birthDate: _birthDate?.toIso8601String(),
        program: _selectedProgram!,
        hasScholarship: _hasScholarship,
        documents: uploadedDocs,
        status: 'pending',
        submissionDate: DateTime.now().toIso8601String(),
      );

      await _databaseService.saveRequest(request);

      Navigator.pop(context, true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Demande soumise avec succès!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la soumission: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
