import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gamemaster_hub/domain/core/entities/game.dart';
import 'package:gamemaster_hub/domain/core/repositories/save_repository.dart';
import 'package:gamemaster_hub/presentation/core/screens/auth_screen.dart';
import 'package:gamemaster_hub/presentation/core/screens/home_screen.dart';
import 'package:gamemaster_hub/presentation/sm/screens/sm_main_screen.dart';
import 'package:gamemaster_hub/presentation/sm/screens/sm_save_screen.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/save/saves_bloc.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/save/saves_event.dart';

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
        path: '/sm/:saveId',
        name: 'soccer_manager',
        builder: (context, state) {
          final saveIdStr = state.pathParameters['saveId'];
          final saveId = int.tryParse(saveIdStr ?? '');
          if (saveId == null || saveId <= 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ID de sauvegarde invalide.')),
              );
              context.go('/');
            });
            return const SizedBox.shrink();
          }
          return SMMainScreen(saveId: saveId);
        },
      ),
      GoRoute(
        path: '/saves/:gameId',
        name: 'saves',
        builder: (context, state) {
          final gameId = int.tryParse(state.pathParameters['gameId'] ?? '');
          if (gameId == null || gameId <= 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ID du jeu invalide.')),
              );
              context.go('/');
            });
            return const SizedBox.shrink();
          }

          final game = state.extra as Game? ?? Game(gameId: gameId, name: 'Jeu inconnu');
          final saveRepo = RepositoryProvider.of<SaveRepository>(context);
          final savesBloc = SavesBloc(saveRepository: saveRepo)..add(LoadSavesEvent(gameId: game.gameId));

          return BlocProvider.value(
            value: savesBloc,
            child: SmSaveScreen(gameId: game.gameId, 
            // game: game, savesBloc: savesBloc
            ),
          );
        },
      ),
    ],
  );
}
