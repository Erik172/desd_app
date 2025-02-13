// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter/material.dart';
import 'package:desd_app/routes/app_router.dart';
import 'package:desd_app/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:desd_app/utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  final apiBaseUrl = await Constants.apiBaseUrl;
  runApp(MyApp(apiBaseUrl: apiBaseUrl));
}

class MyApp extends StatelessWidget {
  final String apiBaseUrl;

  const MyApp({super.key, required this.apiBaseUrl});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider())
      ],
      child: Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
        return MaterialApp.router(
          title: 'DESD App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue, brightness: Brightness.dark),
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
          themeMode: themeProvider.themeMode,
          routerConfig: router,
        );
      }),
    );
  }
}
