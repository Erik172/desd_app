import 'package:flutter/material.dart';

class AuditoriaProvider extends ChangeNotifier {
  String _currentAuditoria = '';

  String get currentAuditoria => _currentAuditoria;

  void setCurrentAuditoria(String auditoria) {
    _currentAuditoria = auditoria;
    notifyListeners();
  }
}