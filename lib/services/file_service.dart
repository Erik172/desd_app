import 'dart:io';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class FileService {
  /// Selecciona múltiples archivos de tipos específicos utilizando el FilePicker.
  /// 
  /// Retorna una lista de rutas de archivos seleccionados o `null` si no se seleccionaron archivos.
  /// 
  /// Tipos de archivos permitidos: `pdf`, `png`, `jpg`, `tif`, `tiff`, `jpeg`.
  /// 
  /// Maneja cualquier excepción que ocurra durante la selección de archivos y 
  /// imprime un mensaje de error en la consola.
  /// 
  /// Ejemplo de uso:
  /// 
  /// ```dart
  /// List<String?>? archivos = await pickFiles();
  /// if (archivos != null) {
  ///   // Procesar archivos seleccionados
  /// } else {
  ///   // No se seleccionaron archivos
  /// }
  /// ```
  /// 
  /// Retorna:
  /// - `List<String?>?`: Lista de rutas de archivos seleccionados o `null` si no se seleccionaron archivos.
  Future<List<String?>?> pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'tif', 'tiff', 'jpeg'],
      );

      if (result != null) {
        return result.paths;
      } else {
        return null;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error picking files: $e');
      return null;
    }
  }

  /// Selecciona un directorio utilizando el FilePicker y devuelve la ruta del directorio seleccionado.
  /// 
  /// Retorna la ruta del directorio seleccionado como una cadena de texto, o `null` si no se selecciona ningún directorio.
  /// 
  /// En caso de error, imprime un mensaje de error y retorna `null`.
  /// 
  /// Returns:
  ///   - `Future<String?>`: La ruta del directorio seleccionado o `null` si no se selecciona ningún directorio o ocurre un error.
  Future<String?> pickDirectory() async {
    try {
      String? directoryPath = await FilePicker.platform.getDirectoryPath();

      if (directoryPath != null) {
        return directoryPath;
      } else {
        return null;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error picking directory: $e');
      return null;
    }
  }

  /// Crea un archivo ZIP a partir de una lista de archivos proporcionada.
  ///
  /// Este método toma una lista de rutas de archivos y los comprime en un 
  /// archivo ZIP. Devuelve la ruta del archivo ZIP creado o `null` si ocurre 
  /// algún error.
  ///
  /// Parámetros:
  /// - `files`: Una lista de rutas de archivos que se deben comprimir.
  ///
  /// Retorna:
  /// - Una `Future` que resuelve a una cadena que representa la ruta del 
  ///   archivo ZIP creado, o `null` si ocurre un error.
  Future<String?> createZip({required List<String> files}) async {
    try {
      // Create a new ZIP file
      final archive = Archive();

      for (String filePath in files) {
        final file = File(filePath);
        final fileName = file.uri.pathSegments.last;
        final fileBytes = file.readAsBytesSync();

        // Add the file to the archive
        archive.addFile(ArchiveFile(fileName, fileBytes.length, fileBytes));
      }

      // Encode the archive to a ZIP file
      final zipEncoder = ZipEncoder();
      final zipData = zipEncoder.encode(archive);

      // Get the temporary directory
      final tempDir = await getTemporaryDirectory();
      final zipFilePath = '${tempDir.path}\\compressed_files.zip';

      // Save the ZIP file
      final zipFile = File(zipFilePath);
      await zipFile.writeAsBytes(zipData);

      return zipFilePath;
    } catch (e) {
      // ignore: avoid_print
      print('Error creating ZIP file: $e');
      return null;
    }
  }
}