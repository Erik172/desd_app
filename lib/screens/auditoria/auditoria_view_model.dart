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

class AuditoriaViewModel extends ChangeNotifier {
  late final FileService _fileService;
  late final FlutterSecureStorage _secureStorage;

  String? _selectedDirectory;
  String? _resultId;
  int _numFiles = 0;
  bool _isProcessing = false;
  Map<String, dynamic> _status = {};
  double _progress = 0.0;
  String _currentFile = '';

  final List<String> _models = ['Rotacion', 'Inclinacion', 'Corte informacion', 'Legibilidad'];
  final List<String> _selectedModels = [];

  final Map<String, String> _modelNamesMap = {
    'Rotacion': 'rode',
    'Inclinacion': 'tilde',
    'Corte informacion': 'cude',
    'Legibilidad': 'legibility',
  };

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

  AuditoriaViewModel() {
    _fileService = FileService();
    _secureStorage = const FlutterSecureStorage();
  }

  void toggleModelSelection(String model) {
    _selectedModels.contains(model) ? _selectedModels.remove(model) : _selectedModels.add(model);
    notifyListeners();
  }

  Future<void> pickDirectory() async {
    final selectedDirectory = await _fileService.pickDirectory();
    if (selectedDirectory == null) return;

    final directory = Directory(selectedDirectory);
    if (!directory.existsSync()) return;

    final files = await directory.list(recursive: true, followLinks: false).toList();

    _selectedDirectory = selectedDirectory;
    _numFiles = files.length;
    notifyListeners();
  }

  void _showSnackBar(BuildContext context, String message, {int duration = 3}) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: duration),
        ),
      );
    }
  }

  Future<void> processFiles(BuildContext context) async {
    if (_selectedDirectory == null) {
      _showSnackBar(context, 'Seleccione un directorio primero.');
      return;
    }

    if (_selectedModels.isEmpty) {
      _showSnackBar(context, 'Seleccione al menos un modelo.');
      return;
    }

    _isProcessing = true;
    notifyListeners();

    // Iniciar temporizador de progreso
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) => _updateProgress(context));

    final token = await _secureStorage.read(key: 'token');

    final files = await Directory(_selectedDirectory!).list(recursive: true, followLinks: false).toList();
    final allowedExtensions = {'pdf', 'jpg', 'png', 'tif', 'tiff'};
    final filesPaths = files
        .where((file) => allowedExtensions.contains(file.path.split('.').last.toLowerCase()))
        .map((file) => file.path)
        .toList();

    _numFiles = filesPaths.length;
    notifyListeners();

    // Comprimir archivos
    final zipFilePath = await _fileService.createZip(files: filesPaths);
    if (zipFilePath == null) {
      _showSnackBar(context, 'Error al comprimir los archivos.');
      _isProcessing = false;
      notifyListeners();
      return;
    }

    final uri = Uri.parse('${await Constants.apiBaseUrl}/api/v1/worker');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['models'] = _selectedModels.map((model) => _modelNamesMap[model]!).join(',')
      ..fields['task_id'] = generateId(path: _selectedDirectory!)
      ..files.add(await _createMultipartFile(zipFilePath));

    _resultId = request.fields['task_id'];
    notifyListeners();

    try {
      final response = await request.send();
      _handleResponse(response, context);
    } on TimeoutException {
      _showSnackBar(context, 'Request timed out. Please check your connection.');
    } on SocketException {
      _showSnackBar(context, 'Network error. Check your connection.');
    } on HttpException catch (e) {
      _showSnackBar(context, 'HTTP error: $e');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      _showSnackBar(context, 'Unexpected error occurred.');
    } finally {
      _isProcessing = false;
      _progressTimer?.cancel();
      notifyListeners();
    }
  }

  Future<http.MultipartFile> _createMultipartFile(String filePath) async {
    final file = File(filePath);
    return http.MultipartFile(
      'files',
      file.openRead(),
      await file.length(),
      filename: file.uri.pathSegments.last,
    );
  }

  Future<void> _handleResponse(http.StreamedResponse response, BuildContext context) async {
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 202) {
      _showSnackBar(context, 'Auditoría Agregada al sistema. Puede revisar el progreso en la sección de resultados.');
    } else if (response.statusCode == 401) {
      if (context.mounted) context.go('/logout');
    } else if (response.statusCode == 422) {
      _showSnackBar(context, 'Este directorio ya se está procesando.', duration: 10);
    } else {
      _showSnackBar(context, 'Error al procesar los archivos: $responseBody', duration: 10);
    }
  }

  Future<void> _updateProgress(BuildContext context) async {
    if (_resultId == null) return;

    try {
      final status = await getStatus(context, _resultId!);
      final totalFiles = status['status']['total_files'];
      final processedFiles = status['status']['total_files_processed'];

      _progress = (totalFiles != null && processedFiles != null && totalFiles > 0) ? processedFiles / totalFiles : 0.0;
      _currentFile = status['status']['current_file'] ?? '';
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating progress: $e');
    }
  }

  Future<Map<String, dynamic>> getStatus(BuildContext context, String resultId) async {
    return await ResultService().getResultStatus(context: context, collectionId: resultId);
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