import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:demande_admission/models/admission_request.dart';
import 'package:demande_admission/services/storage_service.dart';
import 'package:demande_admission/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RequestFormScreen extends StatefulWidget {
  @override
  _RequestFormScreenState createState() => _RequestFormScreenState();
}

class _RequestFormScreenState extends State<RequestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<XFile> _documents = [];
  final _picker = ImagePicker();
  final _programs = [
    'Licence Informatique',
    'Master Finance',
    'Doctorat Physique',
  ];
  String? _selectedProgram;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nouvelle demande')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sélection du programme
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Programme',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.teal.withOpacity(0.1),
                ),
                value: _selectedProgram,
                items:
                    _programs.map((program) {
                      return DropdownMenuItem(
                        value: program,
                        child: Text(program),
                      );
                    }).toList(),
                onChanged: (value) => setState(() => _selectedProgram = value),
                validator:
                    (value) => value == null ? 'Choisissez un programme' : null,
              ),
              SizedBox(height: 24),

              // Section documents
              Text(
                'Documents requis',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ..._buildDocumentList(),
              SizedBox(height: 16),
              OutlinedButton.icon(
                icon: Icon(Icons.attach_file),
                label: Text('Ajouter des documents'),
                onPressed: _pickDocuments,
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 32),

              // Bouton de soumission
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  onPressed: _isLoading ? null : _submitForm,
                  child:
                      _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Soumettre la demande'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDocumentList() {
    return _documents.map((file) {
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
    }).toList();
  }

  Future<void> _pickDocuments() async {
    try {
      final result = await _picker.pickMultiImage();
      if (result != null) {
        setState(() => _documents.addAll(result));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_documents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez ajouter au moins un document')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final urls = await LocalStorageService().saveMultipleFilesLocally(
        _documents,
      );

      final request = AdmissionRequest(
        userId: FirebaseAuth.instance.currentUser!.uid,
        program: _selectedProgram!,
        documents: urls,
        submissionDate: DateTime.now().toIso8601String(),
      );

      await DatabaseService().saveRequest(request);

      Navigator.pop(context); // Retour à l'accueil après succès
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
