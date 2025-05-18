import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(File file) async {
    try {
      final fileName =
          'documents/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final ref = _storage.ref().child(fileName);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw 'Erreur lors de l\'upload: ${e.toString()}';
    }
  }

  Future<Map<String, String>> uploadMultipleFiles(List<XFile> xFiles) async {
    final Map<String, String> urls = {};

    for (final xFile in xFiles) {
      final file = File(xFile.path);
      final url = await uploadFile(file);
      urls[xFile.name] = url;
    }

    return urls;
  }
}
