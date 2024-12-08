// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:desd_app/services/file_service.dart';
import 'package:desd_app/services/result_service.dart';
import 'package:desd_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class AuditoriaViewModel extends ChangeNotifier {
  final FileService _fileService = FileService();
  String? _selectedDirectory;
  String? _resultId;
  int _numFiles = 0;
  bool _isProcessing = false;
  Map<String, dynamic> _status = {};

  final List<String> _models = ['Rotacion', 'Inclinacion', 'Corte informacion'];
  final List<String> _selectedModels = [];

  List<String> get models => _models;
  List<String> get selectedModels => _selectedModels;
  String? get selectedDirectory => _selectedDirectory;
  String? get resultId => _resultId;
  int get numFiles => _numFiles;
  bool get isProcessing => _isProcessing;
  Map<String, dynamic> get status => _status;


  void toggleModelSelection(String model) {
    if (_selectedModels.contains(model)) {
      _selectedModels.remove(model);
    } else {
      _selectedModels.add(model);
    }

    notifyListeners();
  }

  /// Selecciona un directorio utilizando el servicio de archivos y actualiza
  /// el estado con la información del directorio seleccionado.
  ///
  /// Este método abre un selector de directorios para que el usuario elija
  /// un directorio. Si el usuario no selecciona un directorio, el método
  /// termina sin hacer nada. Si se selecciona un directorio, se verifica
  /// que exista y se obtiene la lista de archivos dentro del directorio
  /// de manera recursiva (sin seguir enlaces simbólicos).
  ///
  /// Luego, se actualiza la variable `_selectedDirectory` con la ruta del
  /// directorio seleccionado y `_numFiles` con el número de archivos en
  /// el directorio. Finalmente, se notifica a los oyentes del cambio de estado.
  Future<void> pickDirectory() async {
    final selectedDirectory = await _fileService.pickDirectory();
    if (selectedDirectory == null) return;

    final directory = Directory(selectedDirectory);
    if (!directory.existsSync()) return;

    final files = directory.listSync(recursive: true, followLinks: false);

    _selectedDirectory = selectedDirectory;
    _numFiles = files.length;
    notifyListeners();
  }

  /// Procesa los archivos seleccionados y los envía a la API para su auditoría.
  ///
  /// Muestra mensajes de error si no se ha seleccionado un directorio o al menos un modelo.
  /// Utiliza `FlutterSecureStorage` para obtener el token de autenticación.
  /// Envía una solicitud `MultipartRequest` con los archivos y modelos seleccionados.
  /// Muestra un mensaje de éxito o error según la respuesta de la API.
  ///
  /// Parámetros:
  /// - `context`: El contexto de la aplicación.
  ///
  /// Retorna:
  /// - `Future<void>`: Un futuro que se completa cuando se ha procesado la solicitud.
  Future<void> processFiles(BuildContext context) async {
    if (_selectedDirectory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione un directorio primero.'),
        ),
      );
      return;
    }

    if (_selectedModels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione al menos un modelo.'),
        ),
      );
      return;
    }

    _isProcessing = true;
    notifyListeners();

    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    final String? token = await secureStorage.read(key: 'token');

    final files = Directory(_selectedDirectory!).listSync(recursive: true, followLinks: false);
    final allowedExtensions = ['pdf', 'jpg', 'png', 'tif', 'tiff'];
    final filteredFiles = files.where((file) {
      final extension = file.path.split('.').last.toLowerCase();
      return allowedExtensions.contains(extension);
    }).toList();
    final filesPaths = filteredFiles.map((file) => file.path).toList();

    _numFiles = filesPaths.length;
    notifyListeners();

    final uri = Uri.parse('${Constants.apiBaseUrl}/api/v1/desd');

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    // pasar los modelos seleccionados a lowercase
    request.fields['models'] = _selectedModels.map((model) => model.toLowerCase()).join(',');
    // generar un id aleatorio para la auditoria
    // request.fields['result_id'] = DateTime.now().millisecondsSinceEpoch.toString();
    request.fields['result_id'] = generateId(path: _selectedDirectory!);

    _resultId = request.fields['result_id'];
    notifyListeners();

    for (var filePath in filesPaths) {
      final file = File(filePath);
      final fileStream = http.ByteStream(file.openRead());
      final length = await file.length();
      final multipartFile = http.MultipartFile(
        'files',
        fileStream,
        length,
        filename: file.uri.pathSegments.last,
      );
      request.files.add(multipartFile);
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Auditoría procesada con éxito. ID: $_resultId'),
        ),
      );
    } else if (response.statusCode == 401) {
      GoRouter.of(context).go('/logout');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al procesar los archivos.'),
        ),
      );
    }
    _isProcessing = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> getStatus({required BuildContext context, required String resultId}) async {
    final ResultService resultService = ResultService();
    final response = await resultService.getResultStatus(context: context, collectionId: resultId);

    return response;
  }

  String generateId({required String path}) {
    // crear un id que sea el path del archivo quitanado los caracteres especiales y cambiando '/' por '_' 
    return path.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
  }
}