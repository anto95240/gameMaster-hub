import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gamemaster_hub/presentation/core/blocs/auth/auth_bloc.dart';
import 'package:gamemaster_hub/presentation/core/blocs/theme/theme_bloc.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isHomePage;
  final bool showLogo;
  final VoidCallback? onBackPressed;
  final VoidCallback? onSync;

  const CustomAppBar({
    super.key,
    required this.title,
    this.isHomePage = false,
    this.showLogo = false,
    this.onBackPressed,
    this.onSync,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF2C2C3A) : const Color(0xFFE5E7EB);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobileOrTablet = screenWidth < 800;
    
    return AppBar(
      backgroundColor: bgColor,
      centerTitle: false,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          if (!isHomePage && !showLogo)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => context.pop(),
              padding: EdgeInsets.zero,
            ),
          if (showLogo) ...[
            Image.asset(
              'assets/images/logo.png',
              height: 32,
              width: 32,
              errorBuilder: (context, error, stackTrace) => 
                const Icon(Icons.gamepad, size: 32),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: isMobileOrTablet 
          ? _buildMobileActions(context, isDark)
          : _buildDesktopActions(context, isDark),
    );
  }

  List<Widget> _buildMobileActions(BuildContext context, bool isDark) {
    return [
      PopupMenuButton<String>(
        icon: const Icon(Icons.menu),
        onSelected: (value) {
          switch (value) {
            case 'theme':
              context.read<ThemeBloc>().add(ToggleTheme());
              break;
            case 'sync':
              if (onSync != null) onSync!();
              break;
            case 'logout':
              context.read<AuthBloc>().add(AuthSignOutRequested());
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'theme',
            child: Row(
              children: [
                Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                const SizedBox(width: 12),
                const Text('Changer le thème'),
              ],
            ),
          ),
          if (onSync != null)
            const PopupMenuItem(
              value: 'sync',
              child: Row(
                children: [
                  Icon(Icons.sync),
                  SizedBox(width: 12),
                  Text('Synchroniser'),
                ],
              ),
            ),
          const PopupMenuItem(
            value: 'logout',
            child: Row(
              children: [
                Icon(Icons.logout),
                SizedBox(width: 12),
                Text('Déconnexion'),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(width: 8),
    ];
  }

  List<Widget> _buildDesktopActions(BuildContext context, bool isDark) {
    return [
      IconButton(
        icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
        tooltip: 'Changer le thème',
        onPressed: () {
          context.read<ThemeBloc>().add(ToggleTheme());
        },
      ),
      if (onSync != null)
        IconButton(
          icon: const Icon(Icons.sync),
          tooltip: 'Synchroniser',
          onPressed: onSync,
        ),
      IconButton(
        icon: const Icon(Icons.logout),
        tooltip: 'Déconnexion',
        onPressed: () {
          context.read<AuthBloc>().add(AuthSignOutRequested());
        },
      ),
      const SizedBox(width: 8),
    ];
  }
}
