import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';
import 'package:gamemaster_hub/presentation/presentation_export.dart';

class SMMainScreen extends StatefulWidget {
  final int saveId;
  final Game? game;
  final Save? save;

  const SMMainScreen({super.key, required this.saveId, this.game, this.save});

  @override
  State<SMMainScreen> createState() => _SMMainScreenState();
}

class _SMMainScreenState extends State<SMMainScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Game? currentGame;
  Save? currentSave;
  bool isLoading = true;
  String? errorMessage;

  final List<Tab> _tabs = const [
    Tab(text: 'Joueurs', icon: Icon(Icons.people_alt)),
    Tab(text: 'Tactique', icon: Icon(Icons.sports_soccer)),
    Tab(text: 'Stats', icon: Icon(Icons.bar_chart)),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
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
        appBar: CustomAppBar(
          title: 'Erreur',
          onBackPressed: () => context.go('/'),
        ),
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

    return Scaffold(
      appBar: CustomAppBar(
        title: '${currentGame!.name} - ${currentSave!.name}',
        onBackPressed: () => context.go(
          '/saves/${currentGame!.gameId}',
          extra: currentGame,
        ),
        onSync: () {
          setState(() => isLoading = true);
          _initializeData();
        },
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
          labelColor: Colors.white,
          indicatorColor: Colors.amberAccent,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SMPlayersTab(saveId: widget.saveId, game: currentGame!),
          SMTacticsTab(saveId: widget.saveId, game: currentGame!),
          const Center(
            child: Text(
              'Écran Statistiques (à venir)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
