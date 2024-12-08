import 'package:desd_app/providers/providers.dart';
import 'package:desd_app/services/auth_service.dart';
import 'package:desd_app/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class BasePageLayout extends StatefulWidget {
  final Widget child;
  final Widget? floatingActionButton;
  final String? title;

  const BasePageLayout({super.key, required this.child, this.title, this.floatingActionButton});

  @override
  State<BasePageLayout> createState() => _BasePageLayoutState();
}

class _BasePageLayoutState extends State<BasePageLayout> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CommonNavegationRail(
                  isExpanded: _isExpanded,
                  onToggleExpand: (value) {
                    setState(() {
                      _isExpanded = value;
                    });
                  },
                  navigationProvider: Provider.of<NavigationProvider>(context),
                  onLogout: () {
                    AuthService().logout();
                  },
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AppBar(
                        title: Text(widget.title ?? ''),
                        actions: <Widget>[
                          IconButton(
                            icon: Icon(
                              Provider.of<ThemeProvider>(context).isDarkMode
                                  ? Icons.light_mode
                                  : Icons.dark_mode,
                            ),
                            onPressed: () {
                              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout),
                            onPressed: () {
                              context.go('/logout');
                            },
                          ),
                        ],
                      ),
                      Expanded(
                        child: widget.child, // Contenido dinámico aquí.
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: widget.floatingActionButton,
    );
  }
}
