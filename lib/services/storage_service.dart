import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class LocalStorageService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> saveFileLocally(File file) async {
    final path = await _localPath;
    final fileName = file.path.split('/').last;
    return file.copy('$path/$fileName');
  }

  Future<Map<String, String>> saveMultipleFilesLocally(
    List<XFile> xFiles,
  ) async {
    final Map<String, String> paths = {};

    for (final xFile in xFiles) {
      final file = File(xFile.path);
      final savedFile = await saveFileLocally(file);
      paths[xFile.name] = savedFile.path;
    }

    return paths;
  }
}
