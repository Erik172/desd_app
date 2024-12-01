import 'package:desd_app/screens/auth/login/login_page.dart';
import 'package:desd_app/screens/home/home_page.dart';
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
  ],
  // redirect: (context, state) async {
  //   final authService = AuthService();
  //   final isLoggedIn = await authService.isLoggedIn();

  //   final publicRoutes = {'/login'};

  //   if (!isLoggedIn && !publicRoutes.contains(state.matchedLocation)) {
  //     return '/login';
  //   }

  //   if (isLoggedIn && state.matchedLocation == '/login') {
  //     return '/';
  //   }

  //   return null;
  // },
);