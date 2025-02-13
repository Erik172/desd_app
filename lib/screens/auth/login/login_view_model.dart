import 'dart:convert';
import 'dart:async';
import 'package:desd_app/models/login_model.dart';
import 'package:desd_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class LoginViewModel extends ChangeNotifier {
  final BuildContext context;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? errorMessage;

  late final FlutterSecureStorage _secureStorage;

  LoginViewModel(this.context) {
    _secureStorage = const FlutterSecureStorage();
  }

  void _showSnackBar(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _handleResponse(http.Response response) async {
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final String token = data['access_token'];

      await _secureStorage.write(key: 'token', value: token);
      if (context.mounted) context.go('/');
    } else if (response.statusCode == 401) {
      errorMessage = 'Invalid email or password';
    } else {
      errorMessage = 'An error occurred. Please try again later';
    }
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final loginModel = LoginModel(
      username: usernameController.text.trim(),
      password: passwordController.text.trim(),
    );

    try {
      final response = await http
          .post(
            Uri.parse('${await Constants.apiBaseUrl}/api/v1/auth'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode(loginModel.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      await _handleResponse(response);

      if (errorMessage != null) _showSnackBar(errorMessage!);
    } on TimeoutException {
      errorMessage = 'Request timed out. Please check your connection.';
      _showSnackBar(errorMessage!);
    } on FormatException {
      errorMessage = 'Invalid response format from server.';
      _showSnackBar(errorMessage!);
    } catch (e) {
      errorMessage = 'An error occurred: $e';
      debugPrint('Login error: $e');
      _showSnackBar(errorMessage!);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
