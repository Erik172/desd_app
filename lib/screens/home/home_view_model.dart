import 'package:desd_app/services/result_service.dart';
import 'package:desd_app/services/user_service.dart';
import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  final UserService userService = UserService();
  final ResultService resultService = ResultService();
  Map<String, dynamic> user = {};

  HomeViewModel() {
    userService.me().then((value) {
      user = value;
      notifyListeners();
    });

  }}