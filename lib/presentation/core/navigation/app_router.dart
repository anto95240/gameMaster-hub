import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';
import 'package:gamemaster_hub/presentation/presentation_export.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  static GoRouter createRouter(BuildContext context) {
    return GoRouter(
      initialLocation: '/auth',
      refreshListenable: GoRouterRefreshStream(
        context.read<AuthBloc>().stream,
      ),
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;

        final isAuthRoute = state.uri.path == '/auth';

        if (authState is AuthUnauthenticated && !isAuthRoute) {
          return '/auth';
        }

        if (authState is AuthAuthenticated && isAuthRoute) {
          return '/';
        }

        return null;
      },
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
        ...SmRouter.routes,
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

            final game = state.extra as Game? ??
                Game(gameId: gameId, name: 'Jeu inconnu');

            final saveRepo = RepositoryProvider.of<SaveRepository>(context);
            final savesBloc = SavesBloc(saveRepository: saveRepo)
              ..add(LoadSavesEvent(gameId: game.gameId));

            return BlocProvider.value(
              value: savesBloc,
              child: SmSaveScreen(gameId: game.gameId, game: game),
            );
          },
        ),
      ],
    );
  }
}
