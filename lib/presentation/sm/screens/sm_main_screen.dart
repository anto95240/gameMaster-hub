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
    
    // Le chargement des joueurs est maintenant géré par SMPlayersTab.dart
    // context.read<JoueursSmBloc>().add(LoadJoueursSmEvent(widget.saveId)); 
    
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
    final notEnoughForTactics = _currentPlayerCount < 11;
    final notEnoughForStats = _currentPlayerCount < 15;

    if ((index == 1 && notEnoughForTactics) ||
        (index == 2 && notEnoughForStats)) {
      // Bloque le changement d’onglet
      Future.microtask(() => _tabController.animateTo(0));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            index == 1
                ? "Vous devez avoir au moins 11 joueurs pour accéder à la tactique."
                : "Vous devez avoir au moins 15 joueurs pour accéder aux statistiques.",
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final joueursState = context.watch<JoueursSmBloc>().state;
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
        // Ajout du FAB même sur l'écran d'erreur
        floatingActionButton: _buildFab(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      );
    }

    final disableTactics = _currentPlayerCount < 11;
    final disableStats = _currentPlayerCount < 15;

    return Scaffold(
      appBar: CustomAppBar(
        title: '${currentGame!.name} - ${currentSave!.name}',
        onBackPressed: () =>
            context.go('/saves/${currentGame!.gameId}', extra: currentGame),
        onSync: () async {
          setState(() => isLoading = true);
          await _initializeData();
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
          labelColor: Colors.white,
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
              ? _lockedTabMessage("Tactique", 11)
              : SMTacticsTab(
                  saveId: widget.saveId,
                  game: currentGame!,
                  currentTabIndex: _currentTabIndex,
                ),
          disableStats
              ? _lockedTabMessage("Statistiques", 15)
              : SMAnalyseTab(
                  saveId: widget.saveId,
                  currentTabIndex: _currentTabIndex,
                ),
        ],
      ),
      
      // ✅✅✅ CORRECTION PRINCIPALE ✅✅✅
      floatingActionButton: _buildFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// Helper pour construire le FAB (Floating Action Button)
  Widget? _buildFab(BuildContext context) {
    // S'affiche que sur l'onglet Joueurs (index 0)
    if (_currentTabIndex == 0) { 
      return FloatingActionButton(
        onPressed: () {
          // Ouvre la boîte de dialogue pour ajouter un joueur
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              // On 'prépare' le contexte du BLoC pour le dialogue
              // C'est crucial pour que 'handlePlayerSubmit' fonctionne
              return BlocProvider.value(
                value: context.read<JoueursSmBloc>(),
                child: AddPlayerDialog(saveId: widget.saveId),
              );
            },
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      );
    }
    return null; // Masqué sur les autres onglets
  }

  /// Message affiché si la section est verrouillée (pas assez de joueurs)
  Widget _lockedTabMessage(String tabName, int requiredCount) {
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
          Text(
            "Ajoutez au moins $requiredCount joueurs pour accéder à cette section.",
            style: const TextStyle(fontSize: 14, color: Colors.white54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}