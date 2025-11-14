import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';
import 'package:gamemaster_hub/presentation/presentation_export.dart';

class SmSaveScreenLoader extends StatelessWidget {
  final int gameId;
  final SavesBloc savesBloc;
  final GameRepository gameRepository;

  const SmSaveScreenLoader({
    super.key,
    required this.gameId,
    required this.savesBloc,
    required this.gameRepository,
  });

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

        savesBloc.add(LoadSavesEvent(gameId: game.gameId));

        return BlocProvider.value(
          value: savesBloc,
          child: SmSaveScreen(
            gameId: game.gameId,
            game: game,
          ),
        );
      },
    );
  }
}
