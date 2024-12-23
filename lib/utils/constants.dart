// filepath: /D:/DESD_PROJECT/desd_app/lib/utils/constants.dart
import 'package:shared_preferences/shared_preferences.dart';

class Constants {
  static const String _apiBaseUrlKey = 'apiBaseUrl';
  static const String _defaultApiBaseUrl = 'http://127.0.0.1:8080';

  static Future<String> get apiBaseUrl async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiBaseUrlKey) ?? _defaultApiBaseUrl;
  }

  static Future<void> setApiBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiBaseUrlKey, url);
  }
}
