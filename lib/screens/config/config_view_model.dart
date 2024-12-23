// filepath: /D:/DESD_PROJECT/desd_app/lib/screens/config/config_view_model.dart
import 'package:flutter/material.dart';
import 'package:desd_app/utils/constants.dart';

class ConfigViewModel extends ChangeNotifier {
  String _apiBaseUrl = '';

  String get apiBaseUrl => _apiBaseUrl;

  ConfigViewModel() {
    _loadApiBaseUrl();
  }

  Future<void> _loadApiBaseUrl() async {
    _apiBaseUrl = await Constants.apiBaseUrl;
    notifyListeners();
  }

  Future<void> setApiBaseUrl(String url) async {
    await Constants.setApiBaseUrl(url);
    _apiBaseUrl = url;
    notifyListeners();
  }
}