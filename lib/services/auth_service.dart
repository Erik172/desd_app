import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  Future<void> logout() async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    await secureStorage.delete(key: 'token');
  }

  Future<bool> isLoggedIn() async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    final String? token = await secureStorage.read(key: 'token');
    return token != null;
  }
}