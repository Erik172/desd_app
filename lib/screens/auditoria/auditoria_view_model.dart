// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'dart:async';
import 'package:desd_app/services/file_service.dart';
import 'package:desd_app/services/result_service.dart';
import 'package:desd_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuditoriaViewModel extends ChangeNotifier {
  final FileService _fileService = FileService();
  String? _selectedDirectory;
  String? _resultId;
  int _numFiles = 0;
  bool _isProcessing = false;
  Map<String, dynamic> _status = {};
  double _progress = 0.0;
  String _currentFile = '';

  final List<String> _models = ['Rotacion', 'Inclinacion', 'Corte informacion'];
  final List<String> _selectedModels = [];

  Timer? _progressTimer;

  List<String> get models => _models;
  List<String> get selectedModels => _selectedModels;
  String? get selectedDirectory => _selectedDirectory;
  String? get resultId => _resultId;
  int get numFiles => _numFiles;
  bool get isProcessing => _isProcessing;
  Map<String, dynamic> get status => _status;
  double get progress => _progress;
  String get currentFile => _currentFile;

  void toggleModelSelection(String model) {
    if (_selectedModels.contains(model)) {
      _selectedModels.remove(model);
    } else {
      _selectedModels.add(model);
    }

    notifyListeners();
  }

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

    // Start the timer to update progress every second
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateProgress(context);
    });

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

    // Comprimir los archivos en un archivo ZIP
    final zipFilePath = await _fileService.createZip(files: filesPaths);
    if (zipFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al comprimir los archivos.'),
        ),
      );
      _isProcessing = false;
      notifyListeners();
      return;
    }

    final uri = Uri.parse('${await Constants.apiBaseUrl}/api/v1/desd');

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['models'] = _selectedModels.map((model) => model.toLowerCase()).join(',');
    request.fields['result_id'] = generateId(path: _selectedDirectory!);

    _resultId = request.fields['result_id'];
    notifyListeners();

    // Añadir el archivo ZIP al request
    final zipFile = File(zipFilePath);
    final fileStream = http.ByteStream(zipFile.openRead());
    final length = await zipFile.length();
    final multipartFile = http.MultipartFile(
      'files',
      fileStream,
      length,
      filename: File(zipFilePath).uri.pathSegments.last,
    );
    request.files.add(multipartFile);

    final response = await request.send();

    // Stop the timer when the response is received
    response.stream.transform(utf8.decoder).listen((value) {
      // Parse the progress update from the server response
      final progressUpdate = json.decode(value);
      _progress = progressUpdate['progress'];
      _currentFile = progressUpdate['current_file'];
      notifyListeners();
    }).onDone(() {
      _progressTimer?.cancel();
      _isProcessing = false;
      notifyListeners();
    });

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Auditoría procesada con éxito. ID: $_resultId'),
        ),
      );
    } else if (response.statusCode == 401) {
      GoRouter.of(context).go('/logout');
    } else if (response.statusCode == 422) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este directorio ya se está procesando.'),
          duration: Duration(seconds: 10),
        ),
      );
    }else {
      final responseBody = await response.stream.bytesToString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al procesar los archivos: $responseBody'),
          duration: const Duration(seconds: 10),
        ),
      );
    }
    _isProcessing = false;
    notifyListeners();
  }

  Future<void> _updateProgress(BuildContext context) async {
    if (_resultId == null) return;

    try {
      final status = await getStatus(context: context, resultId: _resultId!);
      final totalFiles = status['status']['total_files'];
      final processedFiles = status['status']['total_files_processed'];

      if (totalFiles != null && processedFiles != null && totalFiles > 0) {
        _progress = processedFiles / totalFiles;
      } else {
        _progress = 0.0;
      }

      _currentFile = status['status']['current_file'] ?? '';
      notifyListeners();
    } catch (e) {
      print('Error updating progress: $e');
    }
  }

  Future<Map<String, dynamic>> getStatus({required BuildContext context, required String resultId}) async {
    final ResultService resultService = ResultService();
    final response = await resultService.getResultStatus(context: context, collectionId: resultId);

    return response;
  }

  String generateId({required String path}) {
    return path.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
  }

  void reset() {
    _selectedDirectory = null;
    _resultId = null;
    _numFiles = 0;
    _isProcessing = false;
    _status = {};
    _progress = 0.0;
    _currentFile = '';
    _selectedModels.clear();
    _progressTimer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }
}