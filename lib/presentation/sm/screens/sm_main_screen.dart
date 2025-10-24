import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/domain/core/entities/game.dart';
import 'package:gamemaster_hub/domain/core/entities/save.dart';
import 'package:gamemaster_hub/domain/core/repositories/save_repository.dart';
import 'package:gamemaster_hub/presentation/core/blocs/game/game_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gamemaster_hub/presentation/sm/screens/sm_players_tab.dart';
import 'package:gamemaster_hub/presentation/core/widgets/custom_app_bar.dart';

class SMMainScreen extends StatefulWidget {
  final int saveId;
  final Game? game;
  final Save? save;

  const SMMainScreen({super.key, required this.saveId, this.game, this.save});

  @override
  State<SMMainScreen> createState() => _SMMainScreenState();
}

class _SMMainScreenState extends State<SMMainScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  Game? currentGame;
  Save? currentSave;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      if (widget.game != null && widget.save != null) {
        setState(() {
          currentGame = widget.game;
          currentSave = widget.save;
          isLoading = false;
        });
        return;
      }

      final saveRepo = context.read<SaveRepository>();
      final save = await saveRepo.getSaveById(widget.saveId);
      
      if (save == null) {
        setState(() {
          errorMessage = 'Save non trouvée';
          isLoading = false;
        });
        return;
      }

      final gameBloc = context.read<GameBloc>();
      final games = gameBloc.state is GamesLoaded
          ? (gameBloc.state as GamesLoaded).games
          : [];
      
      final game = games.firstWhere(
        (g) => g.gameId == save.gameId,
        orElse: () => Game(gameId: save.gameId, name: 'Jeu inconnu'),
      );

      setState(() {
        currentGame = game;
        currentSave = save;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur lors du chargement: $e';
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null || currentGame == null || currentSave == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(errorMessage ?? 'Données non disponibles'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {

        return Scaffold(
          appBar: CustomAppBar(
            title: '${currentGame!.name} - ${currentSave!.name}',
            onBackPressed: () {
              context.go('/saves/${currentGame!.gameId}', extra: currentGame);
            },
            onSync: () {
              setState(() {
                isLoading = true;
              });
              _initializeData();
            },
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              SMPlayersTab(saveId: widget.saveId, game: currentGame!),
            ],
          ),
        );
      },
    );
  }
}
