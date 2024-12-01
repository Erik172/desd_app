import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommonNavegationRail extends StatefulWidget {
  final bool isExpanded;
  final Function(bool) onToggleExpand;
  final ChangeNotifier navigationProvider;
  final VoidCallback onLogout;

  const CommonNavegationRail({
    super.key,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.navigationProvider,
    required this.onLogout,
  });

  @override
  State<CommonNavegationRail> createState() => _CommonNavegationRailState();
}

class _CommonNavegationRailState extends State<CommonNavegationRail> {
  bool isAdmin = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.navigationProvider,
      child: Consumer<ChangeNotifier>(
        builder: (context, provider, child) {
          final selectedIndex = (provider as dynamic).selectedIndex;
          final onItemTapped = (provider as dynamic).onItemTapped;

          return NavigationRail(
            extended: widget.isExpanded,
            selectedIndex: selectedIndex,
            groupAlignment: -0.9,
            onDestinationSelected: (int index) {
              onItemTapped(index);
            },
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                widget.onToggleExpand(!widget.isExpanded);
              },
            ),
            labelType: widget.isExpanded
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.home),
                selectedIcon: Icon(Icons.home_filled),
                label: Text('Home'),
              ),

              NavigationRailDestination(
                icon: Icon(Icons.find_in_page),
                label: Text('Auditoria'),
              ),

              NavigationRailDestination(
                icon: Badge(
                  // label: Text('2'),
                  child: Icon(Icons.task),
                ),
                label: Text('Resultados'),
              ),
            ],
          );
        },
      ),
    );
  }
}