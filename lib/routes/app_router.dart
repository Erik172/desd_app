import 'package:desd_app/screens/admin/admin_page.dart';
import 'package:desd_app/screens/auditoria/auditoria_page.dart';
import 'package:desd_app/screens/auth/login/login_page.dart';
import 'package:desd_app/screens/config/config_page.dart';
import 'package:desd_app/screens/duplicate/duplicate_page.dart';
import 'package:desd_app/screens/home/home_page.dart';
import 'package:desd_app/screens/resultados/resultados_page.dart';
import 'package:desd_app/services/auth_service.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),

    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),

    GoRoute(
      path: '/logout',
      builder: (context, state) => const LoginPage(),
      redirect: (context, state) async {
        if (state.matchedLocation == '/logout') {
          await AuthService().logout();
          return '/login';
        }
        return null;
      },
    ),

    GoRoute(
      path: '/auditoria',
      builder: (context, state) => const AuditoriaPage(),
    ),

    GoRoute(
      path: '/duplicado',
      builder: (context, state) => const DuplicatePage(),
    ),

    GoRoute(
      path: '/resultados',
      builder: (context, state) => const ResultadosPage(),
    ),

    GoRoute(
      path: '/configuracion',
      builder: (context, state) => const ConfigPage(),
    ),

    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminPage(),
    ),
  ],
  redirect: (context, state) async {
    final authService = AuthService();
    final isLoggedIn = await authService.isLoggedIn();

    final publicRoutes = {'/login', '/configuracion'};

    if (!isLoggedIn && !publicRoutes.contains(state.matchedLocation)) {
      return '/login';
    }

    if (isLoggedIn && state.matchedLocation == '/login') {
      return '/';
    }

    return null;
  },
);