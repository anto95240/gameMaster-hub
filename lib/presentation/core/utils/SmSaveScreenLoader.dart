import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/save/saves_event.dart';
import 'package:gamemaster_hub/presentation/sm/screens/sm_save_screen.dart';
import '../../../domain/core/entities/game.dart';
import '../../../domain/core/repositories/game_repository.dart';
import '../../sm/blocs/save/saves_bloc.dart';

class SmSaveScreenLoader extends StatelessWidget {
  final int gameId;
  final SavesBloc savesBloc;
  final GameRepository gameRepository;

  const SmSaveScreenLoader({
    Key? key,
    required this.gameId,
    required this.savesBloc,
    required this.gameRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Game?>(
      future: gameRepository.getGameById(gameId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Erreur : ${snapshot.error}')),
          );
        } else if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('Erreur : Jeu non trouvé')),
          );
        }

        final game = snapshot.data!;

        // Déclenche l'événement de chargement des saves
        savesBloc.add(LoadSavesEvent(game.gameId));

        return BlocProvider.value(
          value: savesBloc,
          child: SmSaveScreen(
            gameId: game.gameId,
            game: game,
            savesBloc: savesBloc,
          ),
        );
      },
    );
  }
}
