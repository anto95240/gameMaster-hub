import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/domain/core/entities/game.dart';
import 'package:gamemaster_hub/presentation/core/blocs/game/game_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gamemaster_hub/presentation/core/utils/responsive_layout.dart';
import 'package:gamemaster_hub/presentation/sm/screens/sm_players_tab.dart';
import 'package:gamemaster_hub/presentation/core/widgets/custom_app_bar.dart';

class SMMainScreen extends StatefulWidget {
  final int saveId;
  const SMMainScreen({super.key, required this.saveId});

  @override
  State<SMMainScreen> createState() => _SMMainScreenState();
}

class _SMMainScreenState extends State<SMMainScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  Game? currentGame;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);

    // récupère le Game correspondant à cette saveId si disponible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final games = context.read<GameBloc>().state is GamesLoaded
          ? (context.read<GameBloc>().state as GamesLoaded).games
          : [];
      setState(() {
        currentGame = games.firstWhere(
          (g) => g.gameId == widget.saveId, // ou adapter selon gameId dans save
          orElse: () => Game(gameId: 0, name: 'Jeu inconnu'),
        );
      });
    });
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
        final isMobileOrTablet = screenType == ScreenType.mobile || screenType == ScreenType.tablet;
        double screenWidth = constraints.maxWidth;
        double fontSize = screenWidth < 400
            ? 14
            : screenWidth < 600
                ? 16
                : 18;

        return Scaffold(
          appBar: CustomAppBar(
            title: 'Soccer Manager',
            onBackPressed: () {
              // navigation vers SmSaveScreen avec le Game courant
              if (currentGame != null) {
                context.go('/saves/${currentGame!.gameId}', extra: currentGame);
              } else {
                context.go('/'); // fallback
              }
            },            
            isMobile: isMobileOrTablet,
            mobileTitleSize: fontSize,
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
