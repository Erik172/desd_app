import 'package:desd_app/services/ip_service.dart';
import 'package:flutter/material.dart';
import 'package:desd_app/services/user_service.dart';

class AdminViewModel extends ChangeNotifier {
  final UserService _userService;
  final IpService _ipService;

  AdminViewModel(BuildContext context)
      : _userService = UserService(context: context),
        _ipService = IpService(context: context) {
    getUsers();
    getCurrentUser();
    getAllowedIps();
  }

  List<dynamic> _users = [];
  Map<String, dynamic> _currentUser = {};

  List<dynamic> get users => _users;
  Map<String, dynamic> get currentUser => _currentUser;

  Map<String, dynamic> _allowedIps = {};
  Map<String, dynamic> get allowedIps => _allowedIps;

  Future<void> getAllowedIps() async {
    try {
      _allowedIps = await _ipService.fetchAllowedIps();
      notifyListeners();
    } catch (e) {
      print('Error fetching allowed IPs: $e');
    }
  }

  Future<void> addAllowedIp(String ip) async {
    try {
      await _ipService.addAllowedIp(ip);
      getAllowedIps();
    } catch (e) {
      print('Error adding allowed IP: $e');
    }
  }

  Future<void> deleteAllowedIp(int idIp) async {
    try {
      await _ipService.deleteAllowedIp(idIp);
      getAllowedIps();
    } catch (e) {
      print('Error deleting allowed IP: $e');
    }
  }


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

  void switchAdminRole(String userId) async {
    Map<String, dynamic> user;
    user = await _userService.fetchUser(userId);
    user = user..removeWhere((key, value) => ['username', 'password'].contains(key));

    user['is_admin'] = !user['is_admin'];

    await _userService.updateUser(userId, user);
    getUsers();
  }
}