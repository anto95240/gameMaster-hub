import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_bloc.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_event.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_state.dart';

class SMPlayersFilters extends StatelessWidget {
  final JoueursSmLoaded state;
  final double width;

  const SMPlayersFilters({super.key, required this.state, required this.width});

  @override
  Widget build(BuildContext context) {
    final positions = ['Tous', 'Gardien', 'Défenseur', 'Milieu', 'Attaquant'];
    final selectedPosition = positions.contains(state.selectedPosition)
        ? state.selectedPosition
        : 'Tous';

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: selectedPosition,
            decoration: const InputDecoration(
              labelText: 'Position',
              border: OutlineInputBorder(),
            ),
            items: positions
                .map((pos) => DropdownMenuItem(value: pos, child: Text(pos)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                context.read<JoueursSmBloc>().add(FilterJoueursSmEvent(
                      position: value,
                      searchQuery: state.searchQuery,
                    ));
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Rechercher...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              context.read<JoueursSmBloc>().add(FilterJoueursSmEvent(
                    position: selectedPosition,
                    searchQuery: value,
                  ));
            },
          ),
        ),
      ],
    );
  }
}
