import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/domain/core/entities/game.dart';
import 'package:gamemaster_hub/domain/core/repositories/save_repository.dart';
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
        builder: (context, state) {
          final gameIdStr = state.pathParameters['gameId'];
          final gameId = int.tryParse(gameIdStr ?? '') ?? 0;

          final game = state.extra as Game? ??
              Game(
                gameId: gameId,
                name: 'Jeu inconnu',
              );

          final saveRepo = RepositoryProvider.of<SaveRepository>(context);
          final savesBloc = SavesBloc(saveRepo)..add(LoadSavesEvent(game.gameId));

          return BlocProvider.value(
            value: savesBloc,
            child: SmSaveScreen(
              gameId: game.gameId,
              game: game,
              savesBloc: savesBloc,
            ),
          );
        },
      ),
    ],
  );
}
