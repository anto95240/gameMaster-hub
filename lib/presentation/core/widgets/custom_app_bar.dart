import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_event.dart';
import 'package:go_router/go_router.dart';
import 'package:gamemaster_hub/presentation/core/blocs/auth/auth_bloc.dart';
import 'package:gamemaster_hub/presentation/core/blocs/theme/theme_bloc.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_bloc.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isHomePage; // true si page home
  final VoidCallback? onBackPressed;
  final bool isMobile;
  final double mobileTitleSize;

  const CustomAppBar({
    super.key,
    required this.title,
    this.isHomePage = false,
    this.onBackPressed,
    this.isMobile = false,
    this.mobileTitleSize = 16,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final String? currentUserId = authState is AuthAuthenticated ? authState.user.id : null;

    final actions = [
      IconButton(
        onPressed: () => context.read<ThemeBloc>().add(ToggleTheme()),
        icon: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (_, state) => Icon(state.isDarkMode ? Icons.light_mode : Icons.dark_mode),
        ),
      ),
      IconButton(
        onPressed: () {
          context.read<JoueursSmBloc>().add(LoadJoueursSmEvent(0));
        },
        icon: const Icon(Icons.sync),
      ),
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
      title: Text(title, style: TextStyle(fontSize: isMobile ? mobileTitleSize : 20)),
      actions: isMobile
          ? [
              PopupMenuButton<int>(
                icon: const Icon(Icons.menu),
                itemBuilder: (_) => actions.map((widget) => PopupMenuItem<int>(child: widget)).toList(),
              ),
            ]
          : actions,
    );
  }
}
