import 'dart:convert';

import 'package:desd_app/models/login_model.dart';
import 'package:desd_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class LoginViewModel extends ChangeNotifier {
  final BuildContext context;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? errorMessage;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  LoginViewModel(this.context);

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final loginModel = LoginModel(
      email: emailController.text,
      password: passwordController.text,
    );

    try {
      final response = await http.post(
        Uri.parse('${Constants.apiBaseUrl}/api/v1/auth/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(loginModel.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String token = data['token'];

        await _secureStorage.write(key: 'token', value: token);

        // ignore: use_build_context_synchronously
        context.go('/');

      } else if (response.statusCode == 401) {
        errorMessage = 'Invalid email or password';
        showSnackBar(errorMessage!);
      } else {
        errorMessage = 'An error occurred. Please try again later';
        showSnackBar(errorMessage!);
      }
    } catch (e) {
      errorMessage = 'An error occurred. Please try again later: $e';
      showSnackBar(errorMessage!);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}