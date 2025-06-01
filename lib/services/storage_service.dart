import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
        final fileName =
            '${prefix ?? ''}_${DateTime.now().millisecondsSinceEpoch}_${file.name}'
                .replaceAll(RegExp(r'[^\w.-]'), '_');

        final fileBytes = await file.readAsBytes();

        await _client.storage
            .from(bucketName)
            .upload(fileName, fileBytes as File);

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
}
