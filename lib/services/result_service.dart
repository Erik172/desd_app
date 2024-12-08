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

  void _handleResponse({required BuildContext context, required http.Response response}) {
    if (response.statusCode == 401) {
      context.go('/logout');
      throw Exception('Unauthorized');
    } else if (response.statusCode != 200) {
      print('Error: ${response.body}');
      throw Exception('Error: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> fetchResults({required BuildContext context, int page = 1, int perPage = 50}) async {
    final token = await _getToken();
    final url = '${Constants.apiBaseUrl}/api/v1/results?page=$page&per_page=$perPage';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    _handleResponse(context: context, response: response);

    return json.decode(response.body);
  }

  Future<void> downloadResult({required BuildContext context, required String collectionId}) async {
    final token = await _getToken();
    final url = '${Constants.apiBaseUrl}/api/v1/results/$collectionId/export';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    _handleResponse(context: context, response: response);

    if (kIsWeb) {
      // Guardar archivo en la web
      final bytes = response.bodyBytes;
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      // ignore: unused_local_variable
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', '$collectionId.csv')
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // Guardar archivo en escritorio
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar archivo como',
        fileName: '$collectionId.csv',
      );

      if (outputFile != null) {
        final file = io.File(outputFile);
        await file.writeAsBytes(response.bodyBytes);
        print('File saved to: $outputFile');
      } else {
        print('File not saved');
      }
    }
  }

  Future<void> deleteResult({required BuildContext context, required String collectionId}) async {
    final token = await _getToken();
    final url = '${Constants.apiBaseUrl}/api/v1/results/$collectionId';

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    _handleResponse(context: context, response: response);
  }

  Future<Map<String, dynamic>> getResultStatus({required BuildContext context, required String collectionId}) async {
    final token = await _getToken();
    final url = '${Constants.apiBaseUrl}/api/v1/results/$collectionId';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    _handleResponse(context: context, response: response);

    return json.decode(response.body);
  }
}