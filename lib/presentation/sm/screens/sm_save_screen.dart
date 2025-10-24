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

                int crossAxisCount = 2;
                if (screenWidth < 400) crossAxisCount = 1;
                else if (screenWidth < 800) crossAxisCount = 2;
                else crossAxisCount = 3;

                final spacing = 12.0;
                final cardWidth =
                    (screenWidth - (crossAxisCount - 1) * spacing) / crossAxisCount;

                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: GridView.builder(
                    itemCount: saves.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: spacing,
                      childAspectRatio: cardWidth / 170, 
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
