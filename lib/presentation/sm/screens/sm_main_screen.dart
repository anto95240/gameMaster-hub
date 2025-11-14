import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';
import 'package:gamemaster_hub/presentation/presentation_export.dart';

class SMMainScreen extends StatefulWidget {
  final int saveId;
  final Game? game;
  final Save? save;

  const SMMainScreen({
    super.key,
    required this.saveId,
    this.game,
    this.save,
  });

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
  int _currentPlayerCount = 0;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _currentTabIndex = _tabController.index);
      }
    });
    
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
          errorMessage = 'Sauvegarde non trouvée.';
          isLoading = false;
        });
        return;
      }

      if (!mounted) return;

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
        errorMessage = 'Erreur lors du chargement : $e';
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection(int index) {
    final tacticsState = context.read<TacticsSmBloc>().state;
    final notEnoughForTactics = _currentPlayerCount < 22; 
    final tacticsNotDone = tacticsState.status != TacticsStatus.loaded ||
        tacticsState.assignedPlayersByPoste.isEmpty; 

    if ((index == 1 && notEnoughForTactics) ||
        (index == 2 && tacticsNotDone)) {
      Future.microtask(() => _tabController.animateTo(0));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            index == 1
                ? "Vous devez avoir au moins 22 joueurs pour accéder à la tactique." 
                : "Vous devez d'abord optimiser une tactique pour accéder à l'analyse.",
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final joueursState = context.watch<JoueursSmBloc>().state;
    final tacticsState = context.watch<TacticsSmBloc>().state; 

    if (joueursState is JoueursSmLoaded) {
      _currentPlayerCount = joueursState.joueurs.length;
    }

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
        floatingActionButton: _buildFab(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      );
    }

    final disableTactics = _currentPlayerCount < 22;
    final disableStats = tacticsState.status != TacticsStatus.loaded ||
        tacticsState.assignedPlayersByPoste.isEmpty;

    return Scaffold(
      appBar: CustomAppBar(
        title: '${currentGame!.name} - ${currentSave!.name}',
        onBackPressed: () =>
            context.go('/saves/${currentGame!.gameId}', extra: currentGame),
        onSync: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Synchronisation des données...'),
                duration: Duration(seconds: 1)),
          );
          _initializeData();
          context.read<JoueursSmBloc>().add(LoadJoueursSmEvent(widget.saveId));
          context.read<TacticsSmBloc>().add(LoadTactics(widget.saveId));
        },
        bottom: TabBar(
          controller: _tabController,
          onTap: _handleTabSelection,
          tabs: [
            const Tab(
              icon: Icon(Icons.people_alt),
              text: 'Joueurs',
            ),
            Tab(
              icon: Icon(Icons.sports_soccer,
                  color: disableTactics ? Colors.white38 : null),
              text: 'Tactique',
            ),
            Tab(
              icon: Icon(Icons.bar_chart,
                  color: disableStats ? Colors.white38 : null), 
              text: 'Analyse',
            ),
          ],
          indicatorColor: Colors.amberAccent,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SMPlayersTab(
            saveId: widget.saveId,
            currentTabIndex: _currentTabIndex,
          ),
          disableTactics
              ? _lockedTabMessage("Tactique", 22)  
              : SMTacticsTab(
                  saveId: widget.saveId,
                  game: currentGame!,
                  currentTabIndex: _currentTabIndex,
                ),
          disableStats
              ? _lockedTabMessage("Analyse", 0,
                  "Vous devez d'abord optimiser une tactique.")
              : SMAnalyseTab(
                  saveId: widget.saveId,
                  currentTabIndex: _currentTabIndex,
                ),
        ],
      ),
      floatingActionButton: _buildFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget? _buildFab(BuildContext context) {
    if (_currentTabIndex == 0) {
      return FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return BlocProvider.value(
                value: context.read<JoueursSmBloc>(),
                child: AddPlayerDialog(saveId: widget.saveId),
              );
            },
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      );
    }
    return null;
  }

  Widget _lockedTabMessage(String tabName, int requiredCount,
      [String? customMessage]) {
    final message = customMessage ??
        "Ajoutez au moins $requiredCount joueurs pour accéder à cette section.";
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, color: Colors.white38, size: 50),
          const SizedBox(height: 12),
          Text(
            "$tabName verrouillé",
            style: const TextStyle(fontSize: 20, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              message,
              style: const TextStyle(fontSize: 14, color: Colors.white54),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}