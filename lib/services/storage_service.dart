import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Map<String, String>> uploadMultipleFiles(
    String bucketName,
    List<XFile> files, {
    String? prefix,
  }) async {
    final Map<String, String> uploadedFiles = {};

    for (final file in files) {
      try {
        // Génération du nom de fichier sécurisé
        final fileName = _generateFileName(file.name, prefix: prefix);

        // Conversion du XFile en Uint8List
        final fileBytes = await file.readAsBytes();

        // Upload vers Supabase Storage
        await _client.storage
            .from(bucketName)
            .uploadBinary(
              fileName,
              fileBytes,
              fileOptions: FileOptions(contentType: _getMimeType(file.name)),
            );

        // Récupération de l'URL publique
        final publicUrl = _client.storage
            .from(bucketName)
            .getPublicUrl(fileName);

        uploadedFiles[file.name] = publicUrl;
      } catch (e) {
        throw 'Erreur lors de l\'upload de ${file.name}: $e';
      }
    }

    return uploadedFiles;
  }

  String _generateFileName(String originalName, {String? prefix}) {
    return '${prefix ?? ''}_${DateTime.now().millisecondsSinceEpoch}_$originalName'
        .replaceAll(RegExp(r'[^\w.-]'), '_')
        .replaceAll(' ', '_');
  }

  String? _getMimeType(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }
}
