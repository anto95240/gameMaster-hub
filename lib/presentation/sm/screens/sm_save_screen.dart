import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';
import 'package:gamemaster_hub/presentation/presentation_export.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/save/save_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SmSaveScreen extends StatelessWidget {
  final int gameId;
  final Game game;

  const SmSaveScreen({super.key, required this.gameId, required this.game});

  @override
  Widget build(BuildContext context) {
    final savesBloc = context.read<SavesBloc>();
    savesBloc.add(LoadSavesEvent(gameId: gameId));

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Saves du jeu ${game.name}',
        onBackPressed: () => context.go('/'),
        onSync: () => savesBloc.add(LoadSavesEvent(gameId: gameId)),
      ),
      body: BlocBuilder<SavesBloc, SavesState>(
        builder: (context, state) {
          if (state is SavesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SavesLoaded) {
            final saves = List<Save>.from(state.saves)
              ..sort((a, b) => a.id.compareTo(b.id));

            if (saves.isEmpty) {
              return const Center(child: Text('Aucune sauvegarde disponible.'));
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;

                // 🧩 Responsive grid layout
                int crossAxisCount;
                double spacing;
                double verticalSpacing;
                double cardHeight;

                if (screenWidth < 480) {
                  // 📱 Mobile
                  crossAxisCount = 1;
                  spacing = 18.0;
                  verticalSpacing = 20.0;
                  cardHeight = 190;
                } else if (screenWidth < 900) {
                  // 💻 Tablette
                  crossAxisCount = 2;
                  spacing = 16.0;
                  verticalSpacing = 18.0;
                  cardHeight = 180;
                } else {
                  // 🖥️ Desktop
                  crossAxisCount = 3;
                  spacing = 12.0;
                  verticalSpacing = 14.0;
                  cardHeight = 170;
                }

                final cardWidth =
                    (screenWidth - (crossAxisCount - 1) * spacing) / crossAxisCount;

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing,
                    vertical: verticalSpacing,
                  ),
                  child: GridView.builder(
                    itemCount: saves.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: verticalSpacing,
                      childAspectRatio: cardWidth / cardHeight,
                    ),
                    itemBuilder: (context, index) {
                      final save = saves[index];
                      return SaveCard(save: save, gameId: gameId, game: game);
                    },
                  ),
                );
              },
            );
          } else if (state is SavesError) {
            return Center(child: Text('Erreur : ${state.message}'));
          }

          return const Center(child: Text('Chargement...'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSaveDialog(context),
        tooltip: 'Ajouter une sauvegarde',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddSaveDialog(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (ctx) => const SaveDialog(save: null),
    );

    if (result != null && result is Map<String, dynamic>) {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Utilisateur non connecté')),
          );
        }
        return;
      }

      context.read<SavesBloc>().add(AddSaveEvent(
            gameId: gameId,
            userId: userId,
            name: result['name'],
            description: result['description'],
          ));
    }
  }
}
