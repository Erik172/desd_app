import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationProvider extends ChangeNotifier {
  bool _isDrawerOpen = false;
  int _selectedIndex = 0;

  bool get isDrawerOpen => _isDrawerOpen;

  void toggleDrawer() {
    _isDrawerOpen = !_isDrawerOpen;
    notifyListeners();
  }

  int get selectedIndex => _selectedIndex;

  void onItemTapped(BuildContext context, int index) {
    if (_selectedIndex == index) return; // Do nothing if the same index is selected

    _selectedIndex = index;
    notifyListeners();

    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/auditoria');
        break;
      case 2:
        context.go('/resultados');
        break;
      case 3:
        context.go('/configuracion');
        break;
      default:
        break;
    }
  }
}