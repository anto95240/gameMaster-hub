import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/data/core/repositories/save_repository_impl.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/save/saves_bloc.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/save/saves_event.dart';
import 'package:gamemaster_hub/presentation/sm/screens/sm_save_screen.dart';
import 'package:go_router/go_router.dart';

import '../screens/auth_screen.dart';
import '../screens/home_screen.dart';
import '../../sm/screens/sm_main_screen.dart';

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
      GoRoute(
        path: '/saves/:gameId',
        name: 'save',
        builder: (context, state) {
          final gameId = state.pathParameters['gameId']!;
          final saveRepository = RepositoryProvider.of<SaveRepositoryImpl>(context);

          return BlocProvider(
            create: (_) => SavesBloc(saveRepository)
              ..add(LoadSavesEvent(gameId)),
            child: SmSaveScreen(gameId: gameId),
          );
        },
      ),
    ],
  );
}
