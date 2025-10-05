// lib/presentation/sm/screens/sm_main_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/sm_players_tab.dart';
import '../../core/blocs/auth/auth_bloc.dart';
import '../../core/blocs/theme/theme_bloc.dart';
import '../blocs/joueurs/joueurs_sm_bloc.dart';
import '../blocs/joueurs/joueurs_sm_event.dart';
import '../../../data/sm/repositories/joueur_sm_repository_impl.dart';
import '../../../data/sm/repositories/stats_joueur_sm_repository_impl.dart';
import '../../../data/sm/datasources/joueur_sm_remote_data_source.dart';
import '../../../data/sm/datasources/stats_joueur_sm_remote_data_source.dart';
import '../../core/utils/responsive_layout.dart';

class SMMainScreen extends StatefulWidget {
  const SMMainScreen({super.key});

  @override
  State<SMMainScreen> createState() => _SMMainScreenState();
}

class _SMMainScreenState extends State<SMMainScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = ResponsiveLayout.getScreenTypeFromWidth(constraints.maxWidth);
        final isMobile = screenType == ScreenType.mobile;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.arrow_back),
            ),
            title: isMobile
                ? const Icon(Icons.sports_soccer)
                : const Row(
                    children: [
                      Icon(Icons.sports_soccer),
                      SizedBox(width: 8),
                      Text('Soccer Manager'),
                    ],
                  ),
            actions: [
              IconButton(
                onPressed: () {
                  context.read<ThemeBloc>().add(ToggleTheme());
                },
                icon: BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, state) {
                    return Icon(
                      state.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    );
                  },
                ),
              ),
              if (!isMobile)
                IconButton(
                  onPressed: () {
                    context.read<JoueursSmBloc>().add(LoadJoueursSmEvent());
                  },
                  icon: const Icon(Icons.sync),
                ),
              IconButton(
                onPressed: () {
                  context.read<AuthBloc>().add(AuthSignOutRequested());
                  context.go('/auth');
                },
                icon: const Icon(Icons.account_circle),
              ),
            ],
            bottom: isMobile
                ? null
                : TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.group),
                        text: 'Joueurs',
                      ),
                    ],
                  ),
          ),
          body: isMobile
              ? const SMPlayersTab()
              : TabBarView(
                  controller: _tabController,
                  children: const [
                    SMPlayersTab(),
                  ],
                ),
        );
      },
    );
  }
}