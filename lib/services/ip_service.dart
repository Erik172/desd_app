// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:desd_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class IpService {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final BuildContext context;

  IpService({required this.context});

  Future<String?> _getToken() async {
    return await secureStorage.read(key: 'token');
  }

  void _handleResponse(http.Response response) {
    if (response.statusCode == 401) {
      throw UnauthorizedException('Unauthorized');
    } else if (response.statusCode >= 400) {
      throw HttpException('Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> fetchAllowedIps() async {
    final String baseUrl = await Constants.apiBaseUrl;
    final String url = '$baseUrl/api/v1/admin/allowed_ips';

    final response = await _request(context, url, 'GET', returnRawResponse: true);

    if (response.body.isEmpty) {
      throw const FormatException('Empty response body');
    }

    final List<dynamic> responseBody = json.decode(response.body);
    return {'allowed_ips': responseBody};
  }

  Future<void> addAllowedIp(String ip) async {
    final String baseUrl = await Constants.apiBaseUrl;
    final String url = '$baseUrl/api/v1/admin/allowed_ips';

    final response = await _request(
      context,
      url,
      'POST',
      body: {'ip': ip},
    );
    _handleResponse(response);
  }

  Future<void> deleteAllowedIp(int ipId) async {
    print('Deleting IP: $ipId');
    final String baseUrl = await Constants.apiBaseUrl;
    final String url = '$baseUrl/api/v1/admin/allowed_ips/$ipId';

    final response = await _request(context, url, 'DELETE');
    _handleResponse(response);
  }

  // --------------------------------
  // MÉTODOS AUXILIARES
  // --------------------------------

  Future<http.Response> _request(
    BuildContext context,
    String url,
    String method, {
    Map<String, dynamic>? body,
    bool returnRawResponse = false,
  }) async {
    final String? token = await _getToken();
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    http.Response response;
    if (method == 'GET') {
      response = await http.get(Uri.parse(url), headers: headers);
    } else if (method == 'POST') {
      response = await http.post(Uri.parse(url), headers: headers, body: json.encode(body));
    } else if (method == 'PUT') {
      response = await http.put(Uri.parse(url), headers: headers, body: json.encode(body));
    } else if (method == 'DELETE') {
      response = await http.delete(Uri.parse(url), headers: headers);
    } else {
      throw UnsupportedError('Método HTTP no soportado: $method');
    }

    if (returnRawResponse) {
      return response;
    }

    if (response.body.isEmpty && method != 'DELETE') {
      throw const FormatException('Empty response body');
    }

    return response;
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
