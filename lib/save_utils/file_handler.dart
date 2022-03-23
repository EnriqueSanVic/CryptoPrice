import 'dart:io';
import 'package:path_provider/path_provider.dart';

/**
 * Clase para manejar el contenido de un fichero
 */
class FileHandler {
  String fichero;

  FileHandler(this.fichero);

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/' + fichero);
  }

  Future<File> escribirFichero(String contenido) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(contenido);
  }

  Future<String> leerFichero() async {
    try {
      final file = await _localFile;

      // Read the file
      final contenido = await file.readAsString();

      return contenido;
    } catch (e) {
      // If encountering an error, return 0
      return "Error";
    }
  }
}
