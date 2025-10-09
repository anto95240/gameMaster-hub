import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/main.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_bloc.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_event.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_state.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/add_player_dialog.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/player_card_widget.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/player_details_dialog.dart';
import 'package:gamemaster_hub/presentation/core/utils/responsive_layout.dart';

class SMPlayersTab extends StatelessWidget {
  const SMPlayersTab({super.key});

  @override
  Widget build(BuildContext context) {
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
                  onPressed: () => context.read<JoueursSmBloc>().add(LoadJoueursSmEvent(globalSaveId)),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        } else if (state is JoueursSmLoaded) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final screenType = ResponsiveLayout.getScreenTypeFromWidth(constraints.maxWidth);
              final horizontalPadding = ResponsiveLayout.getHorizontalPadding(constraints.maxWidth);
              final verticalPadding = ResponsiveLayout.getVerticalPadding(constraints.maxWidth);

              return Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context, state, constraints.maxWidth),
                        SizedBox(height: screenType == ScreenType.mobile ? 16 : 24),
                        _buildFilters(context, state, constraints.maxWidth),
                        SizedBox(height: screenType == ScreenType.mobile ? 16 : 24),
                        Expanded(child: _buildPlayersGrid(context, state, constraints.maxWidth)),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: screenType == ScreenType.mobile
                        ? FloatingActionButton(
                            onPressed: () => _showAddPlayerDialog(context),
                            child: const Icon(Icons.add),
                          )
                        : ElevatedButton.icon(
                            onPressed: () => _showAddPlayerDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Ajouter'),
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

  Widget _buildHeader(BuildContext context, JoueursSmLoaded state, double width) {
    final screenType = ResponsiveLayout.getScreenTypeFromWidth(width);
    final isMobile = screenType == ScreenType.mobile;
    final isTablet = screenType == ScreenType.tablet;
    final isLaptop = screenType == ScreenType.laptop;

    final titleSize = isMobile ? 20.0 : (isTablet ? 24.0 : (isLaptop ? 28.0 : 32.0));

    final filteredPlayers = state.filteredJoueurs;
    final totalPlayers = filteredPlayers.length;
    final averageNiveauActuel = totalPlayers > 0
        ? filteredPlayers
                .map((p) => p.joueur.niveauActuel)
                .reduce((a, b) => a + b) /
            totalPlayers
        : 0;

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestion des Joueurs',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Joueurs',
                  totalPlayers.toString(),
                  Icons.people,
                  screenType,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Note',
                  averageNiveauActuel.toStringAsFixed(0),
                  Icons.star,
                  screenType,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Gestion des Joueurs',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 12 : (isLaptop ? 14 : 16),
            vertical: isTablet ? 10 : 12,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatCard(
                context,
                'Joueurs',
                totalPlayers.toString(),
                Icons.people,
                screenType,
              ),
              SizedBox(width: isTablet ? 16 : 30),
              _buildStatCard(
                context,
                'Note',
                averageNiveauActuel.toStringAsFixed(0),
                Icons.star,
                screenType,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, ScreenType screenType) {
    final isMobile = screenType == ScreenType.mobile;
    final isTablet = screenType == ScreenType.tablet;
    final isLaptop = screenType == ScreenType.laptop;
    
    final iconSize = isMobile ? 20.0 : (isTablet ? 22.0 : (isLaptop ? 24.0 : 26.0));
    final labelSize = isMobile ? 11.0 : (isTablet ? 12.0 : 13.0);
    final valueSize = isMobile ? 18.0 : (isTablet ? 20.0 : (isLaptop ? 22.0 : 24.0));
    final horizontalPadding = isMobile ? 16.0 : (isTablet ? 18.0 : (isLaptop ? 22.0 : 24.0));
    final verticalPadding = isMobile ? 12.0 : (isTablet ? 14.0 : (isLaptop ? 16.0 : 18.0));

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: Theme.of(context).colorScheme.primary),
          SizedBox(width: isTablet ? 8 : 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: labelSize,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: valueSize,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _showAddPlayerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => const AddPlayerDialog(),
    );
  }

  Widget _buildFilters(BuildContext context, JoueursSmLoaded state, double width) {
    final screenType = ResponsiveLayout.getScreenTypeFromWidth(width);
    final isMobile = screenType == ScreenType.mobile;
    final isTablet = screenType == ScreenType.tablet;
    final isLaptop = screenType == ScreenType.laptop;

    final positions = ['Tous', 'Gardien', 'Défenseur', 'Milieu', 'Attaquant'];

    // Sécuriser la valeur sélectionnée pour éviter l'erreur DropdownButton
    final selectedPosition = positions.contains(state.selectedPosition)
        ? state.selectedPosition
        : 'Tous';

    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedPosition,
                  decoration: const InputDecoration(
                    labelText: 'Position',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
                  items: positions
                      .map((position) => DropdownMenuItem(
                            value: position,
                            child: Text(position, overflow: TextOverflow.ellipsis),
                          ))
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
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Rechercher...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search, size: 20),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
                  onChanged: (value) {
                    context.read<JoueursSmBloc>().add(
                          FilterJoueursSmEvent(
                            position: selectedPosition,
                            searchQuery: value,
                          ),
                        );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSortControls(context, state, screenType),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: isTablet ? 2 : 1,
              child: DropdownButtonFormField<String>(
                value: selectedPosition,
                decoration: InputDecoration(
                  labelText: 'Position',
                  border: const OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 10 : (isLaptop ? 11 : 12),
                    vertical: isTablet ? 8 : 10,
                  ),
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: isTablet ? 13 : 14,
                    ),
                items: positions
                    .map((position) => DropdownMenuItem(
                          value: position,
                          child: Text(position, overflow: TextOverflow.ellipsis),
                        ))
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
              ),
            ),
            SizedBox(width: isTablet ? 12 : 16),
            Expanded(
              flex: isTablet ? 3 : 2,
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Rechercher...',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search, size: isTablet ? 18 : 20),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 10 : (isLaptop ? 11 : 12),
                    vertical: isTablet ? 8 : 10,
                  ),
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: isTablet ? 13 : 14,
                    ),
                onChanged: (value) {
                  context.read<JoueursSmBloc>().add(
                        FilterJoueursSmEvent(
                          position: selectedPosition,
                          searchQuery: value,
                        ),
                      );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSortControls(context, state, screenType),
      ],
    );
  }

  Widget _buildSortControls(BuildContext context, JoueursSmLoaded state, ScreenType screenType) {
    final isTablet = screenType == ScreenType.tablet;
    final isLaptop = screenType == ScreenType.laptop;
    
    final List<String> sortOptions = ['Nom', 'Note', 'Âge', 'Potentiel', 'Transfert', 'Salaire'];

    String sortFieldToString(SortField? field) {
      switch (field) {
        case SortField.name:
          return 'Nom';
        case SortField.rating:
          return 'Note';
        case SortField.age:
          return 'Âge';
        case SortField.potential:
          return 'Potentiel';
        case SortField.transferValue:
          return 'Transfert';
        case SortField.salary:
          return 'Salaire';
        default:
          return 'Nom';
      }
    }

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: sortFieldToString(state.sortField),
            decoration: InputDecoration(
              labelText: 'Trier par',
              border: const OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isTablet ? 10 : (isLaptop ? 11 : 12),
                vertical: isTablet ? 8 : 10,
              ),
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: isTablet ? 13 : 14,
                ),
            isExpanded: true,
            items: sortOptions
                .map<DropdownMenuItem<String>>(
                  (option) => DropdownMenuItem<String>(
                    value: option,
                    child: Text(
                      option,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: isTablet ? 13 : 14),
                    ),
                  ),
                )
                .toList(),
            onChanged: (String? value) {
              if (value != null) {
                context.read<JoueursSmBloc>().add(
                      SortJoueursSmEvent(
                        sortField: value,
                        ascending: state.sortAscending,
                      ),
                    );
              }
            },
          ),
        ),
        SizedBox(width: isTablet ? 8 : 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: IconButton(
            icon: Icon(
              state.sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: isTablet ? 18 : 20,
            ),
            padding: EdgeInsets.all(isTablet ? 8 : 10),
            constraints: BoxConstraints(
              minWidth: isTablet ? 40 : 48,
              minHeight: isTablet ? 40 : 48,
            ),
            onPressed: () {
              context.read<JoueursSmBloc>().add(
                    SortJoueursSmEvent(
                      sortField: sortFieldToString(state.sortField),
                      ascending: !state.sortAscending,
                    ),
                  );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlayersGrid(BuildContext context, JoueursSmLoaded state, double width) {
    final filteredPlayers = state.filteredJoueurs;

    if (filteredPlayers.isEmpty) {
      return const Center(child: Text('Aucun joueur trouvé'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = ResponsiveLayout.getScreenTypeFromWidth(constraints.maxWidth);
        final cardConstraints = ResponsiveLayout.getPlayerCardConstraints(screenType);
        final spacing = 16.0;

        // Calcul du nombre de colonnes optimal
        final maxColumns = screenType == ScreenType.mobile ? 2 :
                          (screenType == ScreenType.tablet ? 3 :
                          (screenType == ScreenType.laptop ? 4 : 5));

        final crossAxisCount = ResponsiveLayout.calculateOptimalColumns(
          availableWidth: constraints.maxWidth,
          constraints: cardConstraints,
          spacing: spacing,
          maxColumns: maxColumns,
        );

        // Calcul de la largeur effective pour chaque carte
        final totalSpacing = spacing * (crossAxisCount - 1);
        final availableForCards = constraints.maxWidth - totalSpacing;
        final cardWidth = cardConstraints.clampWidth(availableForCards / crossAxisCount);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Wrap(
              spacing: spacing,
              runSpacing: spacing,
              alignment: WrapAlignment.center,
              children: filteredPlayers.map((item) {
                return SizedBox(
                  width: cardWidth,
                  child: PlayerCardWidget(
                    item: item,
                    cardWidth: cardWidth,
                    onTap: () => _showPlayerDetails(context, item),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showPlayerDetails(BuildContext context, JoueurSmWithStats item) {
    showDialog(
      context: context,
      builder: (dialogContext) => PlayerDetailsDialog(item: item),
    );
  }
}