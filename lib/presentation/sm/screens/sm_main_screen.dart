import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/sm_players_tab.dart';
import '../../core/blocs/auth/auth_bloc.dart';
import '../../core/blocs/theme/theme_bloc.dart';
import '../blocs/joueurs/joueurs_sm_bloc.dart';
import '../blocs/joueurs/joueurs_sm_event.dart';
import '../../core/utils/responsive_layout.dart';
import '../../../main.dart'; // 👈 pour accéder à globalSaveId

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
        final screenType =
            ResponsiveLayout.getScreenTypeFromWidth(constraints.maxWidth);
        final isMobile = screenType == ScreenType.mobile;
        double screenWidth = constraints.maxWidth;
        double fontSize = screenWidth < 400
                    ? 14
                    : screenWidth < 600
                        ? 16
                        : 18;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => context.go('/saves'),
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
                      state.isDarkMode
                          ? Icons.light_mode
                          : Icons.dark_mode,
                    );
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  context
                      .read<JoueursSmBloc>()
                      .add(LoadJoueursSmEvent(globalSaveId)); // 👈 ici
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
            bottom: TabBar(
              controller: _tabController,
              labelStyle: TextStyle(
                fontSize: fontSize,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.group),
                  text: 'Joueurs',
                ),
              ],
            ),
          ),
          body: TabBarView(
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
