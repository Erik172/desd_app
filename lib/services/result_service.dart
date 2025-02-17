// ignore_for_file: use_build_context_synchronously
import 'dart:io' as io;
import 'dart:convert';
import 'package:desd_app/utils/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

class ResultService {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await secureStorage.read(key: 'token');
  }

  void _handleResponse(BuildContext context, http.Response response) {
    if (response.statusCode == 401) {
      context.go('/logout');
      throw UnauthorizedException('Unauthorized');
    } else if (response.statusCode >= 400) {
      throw HttpException('Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> fetchResults({
    required BuildContext context,
    int page = 1,
    int perPage = 50,
    int? userId,
    String? status,
  }) async {
    final String baseUrl = await Constants.apiBaseUrl;
    final String url = '$baseUrl/api/v1/task?status=$status';

    return await _request(context, url, 'GET');
  }

  Future<void> downloadResult({
    required BuildContext context,
    required String collectionId,
  }) async {
    final String baseUrl = await Constants.apiBaseUrl;
    final String url = '$baseUrl/api/v1/export/$collectionId';

    final response = await _request(context, url, 'GET', returnRawResponse: true) as http.Response;

    if (kIsWeb) {
      _downloadWeb(response.bodyBytes, collectionId);
    } else {
      await _downloadDesktop(response.bodyBytes, collectionId);
    }
  }

  Future<void> deleteResult({
    required BuildContext context,
    required String collectionId,
  }) async {
    final String baseUrl = await Constants.apiBaseUrl;
    final String url = '$baseUrl/api/v1/task/$collectionId';

    await _request(context, url, 'DELETE');
  }

  Future<Map<String, dynamic>> getResultStatus({
    required BuildContext context,
    required String collectionId,
  }) async {
    final String baseUrl = await Constants.apiBaseUrl;
    final String url = '$baseUrl/api/v1/task/$collectionId';

    return await _request(context, url, 'GET');
  }

  // --------------------------------
  // MÉTODOS AUXILIARES
  // --------------------------------

  Future<dynamic> _request(
    BuildContext context,
    String url,
    String method, {
    bool returnRawResponse = false,
  }) async {
    final String? token = await _getToken();
    final headers = {'Authorization': 'Bearer $token'};

    http.Response response;
    if (method == 'GET') {
      response = await http.get(Uri.parse(url), headers: headers);
    } else if (method == 'DELETE') {
      response = await http.delete(Uri.parse(url), headers: headers);
    } else {
      throw UnsupportedError('Método HTTP no soportado: $method');
    }

    _handleResponse(context, response);

    if (returnRawResponse) {
      return response;
    }

    if (response.body.isEmpty) {
      return {}; // Return an empty map if the response body is empty
    }

    try {
      return json.decode(response.body);
    } catch (e) {
      throw FormatException('Error decoding response body: ${response.body}');
    }
  }

  void _downloadWeb(List<int> bytes, String fileName) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    // ignore: unused_local_variable
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', '$fileName.csv')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  Future<void> _downloadDesktop(List<int> bytes, String fileName) async {
    final String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Guardar archivo como',
      fileName: '$fileName.csv',
    );

    if (outputFile != null) {
      final file = io.File(outputFile);
      await file.writeAsBytes(bytes);
    } else {
      debugPrint('File not saved');
    }
  }
}

// --------------------------------
// CLASES AUXILIARES PARA EXCEPCIONES
// --------------------------------
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
  @override
  String toString() => 'UnauthorizedException: $message';
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  @override
  String toString() => 'HttpException: $message';
}
