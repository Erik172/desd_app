import 'package:flutter/material.dart';
import 'package:desd_app/services/user_service.dart';

class AdminViewModel extends ChangeNotifier {
  final UserService _userService;

  AdminViewModel(BuildContext context) : _userService = UserService(context: context) {
    getUsers();
    getCurrentUser();
  }
  List<dynamic> _users = [];
  Map<String, dynamic> _currentUser = {};

  List<dynamic> get users => _users;
  Map<String, dynamic> get currentUser => _currentUser;


  Future<void> getUsers() async {
    try {
      _users = await _userService.fetchUsers();
      notifyListeners();
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  Future<void> createUser(Map<String, dynamic> user) async {
    try {
      await _userService.createUser(user);
      getUsers();
    } catch (e) {
      print('Error creating user: $e');
    }
  }

  Future<void> getCurrentUser() async {
    try {
      _currentUser = await _userService.me();
      notifyListeners();
    } catch (e) {
      print('Error fetching user: $e');
    }
  }

  void deleteUser(dynamic userId) {
    _userService.deleteUser(userId);
    getUsers();
  }
}