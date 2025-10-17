import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/save/saves_bloc.dart';
import '../blocs/save/saves_state.dart';
import '../blocs/save/saves_event.dart';

class SmSaveScreen extends StatelessWidget {
  final String gameId;
  const SmSaveScreen({Key? key, required this.gameId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<SavesBloc>().add(LoadSavesEvent(gameId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Saves du jeu $gameId'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: BlocBuilder<SavesBloc, SavesState>(
        builder: (context, state) {
          if (state is SavesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SavesLoaded) {
            if (state.saves.isEmpty) {
              return const Center(child: Text('Aucune sauvegarde trouvée.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.saves.length,
              itemBuilder: (context, index) {
                final save = state.saves[index];

                return FutureBuilder(
                  future: Future.wait([
                    context.read<SavesBloc>().saveRepository.countPlayersBySave(save.id),
                    context.read<SavesBloc>().saveRepository.averageRatingBySave(save.id),
                  ]),
                  builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                    int nbJoueurs = save.numberOfPlayers;
                    double avgRating = save.overallRating;
                    if (snapshot.hasData) {
                      nbJoueurs = snapshot.data![0] as int;
                      avgRating = snapshot.data![1] as double;
                    }

                    return GestureDetector(
                      onTap: () {
                        context.go('/sm'); // redirection vers SMMainScreen
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(save.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                              if (save.description != null &&
                                  save.description!.isNotEmpty)
                                Text(save.description!),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Actif: ${save.isActive ? "Oui" : "Non"}'),
                                  Text('Joueurs: $nbJoueurs'),
                                  Text('Note globale: ${avgRating.toStringAsFixed(1)}'),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () async {
                                      // Formulaire de modification
                                      await showDialog(
                                        context: context,
                                        builder: (context) {
                                          final nameController = TextEditingController(text: save.name);
                                          final descController = TextEditingController(text: save.description ?? '');
                                          bool isActive = save.isActive;
                                          return AlertDialog(
                                            title: const Text('Modifier la save'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextField(
                                                  controller: nameController,
                                                  decoration: const InputDecoration(labelText: 'Nom'),
                                                ),
                                                TextField(
                                                  controller: descController,
                                                  decoration: const InputDecoration(labelText: 'Description'),
                                                ),
                                                CheckboxListTile(
                                                  value: isActive,
                                                  title: const Text('Actif'),
                                                  onChanged: (v) {
                                                    isActive = v ?? false;
                                                  },
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                                              TextButton(onPressed: () async {
                                                final updatedSave = save.copyWith(
                                                  name: nameController.text,
                                                  description: descController.text,
                                                  isActive: isActive,
                                                );
                                                await context.read<SavesBloc>().saveRepository.updateSave(updatedSave);
                                                context.read<SavesBloc>().add(LoadSavesEvent(gameId));
                                                Navigator.pop(context);
                                              }, child: const Text('Enregistrer')),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text('Confirmer la suppression'),
                                          content: const Text('Cette save et tous ses joueurs seront supprimés.'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
                                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
                                          ],
                                        ),
                                      );
                                      if (confirmed == true) {
                                        await context.read<SavesBloc>().saveRepository.deleteSave(save.id);
                                        context.read<SavesBloc>().add(LoadSavesEvent(gameId));
                                      }
                                    },
                                  ),
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
            );
          } else if (state is SavesError) {
            return Center(child: Text('Erreur: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
