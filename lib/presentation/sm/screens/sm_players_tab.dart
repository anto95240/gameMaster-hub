import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/domain/core/entities/game.dart';

import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_bloc.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_event.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_state.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/add_player_dialog/add_player_dialog.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/sm_players_tab/sm_players_filters.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/sm_players_tab/sm_players_grid.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/sm_players_tab/sm_players_header.dart';

class SMPlayersTab extends StatelessWidget {
  final int saveId;
  final Game game;

  const SMPlayersTab({super.key, required this.saveId, required this.game});

  @override
  Widget build(BuildContext context) {
    context.read<JoueursSmBloc>().add(LoadJoueursSmEvent(saveId));

    return BlocBuilder<JoueursSmBloc, JoueursSmState>(
      builder: (context, state) {
        if (state is JoueursSmLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is JoueursSmError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Erreur: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      context.read<JoueursSmBloc>().add(LoadJoueursSmEvent(saveId)),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        } else if (state is JoueursSmLoaded) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SMPlayersHeader(state: state, width: constraints.maxWidth),
                        const SizedBox(height: 16),
                        SMPlayersFilters(state: state, width: constraints.maxWidth),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SMPlayersGrid(state: state, width: constraints.maxWidth, saveId: saveId),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton(
                      onPressed: () => _showAddPlayerDialog(context),
                      child: const Icon(Icons.add),
                    ),
                  ),
                ],
              );
            },
          );
        }
        return const Center(child: Text('État inconnu'));
      },
    );
  }

  void _showAddPlayerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AddPlayerDialog(saveId: saveId),
    );
  }
}
