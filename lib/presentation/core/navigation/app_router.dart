import 'package:go_router/go_router.dart';

import '../screens/auth_screen.dart';
import '../screens/home_screen.dart';
import '../../sm/screens/sm_main_screen.dart';
// import '../../fm/screens/fm_main_screen.dart';
// import '../../swgoh/screens/swgoh_main_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/auth',
    routes: [
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/sm',
        name: 'soccer_manager',
        builder: (context, state) => const SMMainScreen(),
      ),
      // GoRoute(
      //   path: '/fm',
      //   name: 'football_manager',
      //   builder: (context, state) => const FMMainScreen(),
      // ),
      // GoRoute(
      //   path: '/swgoh',
      //   name: 'star_wars_goh',
      //   builder: (context, state) => const SWGoHMainScreen(),
      // ),
    ],
  );
}


// final GoRouter router = GoRouter(
//   initialLocation: '/',
//   routes: [
//     GoRoute(
//       path: '/',
//       builder: (context, state) => const HomePage(),
//     ),
//     // Exemple : SM Roster page
//     // GoRoute(
//     //   path: '/sm/roster',
//     //   builder: (context, state) => const SmRosterPage(),
//     // ),
//   ],
// );