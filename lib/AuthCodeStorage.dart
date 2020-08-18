import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AuthCodeStorage {
  static final AuthCodeStorage _instance = AuthCodeStorage._new();

  factory AuthCodeStorage() => _instance;

  AuthCodeStorage._new();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/auth_code');
  }

  Future<String> read() async {
    final file = await _localFile;
    final exists = await file.exists();
    return exists ? await file.readAsString() : '';
  }

  Future<bool> isSaved() async {
    final file = await _localFile;
    return file.exists();
  }

  void save(String authCode) async {
    final file = await _localFile;
    file.writeAsString(authCode);
  }
}
