import 'dart:convert';
import 'package:desd_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class UserService {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final BuildContext context;

  UserService({required this.context});

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

  Future<void> deleteUser(int userId) async {
    final String baseUrl = await Constants.apiBaseUrl;
    final String url = '$baseUrl/api/v1/admin/user/$userId';

    final response = await _request(context, url, 'DELETE');
    _handleResponse(response);
  }

  Future<http.Response> _request(
    BuildContext context,
    String url,
    String method, {
    Map<String, dynamic>? body,
  }) async {
    final String? token = await _getToken();
    final headers = {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};

    http.Response response;
    switch (method) {
      case 'GET':
        response = await http.get(Uri.parse(url), headers: headers);
        break;
      case 'POST':
        response = await http.post(Uri.parse(url), headers: headers, body: json.encode(body));
        break;
      case 'PUT':
        response = await http.put(Uri.parse(url), headers: headers, body: json.encode(body));
        break;
      case 'PATCH':
        response = await http.patch(Uri.parse(url), headers: headers, body: json.encode(body));
        break;
      case 'DELETE':
        response = await http.delete(Uri.parse(url), headers: headers);
        break;
      default:
        throw UnsupportedError('Método HTTP no soportado: $method');
    }

    return response;
  }

  Future<List<dynamic>> fetchUsers() async {
    final response = await _request(context, '${await Constants.apiBaseUrl}/api/v1/admin/user', 'GET');
    _handleResponse(response);
    return json.decode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> fetchUser(String userId) async {
    final response = await _request(context, '${await Constants.apiBaseUrl}/api/v1/admin/user/$userId', 'GET');
    _handleResponse(response);
    return json.decode(response.body);
  }

  Future<void> createUser(Map<String, dynamic> user) async {
    final response = await _request(context, '${await Constants.apiBaseUrl}/api/v1/user', 'POST', body: user);
    _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateUser(String userId, Map<String, dynamic> user) async {
    user = user..removeWhere((key, value) => ['id', 'created_at', 'updated_at', 'results'].contains(key));
    print(user);
    final response = await _request(context, '${await Constants.apiBaseUrl}/api/v1/admin/user/$userId', 'PUT', body: user);
    _handleResponse(response);
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> me() async {
    final response = await _request(context, '${await Constants.apiBaseUrl}/api/v1/user', 'GET');
    _handleResponse(response);
    return json.decode(response.body);
  }

  Future<bool> isAdmin() async {
    final user = await me();
    return user['is_admin'] == true;
  }
}

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