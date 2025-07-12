import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:demande_admission/models/admission_request.dart';
import 'package:demande_admission/services/storage_service.dart';
import 'package:demande_admission/services/database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RequestFormScreen extends StatefulWidget {
  final AdmissionRequest? request;

  const RequestFormScreen({Key? key, this.request}) : super(key: key);

  factory RequestFormScreen.edit({required AdmissionRequest request}) {
    return RequestFormScreen(request: request);
  }

  @override
  _RequestFormScreenState createState() => _RequestFormScreenState();
}

class _RequestFormScreenState extends State<RequestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<XFile> _documents = [];
  final _picker = ImagePicker();
  final _storageService = StorageService();
  final _databaseService = DatabaseService();

  // Contrôleurs de formulaire
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
  void initState() {
    super.initState();
    if (widget.request != null) {
      _prefillForm();
    }
  }

  void _prefillForm() {
    _fullNameController.text = widget.request!.fullName;
    _emailController.text = widget.request!.email;
    _phoneController.text = widget.request!.phone;
    _addressController.text = widget.request!.address;
    if (widget.request!.birthDate != null) {
      _birthDate = DateTime.parse(widget.request!.birthDate!);
    }
    _hasScholarship = widget.request!.hasScholarship;
    _selectedProgram = widget.request!.program;

    for (var key in _requiredDocuments.keys) {
      _requiredDocuments[key] = true;
    }
  }

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
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Informations Personnelles'),
              const SizedBox(height: 16),
              _buildTextFormField(
                'Nom Complet',
                _fullNameController,
                TextInputType.name,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                'Email',
                _emailController,
                TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                'Téléphone',
                _phoneController,
                TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                'Adresse',
                _addressController,
                TextInputType.streetAddress,
              ),
              const SizedBox(height: 16),
              _buildDatePicker(),
              const SizedBox(height: 16),
              _buildScholarshipSwitch(),

              _buildSectionHeader('Programme Académique'),
              const SizedBox(height: 16),
              _buildProgramDropdown(),

              _buildSectionHeader('Documents Requis'),
              const SizedBox(height: 16),
              ..._buildDocumentChecklist(),
              const SizedBox(height: 16),
              _buildDocumentUploadSection(),
              if (_documents.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildUploadedDocumentsList(),
              ],

              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        widget.request == null ? 'Nouvelle Demande' : 'Modifier Demande',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: const Color(0xFF006D77),
      elevation: 0,
      centerTitle: true,
      shape: const ContinuousRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (widget.request != null)
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _showDeleteDialog,
          ),
      ],
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

  Widget _buildTextFormField(
    String label,
    TextEditingController controller,
    TextInputType inputType,
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: TextStyle(color: Colors.grey.shade700),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF006D77), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator:
          (value) => value?.isEmpty ?? true ? 'Ce champ est obligatoire' : null,
    );
  }

  Widget _buildScholarshipSwitch() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade50,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SwitchListTile(
        title: Text(
          'Bénéficiaire d\'une bourse',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
        ),
        value: _hasScholarship,
        onChanged: (value) => setState(() => _hasScholarship = value),
        activeColor: const Color(0xFF006D77),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () => _selectBirthDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date de naissance',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF006D77), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _birthDate != null
                  ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                  : 'Sélectionnez une date',
              style: TextStyle(
                color: _birthDate != null ? Colors.black : Colors.grey.shade600,
              ),
            ),
            Icon(Icons.calendar_today, color: const Color(0xFF006D77)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Programme souhaité',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF006D77), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
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
      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF006D77)),
      borderRadius: BorderRadius.circular(12),
      dropdownColor: Colors.white,
      style: TextStyle(color: Colors.grey.shade800, fontSize: 16),
    );
  }

  List<Widget> _buildDocumentChecklist() {
    return _requiredDocuments.entries.map((entry) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.grey.shade50,
        ),
        child: CheckboxListTile(
          title: Text(entry.key, style: TextStyle(color: Colors.grey.shade800)),
          value: entry.value,
          onChanged:
              (value) => setState(
                () => _requiredDocuments[entry.key] = value ?? false,
              ),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: const Color(0xFF006D77),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildDocumentUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Fichiers à uploader',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.attach_file, color: Color(0xFF006D77)),
          label: const Text(
            'Ajouter des documents',
            style: TextStyle(color: Color(0xFF006D77)),
          ),
          onPressed: _pickDocuments,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: BorderSide(color: const Color(0xFF006D77).withOpacity(0.5)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        ..._documents.map((file) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF83C5BE).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.description, color: Color(0xFF006D77)),
              ),
              title: Text(
                file.name,
                style: TextStyle(color: Colors.grey.shade800),
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => setState(() => _documents.remove(file)),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
          backgroundColor: const Color(0xFF006D77),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: const Color(0xFF006D77).withOpacity(0.3),
        ),
        onPressed: _isLoading ? null : _submitForm,
        child:
            _isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
                : Text(
                  widget.request == null
                      ? 'SOUMETTRE LA DEMANDE'
                      : 'METTRE À JOUR',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning, size: 48, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text(
                    'Supprimer la demande',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Êtes-vous sûr de vouloir supprimer cette demande ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Annuler'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            await _deleteRequest();
                          },
                          child: const Text('Supprimer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _deleteRequest() async {
    setState(() => _isLoading = true);
    try {
      await _databaseService.deleteRequest(widget.request!.id!);
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demande supprimée avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF006D77),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
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
            'Documents manquants: ${missingDocs.join(', ')}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    if (_documents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez ajouter au moins un document',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      Map<String, String> uploadedDocs = {};

      if (_documents.isNotEmpty) {
        uploadedDocs = await _storageService.uploadMultipleFiles(
          'documents',
          _documents,
          prefix:
              '${_fullNameController.text}_${DateTime.now().millisecondsSinceEpoch}'
                  .replaceAll(RegExp(r'[^\w-]'), '_'),
        );
      }

      if (widget.request != null) {
        uploadedDocs.addAll(widget.request!.documents);
      }

      final request = AdmissionRequest(
        id: widget.request?.id,
        userId: Supabase.instance.client.auth.currentUser!.id,
        fullName: _fullNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        birthDate: _birthDate?.toIso8601String(),
        program: _selectedProgram!,
        hasScholarship: _hasScholarship,
        documents: uploadedDocs,
        status: widget.request?.status ?? 'pending',
        submissionDate:
            widget.request?.submissionDate ?? DateTime.now().toIso8601String(),
        decisionDate: widget.request?.decisionDate,
        comments: widget.request?.comments,
      );

      if (widget.request == null) {
        await _databaseService.saveRequest(request);
      } else {
        await _databaseService.updateRequest(request);
      }

      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.request == null
                ? 'Demande soumise avec succès!'
                : 'Demande mise à jour avec succès!',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF006D77),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur: ${e.toString()}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
