import 'package:minesweeperapp/core/route/app_route_name.dart';
import 'package:go_router/go_router.dart';
import 'package:minesweeperapp/feature/home/home_page.dart';
import 'package:minesweeperapp/feature/home/welcome_page.dart';

class AppRoute {
  AppRoute._();

  static final GoRouter router = GoRouter(
    initialLocation: "/welcome",
    routes: [
      GoRoute(
        name: AppRouteName.welcome,
        path: "/welcome",
        builder: (context, state) {
          return const WelcomePage();
        }
      ),

      GoRoute(
        name: AppRouteName.home,
        path: "/home",
        builder: (context, state) {
          final difficulty = state.extra as String? ?? 'easy'; // default is easy
          return HomePage(difficulty: difficulty);
          // return const HomePage();
        },
      ),
    ],
  );
}
