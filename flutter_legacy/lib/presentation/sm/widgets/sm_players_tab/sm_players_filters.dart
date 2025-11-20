import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/presentation/presentation_export.dart';

class SMPlayersFilters extends StatelessWidget {
  final JoueursSmLoaded state;
  final double width;

  const SMPlayersFilters({
    super.key,
    required this.state,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final positions = ['Tous', 'Gardien', 'Défenseur', 'Milieu', 'Attaquant'];
    final selectedPosition = positions.contains(state.selectedPosition)
        ? state.selectedPosition
        : 'Tous';

    final isMobile = width < 600;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDropdown(context, positions, selectedPosition),
                const SizedBox(height: 8),
                _buildSearchField(context, selectedPosition),
              ],
            )
          : Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildDropdown(context, positions, selectedPosition),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: _buildSearchField(context, selectedPosition),
                ),
              ],
            ),
    );
  }

  Widget _buildDropdown(
    BuildContext context,
    List<String> positions,
    String selectedPosition,
  ) {
    return DropdownButtonFormField<String>(
      value: selectedPosition,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Position',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: positions
          .map((pos) => DropdownMenuItem(value: pos, child: Text(pos)))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          context.read<JoueursSmBloc>().add(
                FilterJoueursSmEvent(
                  position: value,
                  searchQuery: state.searchQuery,
                ),
              );
        }
      },
    );
  }

  Widget _buildSearchField(BuildContext context, String selectedPosition) {
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Rechercher...',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.search),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      onChanged: (value) {
        context.read<JoueursSmBloc>().add(
              FilterJoueursSmEvent(
                position: selectedPosition,
                searchQuery: value,
              ),
            );
      },
    );
  }
}
