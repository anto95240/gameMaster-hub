import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/presentation/core/blocs/game/game_bloc.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_bloc.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_event.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_state.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/save/saves_bloc.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/save/saves_event.dart';
import 'package:gamemaster_hub/presentation/core/blocs/auth/auth_bloc.dart';
import 'package:gamemaster_hub/presentation/core/blocs/theme/theme_bloc.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/save/saves_state.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isHomePage;
  final VoidCallback? onBackPressed;
  final bool isMobile;
  final double mobileTitleSize;
  final int? gameId;
  final int? saveId;

  const CustomAppBar({
    super.key,
    required this.title,
    this.isHomePage = false,
    this.onBackPressed,
    this.isMobile = false,
    this.mobileTitleSize = 16,
    this.gameId,
    this.saveId,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final String? currentUserId =
        authState is AuthAuthenticated ? authState.user.id : null;

    final actions = [
      // 🔹 Thème clair/sombre
      IconButton(
        onPressed: () => context.read<ThemeBloc>().add(ToggleTheme()),
        icon: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (_, state) =>
              Icon(state.isDarkMode ? Icons.light_mode : Icons.dark_mode),
        ),
      ),
      // 🔹 Synchronisation
      IconButton(
        onPressed: () async {
          final scaffold = ScaffoldMessenger.of(context);
          scaffold.showSnackBar(
            const SnackBar(
              content: Text('Synchronisation en cours...'),
              duration: Duration(minutes: 1),
            ),
          );

          final gameBloc = context.read<GameBloc>();
          final savesBloc = context.read<SavesBloc>();
          final joueursBloc = context.read<JoueursSmBloc>();

          try {
            // 1️⃣ Charger tous les jeux
            gameBloc.add(LoadGames());
            await gameBloc.stream.firstWhere(
              (state) => state is GamesLoaded || state is GamesError,
            );

            // 2️⃣ Charger les saves si gameId défini
            if (gameId != null) {
              savesBloc.add(LoadSavesEvent(gameId: gameId!));
              await savesBloc.stream.firstWhere(
                (state) => state is SavesLoaded || state is SavesError,
              );
            }

            // 3️⃣ Charger les joueurs si saveId défini
            if (saveId != null) {
              joueursBloc.add(LoadJoueursSmEvent(saveId!));
              await joueursBloc.stream.firstWhere(
                (state) => state is JoueursSmLoaded || state is JoueursSmError,
              );
            }

            scaffold.clearSnackBars();
            scaffold.showSnackBar(
              const SnackBar(
                content: Text('Synchronisation terminée'),
                duration: Duration(seconds: 2),
              ),
            );
          } catch (e) {
            scaffold.clearSnackBars();
            scaffold.showSnackBar(
              SnackBar(
                content: Text('Erreur lors de la synchronisation: $e'),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        icon: const Icon(Icons.sync),
      ),
      // 🔹 Déconnexion
      if (currentUserId != null)
        IconButton(
          onPressed: () {
            context.read<AuthBloc>().add(AuthSignOutRequested());
            context.go('/auth');
          },
          icon: const Icon(Icons.account_circle),
        ),
    ];

    return AppBar(
      leading: isHomePage
          ? null
          : IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => context.pop(),
            ),
      title: Text(
        title,
        style: TextStyle(fontSize: isMobile ? mobileTitleSize : 20),
      ),
      actions: isMobile
          ? [
              PopupMenuButton<int>(
                icon: const Icon(Icons.menu),
                itemBuilder: (_) =>
                    actions.map((widget) => PopupMenuItem<int>(child: widget)).toList(),
              ),
            ]
          : actions,
    );
  }
}
