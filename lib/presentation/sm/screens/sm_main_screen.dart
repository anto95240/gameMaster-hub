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
  final Game? game; // ← Game passé depuis la page save

  const SMMainScreen({super.key, required this.saveId, this.game});

  @override
  State<SMMainScreen> createState() => _SMMainScreenState();
}

class _SMMainScreenState extends State<SMMainScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late Game currentGame;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);

    // Si le Game est passé depuis la route, on l'utilise
    if (widget.game != null) {
      currentGame = widget.game!;
    } else {
      // Sinon on tente de récupérer depuis le GameBloc
      final games = context.read<GameBloc>().state is GamesLoaded
          ? (context.read<GameBloc>().state as GamesLoaded).games
          : [];
      currentGame = games.firstWhere(
        (g) => g.gameId == widget.saveId,
        orElse: () => Game(gameId: widget.saveId, name: 'Jeu inconnu'),
      );
    }
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
              // Navigation vers la page save avec le Game correct
              context.go('/saves/${currentGame.gameId}');
            },
            isMobile: isMobileOrTablet,
            mobileTitleSize: fontSize,
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              SMPlayersTab(saveId: widget.saveId, game: currentGame),
            ],
          ),
        );
      },
    );
  }
}
