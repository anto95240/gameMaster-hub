import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/domain/core/entities/game.dart';
import 'package:gamemaster_hub/main.dart';
import 'package:gamemaster_hub/presentation/core/blocs/auth/auth_bloc.dart';
import 'package:gamemaster_hub/presentation/core/blocs/theme/theme_bloc.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_bloc.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_event.dart';
import '../blocs/save/saves_bloc.dart';
import '../blocs/save/saves_state.dart';
import '../blocs/save/saves_event.dart';
import 'package:go_router/go_router.dart';

class SmSaveScreen extends StatelessWidget {
  final int gameId;
  final Game game;
  final SavesBloc savesBloc;

  const SmSaveScreen({
    Key? key,
    required this.gameId,
    required this.game,
    required this.savesBloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: savesBloc..add(LoadSavesEvent(gameId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Saves du jeu ${game.name}'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'), 
          ),
          actions: [
              IconButton(
                onPressed: () {
                  context.read<ThemeBloc>().add(ToggleTheme());
                },
                icon: BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, state) {
                    return Icon(
                      state.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    );
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  context
                      .read<JoueursSmBloc>()
                      .add(LoadJoueursSmEvent(globalSaveId));
                },
                icon: const Icon(Icons.sync),
              ),
              IconButton(
                onPressed: () {
                  context.read<AuthBloc>().add(AuthSignOutRequested());
                  context.go('/auth');
                },
                icon: const Icon(Icons.account_circle),
              ),
            ],
        ),
        body: BlocBuilder<SavesBloc, SavesState>(
          builder: (context, state) {
            if (state is SavesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SavesLoaded) {
              if (state.saves.isEmpty) {
                return const Center(child: Text('Aucune sauvegarde trouvée.'));
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: state.saves.length,
                  itemBuilder: (context, index) {
                    final save = state.saves[index];

                    return FutureBuilder(
                      future: Future.wait([
                        context.read<SavesBloc>().saveRepository.countPlayersBySave(save.id),
                        context.read<SavesBloc>().saveRepository.averageRatingBySave(save.id),
                      ]),
                      builder: (context, snapshot) {
                        int nbJoueurs = save.numberOfPlayers;
                        double avgRating = save.overallRating;
                        if (snapshot.hasData) {
                          nbJoueurs = snapshot.data![0] as int;
                          avgRating = snapshot.data![1] as double;
                        }

                        return Material(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          elevation: 4,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                            highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            onTap: () => context.go('/sm'),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          save.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () {},
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {},
                                      ),
                                    ],
                                  ),
                                  if (save.description != null && save.description!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Text(
                                        save.description!,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _infoCard('Joueurs', nbJoueurs.toString(), Colors.green),
                                      _infoCard('Note', avgRating.round().toString(), Colors.green),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            } else if (state is SavesError) {
              return Center(child: Text('Erreur: ${state.message}'));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _infoCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
