import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileStorage {
  Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future readFile(String file_name) async {
    final path = await localPath;
    File _localFile = File('$path/$file_name');
    try {
      final file = await _localFile;
      String content = await file.readAsString();
      return content;
    } catch (e) {
      return '';
    }
  }

  Future writeFile(String text, String file_name) async {
    final path = await localPath;
    File _localFile = File('$path/$file_name');
    final file = await _localFile;
    return file.writeAsStringSync('$text\n', mode: FileMode.append);
  }

  Future cleanFile(String file_name) async {
    final path = await localPath;
    File _localFile = File('$path/$file_name');
    final file = await _localFile;
    return file.writeAsString('');
  }

  Future<File> loadAvatar(String file_name) async {
    final path = await localPath;
    File _localFile = new File('$path/images/avt/$file_name');
    return _localFile;
  }

  Future<void> deleteFile(String path_file) async{
    final path = await localPath;
    File _localFile = File('$path/$path_file');
    _localFile.delete();
  }
}