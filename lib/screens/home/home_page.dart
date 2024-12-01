import 'package:desd_app/providers/providers.dart';
import 'package:desd_app/screens/home/home_view_model.dart';
import 'package:desd_app/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeViewModel(),
      child: Consumer2<HomeViewModel, NavigationProvider>(
        builder: (context, homeViewModel, navigationProvider, child) {
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
                        navigationProvider: navigationProvider,
                        onLogout: () {},
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            AppBar(
                              actions: <Widget>[
                                IconButton(
                                  icon: const Icon(Icons.logout),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                            const Expanded(
                              child: Placeholder(),
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
