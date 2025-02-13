import 'dart:convert';

import 'package:desd_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class IpService {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final BuildContext context;

  IpService({required this.context});

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

  Future<Map<String, dynamic>> fetchAllowedIps() async {
    final String baseUrl = await Constants.apiBaseUrl;
    final String url = '$baseUrl/api/v1/admin/allowed_ips';

    final response = await _request(context, url, 'GET', returnRawResponse: true) as http.Response;

    if (response.body.isEmpty) {
      throw FormatException('Empty response body');
    }

    final List<dynamic> responseBody = json.decode(response.body);
    return {'allowed_ips': responseBody};
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
      throw FormatException('Empty response body');
    }

    try {
      return json.decode(response.body);
    } catch (e) {
      throw FormatException('Error decoding response body: ${response.body}');
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
