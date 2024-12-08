import 'package:file_picker/file_picker.dart';

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
}