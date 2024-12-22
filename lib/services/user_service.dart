import 'dart:convert';
import 'package:desd_app/services/auth_service.dart';
import 'package:desd_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class UserService {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final AuthService authService = AuthService();
  final BuildContext context;

  UserService({required this.context});

  Future<String?> _getToken() async {
    return await secureStorage.read(key: 'token');
  }

  void _handleResponse(http.Response response) {
    if (response.statusCode == 401) {
      authService.logout();
      context.go('/login');
    } else if (response.statusCode != 200 && response.statusCode != 201) {
      print('Error: ${response.body}');
      throw Exception('Error: ${response.body}');
    }
  }

  Future<List<dynamic>> fetchUsers() async {
    final token = await _getToken();
    final url = '${await Constants.apiBaseUrl}/api/v1/users';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    _handleResponse(response);

    return json.decode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> fetchUser(String userId) async {
    final token = await _getToken();
    final url = '${await Constants.apiBaseUrl}/api/v1/users/$userId';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    _handleResponse(response);

    return json.decode(response.body);
  }

  Future<void> createUser(Map<String, dynamic> user) async {
    final token = await _getToken();
    final url = '${await Constants.apiBaseUrl}/api/v1/users';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(user),
    );

    _handleResponse(response);

    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> updateUser(
    String userId,
    Map<String, dynamic> user,
  ) async {
    final token = await _getToken();
    final url = '${await Constants.apiBaseUrl}/api/v1/users/$userId';
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(user),
    );

    _handleResponse(response);

    return json.decode(response.body);
  }

  Future<void> deleteUser(int userId) async {
    final token = await _getToken();
    final url = '${await Constants.apiBaseUrl}/api/v1/users/$userId';
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    _handleResponse(response);
  }

  Future<Map<String, dynamic>> me() async {
    final token = await _getToken();
    final url = '${await Constants.apiBaseUrl}/api/v1/auth/me';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    _handleResponse(response);

    return json.decode(response.body);
  }

  Future<bool> isAdmin() async {
    final token = await _getToken();
    final url = '${await Constants.apiBaseUrl}/api/v1/auth/me';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    _handleResponse(response);

    final user = json.decode(response.body);
    return user['is_admin'] == true;
  }
}